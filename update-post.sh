#!/bin/bash

# 文章更新脚本 - 优化版
set -e

show_help() {
    echo "文章更新脚本"
    echo "使用方法: $0 \"文章标题或部分文件名\""
    echo ""
    echo "功能:"
    echo "  - 查找并更新指定文章"
    echo "  - 更新时间戳"
    echo "  - 检查并补充必要元数据"
    echo "  - 提交更改并推送到GitHub"
}

# 查找文章文件
find_post_file() {
    local search_term="$1"
    
    # 先尝试精确匹配
    local post_file=$(find source/_posts -name "*${search_term}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        echo "错误: 找不到包含 '$search_term' 的文章"
        echo ""
        echo "可用文章:"
        find source/_posts -name "*.md" -exec basename {} \; | head -10
        exit 1
    fi
    
    echo "$post_file"
}

# 更新文章时间戳
update_post_timestamp() {
    local post_file="$1"
    local current_time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    echo "更新时间戳: $current_time_utc"
    
    # 使用临时文件更安全地处理
    local temp_file="${post_file}.tmp"
    
    if grep -q "^last_updated:" "$post_file"; then
        # 更新现有的 last_updated
        awk -v new_time="$current_time_utc" '/^last_updated:/ {print "last_updated: " new_time; updated=1; next} {print} END {if (!updated) print "last_updated: " new_time}' "$post_file" > "$temp_file"
    else
        # 添加新的 last_updated
        awk -v new_time="$current_time_utc" '/^date:/ {print; print "last_updated: " new_time; next} {print}' "$post_file" > "$temp_file"
    fi
    
    mv "$temp_file" "$post_file"
}

# 检查必要元数据
check_metadata() {
    local post_file="$1"
    local missing_fields=()
    
    # 检查必要字段
    if ! grep -q "^tags:" "$post_file"; then
        missing_fields+=("tags")
    fi
    
    if ! grep -q "^categories:" "$post_file"; then
        missing_fields+=("categories")
    fi
    
    # 检查可选字段
    if ! grep -q "^cover:" "$post_file"; then
        echo "提示: 可以考虑添加封面图: cover: /img/cover-image.jpg"
    fi
    
    if ! grep -q "^description:" "$post_file"; then
        echo "提示: 可以考虑添加描述: description: 文章简要描述"
    fi
    
    # 如果有缺失的必要字段，提示用户
    if [ ${#missing_fields[@]} -gt 0 ]; then
        echo "警告: 文章缺少以下必要字段: ${missing_fields[*]}"
        echo "请在编辑文章时补充这些字段"
    fi
}

# 主逻辑
main() {
    if [ -z "$1" ]; then
        echo "错误: 请提供文章标题或部分文件名"
        show_help
        exit 1
    fi
    
    local search_term="$1"
    
    echo "=== 更新文章 ==="
    
    # 查找文章
    local post_file=$(find_post_file "$search_term")
    local post_name=$(basename "$post_file" .md)
    
    echo "找到文章: $post_name"
    echo "文件: $post_file"
    
    # 显示当前状态
    echo ""
    echo "当前Git状态:"
    git status --porcelain "$post_file" || true
    
    # 检查元数据
    check_metadata "$post_file"
    
    # 更新时间戳
    update_post_timestamp "$post_file"
    
    echo ""
    read -p "按回车键提交并发布更新，或 Ctrl+C 取消..."
    
    # 提交并推送
    echo "提交更改..."
    git add "$post_file"
    git commit -m "更新文章: $post_name"
    
    echo "推送到 GitHub..."
    git push origin main
    
    echo ""
    echo "🎉 更新成功!"
    echo "📦 CloudFlare Pages 正在自动构建..."
    echo "🌐 构建完成后访问: https://cyblog-b9j.pages.dev"
}

main "$@"