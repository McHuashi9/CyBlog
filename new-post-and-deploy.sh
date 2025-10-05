#!/bin/bash

# CloudFlare Pages 自动化发布脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# 显示帮助信息
show_help() {
    echo -e "${CYAN}"
    echo "=========================================="
    echo "      CloudFlare Pages 博客发布工具"
    echo "=========================================="
    echo -e "${NC}"
    echo "使用方法: $0 [文章标题]"
    echo ""
    echo "示例:"
    echo "  $0 \"我的新文章\""
    echo "  $0 \"技术分享：如何使用CloudFlare\""
    echo ""
    echo "如果没有提供标题，脚本会提示输入"
    echo ""
    echo "工作流程:"
    echo "  1. 创建新文章"
    echo "  2. 等待用户编辑"
    echo "  3. 提交到 Git"
    echo "  4. 推送到 GitHub（触发 CloudFlare 自动构建）"
    echo ""
    echo "博客地址: https://cyblog-b9j.pages.dev"
}

# 检查环境
check_environment() {
    # 检查是否在 Hexo 目录
    if [ ! -f "_config.yml" ] || [ ! -d "themes" ]; then
        log_error "请在 Hexo 博客根目录中运行此脚本"
        exit 1
    fi

    # 检查 Git 远程仓库配置
    if ! git remote get-url origin &> /dev/null; then
        log_error "未配置 Git 远程仓库，请先设置: git remote add origin <仓库URL>"
        exit 1
    fi

    # 检查网络连接
    if ! ping -c 1 github.com &> /dev/null; then
        log_warning "网络连接可能有问题，但继续执行..."
    fi
}

# 创建新文章
create_new_post() {
    local title="$1"
    local post_file
    
    log_step "创建新文章: $title"
    hexo new "$title"
    
    # 获取创建的文件路径
    post_file=$(find source/_posts -name "*${title}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        post_file="source/_posts/${title}.md"
    fi
    
    echo "$post_file"
}

# 等待用户编辑
wait_for_editing() {
    local post_file="$1"
    local title="$2"
    
    log_step "文章已创建: $post_file"
    echo ""
    log_info "请编辑文章文件，完成后返回此处继续发布"
    log_info "文件位置: $(pwd)/$post_file"
    echo ""
    
    # 尝试用 VS Code 打开，如果不可用则提示手动编辑
    if command -v code &> /dev/null; then
        log_info "检测到 VS Code，正在打开文件..."
        code "$post_file"
    elif command -v nano &> /dev/null; then
        log_info "使用 nano 编辑器..."
        nano "$post_file"
    else
        log_warning "请手动编辑文件: $post_file"
        log_info "可以使用你喜欢的编辑器打开上述文件"
    fi
    
    echo ""
    echo -e "${YELLOW}==========================================${NC}"
    read -p "文章编辑完成了吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "已取消发布，你可以在稍后手动提交和推送"
        log_info "手动发布命令:"
        log_info "  git add . && git commit -m '更新' && git push origin main"
        exit 0
    fi
}

# 提交和推送
commit_and_push() {
    local title="$1"
    
    log_step "提交更改到 Git..."
    
    # 添加所有更改
    if git add .; then
        log_success "文件已添加到暂存区"
    else
        log_error "添加文件到暂存区失败"
        exit 1
    fi
    
    # 提交更改
    local commit_message="发布新文章: $title - $(date +'%Y-%m-%d %H:%M:%S')"
    if git commit -m "$commit_message"; then
        log_success "提交成功: $commit_message"
    else
        log_warning "没有新更改可提交，或提交失败"
        # 继续执行，可能只有未跟踪的文件
    fi
    
    # 推送到 GitHub
    log_step "推送到 GitHub..."
    echo -e "${YELLOW}这将触发 CloudFlare Pages 自动构建和部署...${NC}"
    
    if git push origin main; then
        log_success "推送成功！"
    else
        log_error "推送失败，请检查网络连接和远程仓库设置"
        log_info "你可以稍后手动推送: git push origin main"
        exit 1
    fi
}

# 显示部署信息
show_deployment_info() {
    local start_time="$1"
    
    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    echo -e "${GREEN}==========================================${NC}"
    log_success "🎉 博客发布流程完成！"
    echo -e "${GREEN}==========================================${NC}"
    log_info "总耗时: ${duration} 秒"
    log_info "本地任务已完成，CloudFlare 开始自动构建"
    echo ""
    log_success "🌐 博客地址: https://cyblog-b9j.pages.dev"
    echo ""
    log_info "📊 构建状态:"
    log_info "  1. 访问 CloudFlare Pages 控制台查看构建进度"
    log_info "  2. 构建通常需要 1-3 分钟"
    log_info "  3. 构建成功后博客将自动更新"
    echo ""
    log_warning "💡 提示: 你可以立即开始写作下一篇博客！"
}

# 主函数
main() {
    local title="$1"
    local post_file
    local start_time=$(date +%s)
    
    echo -e "${CYAN}"
    echo "=========================================="
    echo "      CloudFlare Pages 博客发布工具"
    echo "=========================================="
    echo -e "${NC}"
    
    # 显示帮助信息（如果请求）
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    # 检查环境
    check_environment
    
    # 获取文章标题
    if [ -z "$title" ]; then
        echo -e "${CYAN}请输入新文章标题:${NC}"
        read -p "> " title
        if [ -z "$title" ]; then
            log_error "文章标题不能为空"
            exit 1
        fi
    fi
    
    log_info "开始发布流程: $title"
    echo ""
    
    # 执行流程
    post_file=$(create_new_post "$title")
    wait_for_editing "$post_file" "$title"
    commit_and_push "$title"
    show_deployment_info "$start_time"
}

# 运行主函数
main "$@"