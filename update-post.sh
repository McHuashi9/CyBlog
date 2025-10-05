#!/bin/bash

# 文章本地编辑与更新脚本
set -e

# 显示帮助信息
show_help() {
    echo "文章更新工具"
    echo "使用方法: $0 [选项] <文章标题>"
    echo ""
    echo "选项:"
    echo "  -e, --exact    精确匹配标题"
    echo "  -l, --list     列出所有文章"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 \"测试文章\"           # 更新包含'测试文章'的文件"
    echo "  $0 -e \"测试文章\"        # 精确更新标题为'测试文章'的文件"
    echo "  $0 -l                   # 列出所有文章"
    echo ""
    echo "工作流程:"
    echo "  1. 找到要编辑的文章"
    echo "  2. 自动更新最后修改时间"
    echo "  3. 提交并推送到 GitHub"
    echo "  4. CloudFlare 自动部署"
}

# 列出所有文章
list_posts() {
    if [ -d "source/_posts" ]; then
        echo "现有文章列表:"
        echo "========================"
        for file in source/_posts/*.md; do
            if [ -f "$file" ]; then
                local title=$(basename "$file" .md)
                local created=$(grep -m1 "^date:" "$file" | sed 's/date: //' | head -1)
                local updated=$(grep "^last_updated:" "$file" | sed 's/last_updated: //' | head -1)
                
                echo "标题: $title"
                echo "创建: $created"
                if [ -n "$updated" ]; then
                    echo "更新: $updated"
                else
                    echo "更新: 从未更新"
                fi
                echo "------------------------"
            fi
        done
    else
        echo "文章目录不存在: source/_posts/"
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
        local created=$(grep -m1 "^date:" "$file" | sed 's/date: //' | head -1)
        echo "  $i. $title (创建: $created)"
        i=$((i+1))
    done
    
    echo ""
    read -p "请选择要更新的文章编号 (1-$count): " selection
    
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
        *)
            echo "取消更新操作"
            exit 0
            ;;
    esac
}

# 更新文章的最后修改时间
update_post_timestamp() {
    local post_file="$1"
    
    # 获取中国时区的当前时间
    local current_time=$(TZ='Asia/Shanghai' date +"%Y-%m-%d %H:%M:%S")
    
    # 检查是否已存在 last_updated 字段
    if grep -q "^last_updated:" "$post_file"; then
        # 更新现有的 last_updated 字段
        sed -i "s/^last_updated: .*/last_updated: $current_time/" "$post_file"
        echo "更新时间: $current_time (中国时区)"
    else
        # 在 tags 字段后添加 last_updated 字段
        # 如果 tags 字段不存在，就在 date 字段后添加
        if grep -q "^tags:" "$post_file"; then
            sed -i "/^tags:/a last_updated: $current_time" "$post_file"
        else
            sed -i "/^date:/a last_updated: $current_time" "$post_file"
        fi
        echo "添加更新时间: $current_time (中国时区)"
    fi
}

# 检查文章是否有未提交的更改
check_for_changes() {
    local post_file="$1"
    local post_title=$(basename "$post_file" .md)
    
    # 检查文件是否被修改
    if git status --porcelain "$post_file" | grep -q "^ M"; then
        echo "检测到文章 '$post_title' 有未提交的更改"
        echo ""
        echo "更改内容:"
        echo "=========================================="
        git diff "$post_file" | head -30
        echo "=========================================="
        echo ""
        return 0
    else
        echo "文章 '$post_title' 没有检测到更改"
        echo "如果你已经做了修改，请先保存文件"
        return 1
    fi
}

# 提交更改
commit_and_push() {
    local post_file="$1"
    local post_title=$(basename "$post_file" .md)
    
    echo ""
    read -p "是否立即提交并推送到 GitHub？(Y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "更改已保存到本地，稍后请手动提交"
        return 0
    fi
    
    echo "提交更改到 Git..."
    if git add . && git commit -m "更新文章: $post_title"; then
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
        echo "构建状态: https://dash.cloudflare.com/"
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
        list_posts
        exit 0
    fi
    
    # 如果没有提供搜索词，显示所有文章让用户选择
    if [ -z "$search_term" ]; then
        echo "请选择要更新的文章:"
        list_posts
        echo ""
        read -p "请输入文章标题: " search_term
        
        if [ -z "$search_term" ]; then
            echo "错误: 必须提供文章标题"
            exit 1
        fi
    fi
    
    # 查找匹配的文章
    local matches=($(find_matching_posts "$search_term" "$exact_match"))
    local match_count=${#matches[@]}
    
    if [ $match_count -eq 0 ]; then
        echo "错误: 找不到包含 '$search_term' 的文章"
        echo ""
        list_posts
        exit 1
    fi
    
    # 选择要更新的文章
    local post_file=""
    if [ $match_count -eq 1 ]; then
        post_file="${matches[0]}"
    else
        post_file=$(interactive_select "${matches[@]}")
        if [ -z "$post_file" ]; then
            exit 0
        fi
    fi
    
    local post_title=$(basename "$post_file" .md)
    
    echo ""
    echo "正在更新文章: $post_title"
    echo "文件路径: $post_file"
    echo ""
    
    # 检查是否有更改
    if check_for_changes "$post_file"; then
        # 更新最后修改时间
        update_post_timestamp "$post_file"
        
        # 提交更改
        commit_and_push "$post_file"
    else
        echo ""
        echo "没有检测到更改，跳过更新"
        echo "如果你已经做了修改:"
        echo "  1. 确保已保存文件"
        echo "  2. 重新运行此脚本"
        echo "  3. 或手动运行: git add . && git commit -m '更新' && git push origin main"
    fi
}

# 运行主函数
main "$@"