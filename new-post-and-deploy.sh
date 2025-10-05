#!/bin/bash

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

# 检查是否在 Hexo 目录
check_hexo_directory() {
    if [ ! -f "_config.yml" ] || [ ! -d "themes" ]; then
        log_error "请在 Hexo 博客根目录中运行此脚本"
        exit 1
    fi
}

# 创建新文章
create_new_post() {
    local title="$1"
    local post_file
    
    log_step "创建新文章: $title"
    hexo new "$title"
    
    # 获取创建的文件路径
    post_file=$(find source/_posts -name "*${title// /-}*.md" | head -1)
    
    if [ -z "$post_file" ]; then
        post_file="source/_posts/${title}.md"
    fi
    
    echo "$post_file"
}

# 等待用户编辑
wait_for_editing() {
    local post_file="$1"
    
    log_step "文章已创建: $post_file"
    echo ""
    log_info "请编辑文章文件，完成后返回此处继续"
    log_info "文件位置: $post_file"
    echo ""
    
    # 检查是否有 GUI 编辑器可用
    if command -v code &> /dev/null; then
        log_info "检测到 VS Code，正在打开文件..."
        code "$post_file"
    elif command -v nano &> /dev/null; then
        log_info "使用 nano 编辑器..."
        nano "$post_file"
    else
        log_warning "请手动编辑文件: $post_file"
    fi
    
    echo ""
    read -p "编辑完成了吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "你可以稍后手动运行部署脚本"
        exit 0
    fi
}

# 部署博客
deploy_blog() {
    local start_time=$(date +%s)
    
    log_step "开始部署流程..."
    echo "=========================================="
    
    # 清理
    log_info "步骤 1: 清理缓存文件..."
    if hexo clean; then
        log_success "清理完成"
    else
        log_error "清理失败"
        return 1
    fi
    
    # 生成静态文件
    log_info "步骤 2: 生成静态文件..."
    if hexo generate; then
        log_success "生成完成"
    else
        log_error "生成失败"
        return 1
    fi
    
    # 部署到 GitHub
    log_info "步骤 3: 部署到 GitHub..."
    if hexo deploy; then
        log_success "部署完成"
    else
        log_error "部署失败"
        return 1
    fi
    
    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 显示总结
    echo "=========================================="
    log_success "🎉 博客发布成功！"
    log_info "总耗时: ${duration} 秒"
    log_info "博客地址: https://McHuashi9.github.io"
    log_warning "提示：更改可能需要 1-2 分钟才能在线显示"
}

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [文章标题]"
    echo ""
    echo "示例:"
    echo "  $0 \"我的新文章\""
    echo "  $0 \"技术分享：如何使用Hexo\""
    echo ""
    echo "如果没有提供标题，脚本会提示输入"
}

# 主函数
main() {
    local title="$1"
    local post_file
    
    echo -e "${CYAN}"
    echo "=========================================="
    echo "      Hexo 博客创作与部署工具"
    echo "=========================================="
    echo -e "${NC}"
    
    # 检查环境
    check_hexo_directory
    
    # 获取文章标题
    if [ -z "$title" ]; then
        read -p "请输入文章标题: " title
        if [ -z "$title" ]; then
            log_error "文章标题不能为空"
            exit 1
        fi
    fi
    
    # 执行流程
    post_file=$(create_new_post "$title")
    wait_for_editing "$post_file"
    deploy_blog
}

# 显示帮助信息（如果请求）
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 运行主函数
main "$@"