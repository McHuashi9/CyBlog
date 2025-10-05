#!/bin/bash

# 简化的文章更新脚本 - 专注于提交更改
set -e

show_help() {
    echo "文章更新脚本"
    echo "使用方法: $0 \"文章标题\""
    echo ""
    echo "注意: 请确保已安装 moment-timezone: npm install moment-timezone --save"
}

# 更新文章时间戳（使用UTC时间存储，由过滤器转换显示）
update_post_timestamp() {
    local post_file="$1"
    
    # 使用UTC时间存储（ISO格式），由Hexo过滤器转换为中国时区显示
    local current_time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    echo "正在更新时间戳..."
    
    if grep -q "^last_updated:" "$post_file"; then
        sed -i "s/^last_updated: .*/last_updated: $current_time_utc/" "$post_file"
        echo "更新时间: $current_time_utc (存储为UTC)"
    else
        if grep -q "^tags:" "$post_file"; then
            sed -i "/^tags:/a last_updated: $current_time_utc" "$post_file"
        else
            sed -i "/^date:/a last_updated: $current_time_utc" "$post_file"
        fi
        echo "添加更新时间: $current_time_utc (存储为UTC)"
    fi
}

# 主逻辑
main() {
    if [ -z "$1" ]; then
        echo "错误: 请提供文章标题"
        show_help
        exit 1
    fi
    
    local search_term="$1"
    local post_file=$(find source/_posts -name "*${search_term}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        echo "错误: 找不到包含 '$search_term' 的文章"
        exit 1
    fi
    
    echo "更新文章: $(basename "$post_file" .md)"
    
    # 检查是否有更改
    if git status --porcelain "$post_file" | grep -q "^ M"; then
        echo "检测到未提交的更改，正在更新时间戳..."
        update_post_timestamp "$post_file"
        
        echo "提交更改..."
        git add .
        git commit -m "更新文章: $(basename "$post_file" .md)"
        git push origin main
        
        echo "推送成功！CloudFlare 构建中..."
        echo "博客地址: https://cyblog-b9j.pages.dev"
    else
        echo "没有检测到更改"
        echo "请先编辑文章，然后重新运行此脚本"
    fi
}

main "$@"