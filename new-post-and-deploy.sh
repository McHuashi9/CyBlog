#!/bin/bash

# CloudFlare Pages 自动化发布脚本 - 优化版
set -e

# 颜色定义（仅用于终端显示，不传递给命令）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 清除颜色的函数（用于传递给命令的参数）
clean_output() {
    echo "$1" | sed -E 's/\x1B\[[0-9;]*[mGK]//g'
}

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}📝 $1${NC}"
}

# 检查环境
check_environment() {
    if [ ! -f "_config.yml" ] || [ ! -d "themes" ]; then
        log_error "请在 Hexo 博客根目录中运行此脚本"
        exit 1
    fi

    if ! git remote get-url origin &> /dev/null; then
        log_error "未配置 Git 远程仓库"
        exit 1
    fi
}

# 创建新文章（修复颜色代码问题）
create_new_post() {
    local title="$1"
    local clean_title=$(clean_output "$title")
    local post_file
    
    log_step "创建新文章: $clean_title"
    
    # 使用清理后的标题创建文章
    hexo new "$clean_title"
    
    # 获取创建的文件路径（使用清理后的标题搜索）
    post_file=$(find source/_posts -name "*${clean_title}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        # 如果找不到，尝试使用原始标题（不含颜色）
        post_file="source/_posts/${clean_title}.md"
    fi
    
    if [ ! -f "$post_file" ]; then
        log_error "文章创建失败，文件不存在: $post_file"
        log_info "请手动创建文章: hexo new \"$clean_title\""
        exit 1
    fi
    
    log_success "文章创建成功: $post_file"
    echo "$post_file"
}

# 等待用户编辑
wait_for_editing() {
    local post_file="$1"
    local clean_title="$2"
    
    echo ""
    log_info "请编辑文章文件:"
    log_info "文件位置: $post_file"
    echo ""
    
    # 尝试用编辑器打开
    if command -v code &> /dev/null; then
        log_info "使用 VS Code 打开文件..."
        code "$post_file"
    elif command -v nano &> /dev/null; then
        log_info "使用 nano 编辑器..."
        nano "$post_file"
    else
        log_warning "请手动编辑文件: $post_file"
    fi
    
    echo ""
    echo "=========================================="
    read -p "文章编辑完成了吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "已取消发布"
        log_info "你可以在稍后手动提交"
        exit 0
    fi
}

# 提交和推送
commit_and_push() {
    local title="$1"
    local clean_title=$(clean_output "$title")
    
    log_step "提交更改到 Git..."
    
    # 添加所有更改
    if git add .; then
        log_success "文件已添加到暂存区"
    else
        log_error "添加文件失败"
        exit 1
    fi
    
    # 提交更改
    local commit_message="发布新文章: $clean_title - $(date +'%Y-%m-%d %H:%M:%S')"
    if git commit -m "$commit_message"; then
        log_success "提交成功"
    else
        log_warning "没有新更改可提交"
    fi
    
    # 推送到 GitHub
    log_step "推送到 GitHub..."
    log_info "这将触发 CloudFlare Pages 自动构建..."
    
    if git push origin main; then
        log_success "推送成功！"
    else
        log_error "推送失败"
        log_info "请检查网络连接"
        exit 1
    fi
}

# 显示帮助
show_help() {
    echo "使用方法: $0 [文章标题]"
    echo ""
    echo "示例:"
    echo "  $0 \"我的新文章\""
    echo "  $0 \"技术分享\""
    echo ""
    echo "博客地址: https://cyblog-b9j.pages.dev"
}

# 主函数
main() {
    local title="$1"
    local clean_title
    local post_file
    local start_time=$(date +%s)
    
    echo "=========================================="
    echo "      CloudFlare Pages 博客发布工具"
    echo "=========================================="
    echo ""
    
    # 显示帮助
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    # 检查环境
    check_environment
    
    # 获取文章标题
    if [ -z "$title" ]; then
        echo "请输入新文章标题:"
        read -p "> " title
        if [ -z "$title" ]; then
            log_error "文章标题不能为空"
            exit 1
        fi
    fi
    
    # 清理标题中的颜色代码
    clean_title=$(clean_output "$title")
    
    log_info "开始发布流程: $clean_title"
    
    # 执行流程
    post_file=$(create_new_post "$clean_title")
    wait_for_editing "$post_file" "$clean_title"
    commit_and_push "$clean_title"
    
    # 显示完成信息
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    echo "=========================================="
    log_success "🎉 博客发布流程完成！"
    echo "=========================================="
    log_info "总耗时: ${duration} 秒"
    log_info "CloudFlare 正在自动构建..."
    echo ""
    log_success "🌐 博客地址: https://cyblog-b9j.pages.dev"
    echo ""
    log_info "构建状态: https://dash.cloudflare.com/"
}

# 运行主函数
main "$@"