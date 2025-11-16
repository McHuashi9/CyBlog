#!/bin/bash

# 文章创建和发布脚本 - 修复版（移除内容检测）
set -e

show_help() {
    echo "使用方法: $0 \"文章标题\""
    echo ""
    echo "功能:"
    echo "  - 创建新文章并添加基本元数据"
    echo "  - 等待用户编辑"
    echo "  - 提交并推送到 GitHub"
    echo "  - 触发 CloudFlare Pages 自动构建"
}

check_network() {
    if nslookup github.com >/dev/null 2>&1; then
        return 0
    else
        echo "❌ 网络连接问题，请检查网络"
        return 1
    fi
}

if [ -z "$1" ]; then
    echo "错误: 请提供文章标题"
    show_help
    exit 1
fi

title="$1"
filename="$(date +%Y-%m-%d)-${title}.md"
post_file="source/_posts/$filename"

echo "=== 创建新文章 ==="
echo "标题: $title"
echo "文件: $post_file"

# 检查文件是否已存在
if [ -f "$post_file" ]; then
    echo "⚠️  文件已存在，使用新时间戳"
    filename="$(date +%Y-%m-%d-%H%M)-${title}.md"
    post_file="source/_posts/$filename"
fi

# 创建文章框架
# 在创建文章框架的部分修改为：
cat > "$post_file" << EOF
---
title: $title
date: $(date +"%Y-%m-%d %H:%M:%S")
tags: []
categories: []
mathjax: true  # 启用数学公式
---


EOF

echo "✅ 文章框架已创建"
echo ""
echo "📝 请用 VSCode 编辑文件:"
echo "   code $post_file"
echo ""
read -p "编辑完成后按回车键提交并发布..."

# 提交并推送
echo "提交更改..."
git add "$post_file"
git commit -m "发布文章: $title"

echo "推送到 GitHub..."
if git push origin main; then
    echo ""
    echo "🎉 发布成功!"
    echo "📦 CloudFlare Pages 正在自动构建..."
    echo "🌐 构建完成后访问: https://cyblog-b9j.pages.dev"
    echo ""
    echo "⏱️  查看构建状态: https://dash.cloudflare.com/"
else
    echo "❌ 推送失败，请检查错误信息"
    exit 1
fi