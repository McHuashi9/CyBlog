#!/bin/bash

# 增强版发布脚本 - 兼容Butterfly主题和WSL环境
set -e

show_help() {
    echo "文章发布脚本 - 支持Butterfly主题"
    echo "使用方法: $0 \"文章标题\""
    echo "或: $0 (交互式输入标题)"
    echo ""
    echo "功能:"
    echo "  - 创建新文章"
    echo "  - 自动添加默认标签和分类"
    echo "  - 提交到Git并推送到GitHub"
    echo "  - 触发CloudFlare Pages构建"
}

# 添加默认标签和分类
add_default_metadata() {
    local post_file="$1"
    local title="$2"
    
    echo "添加默认元数据..."
    
    # 创建临时文件
    local temp_file="${post_file}.tmp"
    
    # 检查并添加标签
    if ! grep -q "^tags:" "$post_file"; then
        if grep -q "^date:" "$post_file"; then
            awk '/^date:/ {print; print "tags: [暂未分类]"; next} 1' "$post_file" > "$temp_file"
            mv "$temp_file" "$post_file"
            echo "  - 添加默认标签: [暂未分类]"
        fi
    fi
    
    # 检查并添加分类
    if ! grep -q "^categories:" "$post_file"; then
        if grep -q "^tags:" "$post_file"; then
            awk '/^tags:/ {print; print "categories: [默认分类]"; next} 1' "$post_file" > "$temp_file"
            mv "$temp_file" "$post_file"
        else
            awk '/^date:/ {print; print "categories: [默认分类]"; next} 1' "$post_file" > "$temp_file"
            mv "$temp_file" "$post_file"
        fi
        echo "  - 添加默认分类: [默认分类]"
    fi
    
    # 添加文章描述（可选）
    if ! grep -q "^description:" "$post_file"; then
        if grep -q "^categories:" "$post_file"; then
            awk '/^categories:/ {print; print "description: 文章《'"$title"'》的简要描述"; next} 1' "$post_file" > "$temp_file"
            mv "$temp_file" "$post_file"
        else
            awk '/^date:/ {print; print "description: 文章《'"$title"'》的简要描述"; next} 1' "$post_file" > "$temp_file"
            mv "$temp_file" "$post_file"
        fi
        echo "  - 添加描述占位符"
    fi
    
    # 清理临时文件（如果存在）
    rm -f "$temp_file"
}

# 查找最新创建的文章文件
find_latest_post() {
    # 在WSL中使用ls命令按时间排序
    local latest_file=$(ls -t source/_posts/*.md 2>/dev/null | head -1)
    echo "$latest_file"
}

# 主逻辑
main() {
    # 获取标题参数
    if [ -z "$1" ]; then
        read -p "文章标题: " title
    else
        title="$1"
    fi
    
    if [ -z "$title" ]; then
        echo "错误: 文章标题不能为空"
        show_help
        exit 1
    fi
    
    echo "创建新文章: $title"
    hexo new "$title"
    
    # 查找新创建的文章文件
    local filename_pattern=$(echo "$title" | sed 's/ /-/g')
    local post_file=$(find source/_posts -name "*${filename_pattern}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        # 如果没找到，尝试获取最新创建的文件
        post_file=$(find_latest_post)
        echo "警告: 通过标题未找到文章，使用最新文件: $(basename "$post_file")"
    fi
    
    if [ -z "$post_file" ] || [ ! -f "$post_file" ]; then
        echo "错误: 找不到新创建的文章文件"
        echo "请检查 source/_posts/ 目录"
        exit 1
    fi
    
    echo "文章文件: $post_file"
    
    # 添加默认元数据
    add_default_metadata "$post_file" "$title"
    
    echo ""
    echo "请编辑文章内容，完成后按回车继续发布..."
    read -p "按回车继续..."
    
    echo "提交到 Git..."
    git add .
    git commit -m "发布: $title - $(date +'%Y-%m-%d %H:%M:%S')" || echo "备注: 无新更改或提交失败"
    
    echo "推送到 GitHub..."
    git push origin main
    
    echo ""
    echo "完成！博客地址: https://cyblog-b9j.pages.dev"
    echo "CloudFlare 构建中..."
    echo "提示: 文章已添加默认标签和分类，请记得在编辑时更新为实际值"
}

# 显示帮助信息
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

main "$@"