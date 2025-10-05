#!/bin/bash

if [ -z "$1" ]; then
    echo "使用方法: ./delete-post.sh \"文章标题\""
    echo ""
    echo "现有文章:"
    ls source/_posts/ | head -10
    exit 1
fi

# 查找并删除文件
POST_FILE=$(find source/_posts -name "*$1*.md" | head -1)

if [ -z "$POST_FILE" ]; then
    echo "❌ 找不到包含 '$1' 的文章"
    echo ""
    echo "现有文章:"
    ls source/_posts/
    exit 1
fi

echo "🗑️  准备删除文章: $POST_FILE"
echo "文章内容预览:"
head -10 "$POST_FILE"

read -p "确认删除吗？(y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm "$POST_FILE"
    echo "✅ 已删除文章"
    
    # 提交更改
    git add .
    git commit -m "删除文章: $1"
    git push origin main
    
    echo "🚀 更改已推送到 GitHub，CloudFlare 将自动更新"
else
    echo "❌ 取消删除"
fi