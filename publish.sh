#!/bin/bash

# Hexo 博客发布脚本 - 修复重复 tags 问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 简化的日志函数
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 创建新文章并添加标签（正确格式）
create_post_with_tags() {
    local title="$1"
    local tags_input="$2"
    
    log "创建新文章: $title"
    
    # 使用 hexo 创建文章
    if ! hexo new post "$title"; then
        error "文章创建失败"
        return 1
    fi
    
    # 获取创建的文件路径
    local filename=$(echo "$title" | sed 's/ /-/g')
    local filepath="source/_posts/${filename}.md"
    
    # 检查文件是否真的创建了
    if [[ ! -f "$filepath" ]]; then
        # 如果上述路径不存在，尝试查找最近创建的 .md 文件
        warn "未找到预期文件，尝试查找最近创建的文章文件..."
        local recent_file=$(find source/_posts -name "*.md" -type f -printf "%T@ %p\n" | sort -nr | head -1 | cut -d' ' -f2-)
        
        if [[ -n "$recent_file" && -f "$recent_file" ]]; then
            filepath="$recent_file"
            log "找到文章文件: $filepath"
        else
            error "无法找到新创建的文章文件"
            return 1
        fi
    fi
    
    # 如果有标签，添加到文章 front-matter（正确格式）
    if [[ -n "$tags_input" ]]; then
        log "添加标签: $tags_input"
        
        # 创建临时文件
        local temp_file=$(mktemp)
        
        # 处理标签输入并构建正确的 YAML 格式
        local normalized_input=$(echo "$tags_input" | sed 's/，/,/g')
        IFS=',' read -ra TAG_ARRAY <<< "$normalized_input"
        
        # 构建标签部分
        local tags_block="tags:"
        for tag in "${TAG_ARRAY[@]}"; do
            # 去除前后空格
            tag=$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -n "$tag" ]]; then
                tags_block+="\n  - $tag"
            fi
        done
        
        # 处理文件内容，在 date 行后插入 tags，但确保只插入一次
        local in_front_matter=true
        local date_found=false
        local tags_inserted=false
        
        while IFS= read -r line; do
            # 如果已经找到 date 行但还没有插入 tags，并且当前行不是 tags 行
            if [[ "$date_found" == true && "$tags_inserted" == false && ! "$line" =~ ^tags: ]]; then
                echo -e "$tags_block" >> "$temp_file"
                tags_inserted=true
            fi
            
            # 检查是否是 date 行
            if [[ "$line" =~ ^date: ]]; then
                date_found=true
            fi
            
            # 跳过已有的 tags 行（如果存在）
            if [[ "$line" =~ ^tags: ]]; then
                warn "发现已有 tags 字段，跳过并替换为新标签"
                continue
            fi
            
            # 写入当前行
            echo "$line" >> "$temp_file"
            
            # 检查 front-matter 结束
            if [[ "$line" == "---" ]] && [[ "$date_found" == true ]]; then
                in_front_matter=false
                # 如果在 front-matter 结束前还没有插入 tags，现在插入
                if [[ "$tags_inserted" == false ]]; then
                    echo -e "$tags_block" >> "$temp_file"
                    tags_inserted=true
                fi
            fi
        done < "$filepath"
        
        # 用临时文件替换原文件
        mv "$temp_file" "$filepath"
        log "标签已添加（正确格式）"
    fi
    
    echo "$filepath"
}

# 生成静态文件
generate_site() {
    log "生成静态文件..."
    if hexo clean && hexo generate; then
        log "静态文件生成成功"
    else
        error "静态文件生成失败"
        return 1
    fi
}

# 推送到 GitHub
push_to_github() {
    log "提交更改..."
    git add .
    git commit -m "发布新文章: $(date '+%Y-%m-%d %H:%M:%S')" || true
    
    log "推送到 GitHub..."
    if git push origin main; then
        log "推送成功，Cloudflare Pages 将自动部署"
        log "访问: https://cyblog-b9j.pages.dev"
    else
        error "推送失败"
        return 1
    fi
}

# 主函数
main() {
    log "Hexo 博客发布脚本"
    
    # 获取文章标题
    read -p "请输入文章标题: " title
    if [[ -z "$title" ]]; then
        error "文章标题不能为空"
        exit 1
    fi
    
    # 获取文章标签
    echo
    echo "请输入文章标签："
    echo "- 多个标签用逗号分隔（支持中英文逗号）"
    echo "- 标签可以有空格和中文"
    echo "- 不需要用双引号括起来"
    echo "- 例如：技术博客, Hexo教程, 网站开发"
    read -p "标签: " tags_input
    
    # 创建文章（添加正确格式的标签）
    post_file=$(create_post_with_tags "$title" "$tags_input")
    if [[ $? -ne 0 ]]; then
        error "创建文章失败"
        exit 1
    fi
    
    log "文章创建成功: $post_file"
    
    # 等待用户编辑完成
    echo
    read -p "文章编辑完成后，按回车键继续: " </dev/tty
    
    # 生成静态文件
    if ! generate_site; then
        error "生成静态文件失败"
        exit 1
    fi
    
    # 询问是否推送
    echo
    read -p "是否推送到 GitHub？[y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if push_to_github; then
            log "发布完成！"
        else
            error "推送失败"
            exit 1
        fi
    else
        warn "取消推送，文章已保存但未发布"
        log "您可以在稍后手动执行: git push origin main"
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi