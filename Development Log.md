# Hexo 博客开发日志 v2.0

## 现有基础配置

### GitHub 配置
- **主仓库**: https://github.com/McHuashi9/CyBlog
- **SSH 状态**: ✅ 已配置
- **访问测试**: `ssh -T git@github.com` 返回成功

### SSH 安全验证记录
- **验证时间**: 2025-11-22
- **GitHub 服务器**: 20.205.243.166
- **ED25519 指纹**: SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU ✅ (官方指纹)
- **验证结果**: 成功添加到已知主机
- **安全状态**: ✅ 安全连接已建立

### Cloudflare Pages 配置  
- **域名**: https://cyblog-b9j.pages.dev
- **部署源**: GitHub 仓库连接
- **构建命令**: `hexo generate`
- **输出目录**: `public`


## v1.0 失败经验

- 1.要有（较）规范的开发日志
- 2.进行重要操作要上传备份，并做好清晰的描述

## 🎯 项目目标
- 纯净安装 Hexo
- 配置 butterfly 主题
- 正确配置数学公式渲染
- 完善自动化脚本
- 建立完整的文档体系

## 📅 时间线

### 2025-11-22: 创建项目
**目标**: 重新创建项目并完成基础配置
**步骤**:

1. 环境检查
```bash
node --version # v18.20.8
npm --version # 10.8.2
git --version # 2.43.0
```

2. 创建新项目目录
```bash
mkdir cyblog && cd cyblog
```

3. 初始化 Hexo 项目并安装核心依赖
```bash
npm install hexo@^6.0.0 --save
npm install hexo-server hexo-generator-index hexo-generator-archive hexo-generator-tag hexo-generator-category --save
```

4. 优先配置数学公式渲染
```bash
npm install hexo-renderer-markdown-it markdown-it-katex --save
```

5. 配置数学渲染，在 _config.yml 中添加了如下内容
```yaml
# Markdown 配置
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: true
    linkify: true
    typographer: true
    quotes: "「」『』"
  plugins:
    - markdown-it-katex

# 数学公式配置
katex:
  enable: true
  # 如果需要在所有页面加载 KaTeX CSS，设为 true
  every_page: false
```

6. 安装 Butterfly 主题
```bash
# 安全安装主题（避免子模块问题）
git clone https://github.com/jerryc127/hexo-theme-butterfly.git themes/butterfly --depth=1
# 安装主题依赖的渲染器
npm install hexo-renderer-pug hexo-renderer-stylus --save
```

**出现问题:**
- 安装时出现 EBADENGINE 警告
- Hexo 8.x 需要 Node.js >=20.19.0，但当前是 v18.20.8
- 1 high severity vulnerability （安全漏洞）

**解决方案:**
```bash
# 卸载当前安装的 Hexo 8.x
npm uninstall hexo
# 明确安装 Hexo 6.x (兼容 Node.js 18)
npm install hexo@6.3.0 --save
# 检查漏洞详情
npm audit
```

**漏洞详情:**
- Hexo 路径遍历漏洞 (GHSA-x2jc-989c-47q4)
- markdown-it-katex XSS 漏洞 (GHSA-5ff8-jcf9-fw62)

**解决方案:**
继续使用 markdown-it-katex
- 当前博客环境相对安全（静态内容，受控输入）
- 先确保功能正常，后续再考虑安全升级

**缓解措施:**
- 仅渲染信任来源的数学公式
- 避免在公式中使用可疑内容
- 记录此技术债务，未来考虑升级方案

7. 更换 butterfly 主题并在本地测试
编辑主配置文件 `_config`，更改以下配置：
```yaml
# 主题设置
theme: butterfly
```
```bash
# 彻底清理缓存和生成的文件
hexo c
# 重新生成
hexo g
# 启动服务器
hexo s
```
测试成功，已经成功切换为 butterfly 主题

8. 测试数学公式渲染
测试未成功，不能渲染出数学公式，但决定先放一放，到时候再解决

9. 配置基础站点信息
编辑 `_config.yml` 设置基础信息：
```yaml
# 站点基础配置
title: CY的个人博客
subtitle: ''
description: ''
keywords: ''
author: CY
language: zh-CN
timezone: 'Asia/Shanghai'

# URL (暂时用本地，部署时修改)
url: http://localhost:4000
```

10. 初始化 Git 并连接 GitHub

```bash
# 删除主题目录中的 .git 文件夹，使其变成普通目录
rm -rf themes/butterfly/.git
# 重新添加到 Git
git add themes/butterfly
# 初始化 Git
git init
# 添加所有文件
git add .
# 首次提交
git commit -m "feat: 初始化 Hexo v2.0 项目
- 纯净安装 Hexo 6.3.0
- 配置 Butterfly 主题
- 设置数学公式渲染
- 基础项目结构"
# 添加远程仓库
git remote add origin git@github.com:McHuashi9/CyBlog.git
# 强制推送覆盖远程仓库
git push --force origin main
```

11. CloudFlare 构建问题修复
**问题现象:**
CloudFlare Pages 构建失败，错误信息：
`fatal: No url found for submodule path 'themes/butterfly' in .gitmodules`

**问题原因：**
- 强制推送后，`themes/butterfly` 目录保留了自身的 `.git` 文件夹
- CloudFlare 误判为主题是 Git 子模块
- 但实际没有配置 `.gitmodules` 文件，导致构建失败

**解决方案：**
```bash
# 移除主题目录的 Git 信息
rm -rf themes/butterfly/.git
# 重新提交推送
git add . && git commit -m "fix: 移除butterfly主题的.git目录，修复CloudFlare子模块错误" && git push origin main
```