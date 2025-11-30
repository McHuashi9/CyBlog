#!/bin/bash

# Hexo 博客发布脚本 - 简化版
# 先确保基本功能正常，后续再添加标签功能

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

# 检查基本环境
check_environment() {
    log "检查环境..."
    
    if ! command -v hexo &> /dev/null; then
        error "Hexo 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        error "Git 未安装"
        exit 1
    fi
    
    log "环境检查通过"
}

# 创建新文章（简化版，不添加标签）
create_post() {
    local title="$1"
    
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
    log "Hexo 博客发布脚本 - 简化版"
    
    # 检查环境
    check_environment
    
    # 获取文章标题
    read -p "请输入文章标题: " title
    if [[ -z "$title" ]]; then
        error "文章标题不能为空"
        exit 1
    fi
    
    # 创建文章（不添加标签）
    post_file=$(create_post "$title")
    if [[ $? -ne 0 ]]; then
        error "创建文章失败"
        exit 1
    fi
    
    log "文章创建成功: $filepath"
    log "请手动编辑文件添加标签，然后使用您喜欢的编辑器编辑内容"
    log "文件位置: $post_file"
    
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