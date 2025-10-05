#!/bin/bash

# 文章删除脚本 - 无颜色简化版
set -e

# 显示帮助信息
show_help() {
    echo "文章删除工具"
    echo "使用方法: $0 [选项] <文章标题>"
    echo ""
    echo "选项:"
    echo "  -e, --exact    精确匹配标题"
    echo "  -l, --list     列出所有文章"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 \"测试文章\"           # 模糊匹配包含'测试文章'的文件"
    echo "  $0 -e \"测试文章\"        # 精确匹配标题为'测试文章'的文件"
    echo "  $0 -l                   # 列出所有文章"
    echo ""
    echo "现有文章:"
    list_posts_short
}

# 列出所有文章（简短格式）
list_posts_short() {
    if [ -d "source/_posts" ]; then
        ls -1 source/_posts/ | head -10
        local count=$(ls -1 source/_posts/ | wc -l)
        if [ $count -gt 10 ]; then
            echo "... 还有 $((count - 10)) 篇文章"
        fi
    else
        echo "文章目录不存在: source/_posts/"
    fi
}

# 列出所有文章（详细格式）
list_posts_detailed() {
    if [ -d "source/_posts" ]; then
        echo "现有文章列表:"
        local i=1
        for file in source/_posts/*.md; do
            if [ -f "$file" ]; then
                local title=$(basename "$file" .md)
                local date=$(grep -m1 "^date:" "$file" | cut -d' ' -f2 | head -1)
                echo "  $i. $title ($date)"
                i=$((i+1))
            fi
        done
    fi
}

# 查找匹配的文章
find_matching_posts() {
    local search_term="$1"
    local exact_match="$2"
    local matches=()
    
    if [ "$exact_match" = "true" ]; then
        # 精确匹配：查找完全匹配的文件
        for file in source/_posts/*.md; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file" .md)
                if [ "$filename" = "$search_term" ]; then
                    matches+=("$file")
                fi
            fi
        done
    else
        # 模糊匹配：查找包含搜索词的文件
        for file in source/_posts/*.md; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file" .md)
                if [[ "$filename" == *"$search_term"* ]]; then
                    matches+=("$file")
                fi
            fi
        done
    fi
    
    printf '%s\n' "${matches[@]}"
}

# 交互式选择文章
interactive_select() {
    local matches=("$@")
    local count=${#matches[@]}
    
    echo ""
    echo "找到 $count 个匹配的文章:"
    local i=1
    for file in "${matches[@]}"; do
        local title=$(basename "$file" .md)
        local date=$(grep -m1 "^date:" "$file" | cut -d' ' -f2 | head -1)
        echo "  $i. $title ($date)"
        i=$((i+1))
    done
    
    echo ""
    read -p "请选择要删除的文章编号 (1-$count), 或输入 'a' 删除所有, 或 'c' 取消: " selection
    
    case $selection in
        [1-9]|[1-9][0-9])
            if [ $selection -le $count ]; then
                local selected_index=$((selection-1))
                echo "${matches[$selected_index]}"
            else
                echo "错误: 无效的选择: $selection"
                exit 1
            fi
            ;;
        a|A)
            echo "ALL"
            ;;
        c|C|*)
            echo "取消删除操作"
            exit 0
            ;;
    esac
}

# 删除文章
delete_post() {
    local post_file="$1"
    local search_term="$2"
    
    if [ ! -f "$post_file" ]; then
        echo "错误: 文件不存在: $post_file"
        exit 1
    fi
    
    echo ""
    echo "准备删除文章: $(basename "$post_file" .md)"
    echo "文件路径: $post_file"
    echo ""
    echo "文章内容预览:"
    echo "=========================================="
    head -15 "$post_file"
    echo "=========================================="
    echo ""
    
    read -p "确认删除这篇文章吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$post_file"
        echo "已删除文章: $(basename "$post_file" .md)"
        return 0
    else
        echo "取消删除"
        return 1
    fi
}

# 提交更改
commit_changes() {
    local search_term="$1"
    
    echo ""
    read -p "是否立即提交并推送到 GitHub？(Y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "更改已保存到本地，稍后请手动提交"
        return 0
    fi
    
    echo "提交更改到 Git..."
    if git add . && git commit -m "删除文章: $search_term"; then
        echo "提交成功"
    else
        echo "提交失败或没有更改可提交"
        return 0
    fi
    
    echo "推送到 GitHub..."
    if git push origin main; then
        echo "推送成功！CloudFlare 将自动更新"
        echo ""
        echo "博客地址: https://cyblog-b9j.pages.dev"
    else
        echo "推送失败，请检查网络连接"
    fi
}

# 主函数
main() {
    local search_term=""
    local exact_match="false"
    local list_only="false"
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--exact)
                exact_match="true"
                shift
                ;;
            -l|--list)
                list_only="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "错误: 未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                search_term="$1"
                shift
                ;;
        esac
    done
    
    # 检查是否在 Hexo 目录
    if [ ! -d "source/_posts" ]; then
        echo "错误: 请在 Hexo 博客根目录中运行此脚本"
        exit 1
    fi
    
    # 如果只是列出文章
    if [ "$list_only" = "true" ]; then
        list_posts_detailed
        exit 0
    fi
    
    # 如果没有提供搜索词
    if [ -z "$search_term" ]; then
        echo "错误: 请提供要删除的文章标题"
        echo ""
        show_help
        exit 1
    fi
    
    # 查找匹配的文章
    local matches=($(find_matching_posts "$search_term" "$exact_match"))
    local match_count=${#matches[@]}
    
    if [ $match_count -eq 0 ]; then
        echo "错误: 找不到包含 '$search_term' 的文章"
        echo ""
        list_posts_short
        exit 1
    fi
    
    # 选择要删除的文章
    local to_delete=""
    if [ $match_count -eq 1 ]; then
        to_delete="${matches[0]}"
    else
        to_delete=$(interactive_select "${matches[@]}")
        if [ -z "$to_delete" ]; then
            exit 0
        fi
    fi
    
    # 处理删除所有的情况
    if [ "$to_delete" = "ALL" ]; then
        echo "警告: 将删除所有 $match_count 个匹配的文章"
        read -p "确认删除所有匹配的文章吗？此操作不可撤销！(y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local deleted_count=0
            for file in "${matches[@]}"; do
                rm "$file"
                echo "已删除: $(basename "$file" .md)"
                deleted_count=$((deleted_count+1))
            done
            echo "共删除 $deleted_count 篇文章"
        else
            echo "取消删除所有文章"
            exit 0
        fi
    else
        # 删除单个文章
        if delete_post "$to_delete" "$search_term"; then
            # 删除成功，继续提交
            commit_changes "$search_term"
        fi
    fi
}

# 运行主函数
main "$@"