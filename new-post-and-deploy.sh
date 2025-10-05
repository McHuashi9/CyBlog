#!/bin/bash

# 简单发布脚本 - 无颜色代码
set -e

title="$1"

if [ -z "$title" ]; then
    read -p "文章标题: " title
fi

echo "创建新文章..."
hexo new "$title"

echo ""
echo "请编辑文章，完成后按回车继续..."
read -p "按回车继续发布..."

echo "提交到 Git..."
git add .
git commit -m "发布: $title - $(date +'%Y-%m-%d %H:%M:%S')" || echo "备注: 无新更改"

echo "推送到 GitHub..."
git push origin main

echo ""
echo "完成！博客地址: https://cyblog-b9j.pages.dev"
echo "CloudFlare 构建中..."