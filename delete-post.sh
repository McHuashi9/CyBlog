#!/bin/bash

# 文章删除脚本
set -e

show_help() {
    echo "文章删除脚本"
    echo "使用方法: $0 \"文章标题或部分文件名\""
    echo ""
    echo "功能:"
    echo "  - 查找并删除指定文章"
    echo "  - 提交更改并重新部署"
}

find_post_file() {
    local search_term="$1"
    
    # 查找匹配的文章文件
    local post_files=($(find source/_posts -name "*${search_term}*.md"))
    
    if [ ${#post_files[@]} -eq 0 ]; then
        echo "错误: 找不到包含 '$search_term' 的文章"
        echo ""
        echo "可用文章:"
        find source/_posts -name "*.md" -exec basename {} \; | head -10
        exit 1
    fi
    
    # 如果找到多个匹配项，让用户选择
    if [ ${#post_files[@]} -gt 1 ]; then
        echo "找到多个匹配的文章:"
        for i in "${!post_files[@]}"; do
            echo "  $((i+1)). $(basename "${post_files[i]}")"
        done
        
        read -p "请选择要删除的文章编号 (1-${#post_files[@]}): " choice
        if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#post_files[@]} ]; then
            echo "${post_files[$((choice-1))]}"
        else
            echo "无效的选择"
            exit 1
        fi
    else
        echo "${post_files[0]}"
    fi
}

main() {
    if [ -z "$1" ]; then
        echo "错误: 请提供文章标题或部分文件名"
        show_help
        exit 1
    fi
    
    local search_term="$1"
    
    echo "=== 删除文章 ==="
    
    # 查找文章
    local post_file=$(find_post_file "$search_term")
    local post_name=$(basename "$post_file" .md)
    
    echo "找到文章: $post_name"
    echo "文件: $post_file"
    
    # 显示文章前几行内容作为确认
    echo ""
    echo "文章预览 (前5行):"
    head -5 "$post_file"
    echo "..."
    echo ""
    
    # 确认删除
    read -p "⚠️  确认要删除这篇文章吗？此操作不可撤销！(y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # 删除文件
        rm "$post_file"
        echo "✅ 已删除文件: $post_file"
        
        # 提交更改
        echo "提交更改..."
        git add .
        git commit -m "删除文章: $post_name"
        
        echo "推送到 GitHub..."
        git push origin main
        
        echo ""
        echo "🗑️  文章删除完成!"
        echo "📦 CloudFlare Pages 正在重新构建..."
        echo "🌐 稍后访问: https://cyblog-b9j.pages.dev"
    else
        echo "❌ 取消删除操作"
        exit 0
    fi
}

main "$@"