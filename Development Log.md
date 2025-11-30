# Hexo + NexT 主题开发日志

## 现有基础配置

### GitHub 配置
- **主仓库：** https://github.com/McHuashi9/CyBlog
- **SSH 状态：** ✅ 已配置
- **访问测试：** `ssh -T git@github.com` 返回成功

### SSH 安全验证记录
- **验证时间：** 2025-11-22
- **GitHub 服务器：** 20.205.243.166
- **ED25519 指纹：** SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU ✅ (官方指纹)
- **验证结果：** 成功添加到已知主机
- **安全状态：** ✅ 安全连接已建立

### Cloudflare Pages 配置  
- **域名：** https://cyblog-b9j.pages.dev
- **部署源：** GitHub 仓库连接
- **构建命令：** `hexo generate`
- **输出目录：** `public`

## 🎯 项目目标
- 使用 NexT 主题建立稳定的博客环境
- 确保数学公式渲染正常工作
- 建立完整的自动化部署流程

## 📅 时间线

### 2025-11-30: 项目初始化
**决策原因**: 放弃 Butterfly 主题，选择对数学公式支持更好的 NexT 主题

**环境状态**:
- Node.js: v18.20.8
- Hexo: 6.3.0
- 主题: NexT (通过 npm 安装)

**步骤**:

1. 环境检查
```bash
node --version # v20.19.0
npm --version # 10.8.2
git --version # 2.43.0
```

2. 安装 next 主题
```bash
mkdir Cyblog
cd Cyblog/
hexo init .
nvm install 20.19.0
nvm use 20.19.0
rm -rf node_modules
npm install
npm install hexo-theme-next
```

3. 修改Hexo 的主配置文件 `_config.yml`

设置主题为 next ：

```yaml
theme: next
```

设置标题、语言、时区等：

```yaml
title: CY的个人博客
subtitle: '记录生活'
description: '存我的笔记'
keywords: '笔记, 日常'
author: ChenYou
language: zh-CN
timezone: Asia/Shanghai
```

4. 创建 NexT 主题配置文件并编辑

```bash
# 从主题目录复制默认配置到根目录
cp node_modules/hexo-theme-next/_config.yml _config.next.yml
```

编辑这个新创建的配置文件的 `math` 部分，修改为：

```yaml
math:
  # Default (false) will load mathjax / katex script on demand.
  # That is it only render those page which has `mathjax: true` in front-matter.
  # If you set it to true, it will load mathjax / katex script EVERY PAGE.
  every_page: true

  mathjax:
    enable: false
    # Available values: none | ams | all
    tags: none

  katex:
    enable: true
    # See: https://github.com/KaTeX/KaTeX/tree/master/contrib/copy-tex
    copy_tex:
      enable: true
```

5. 更换 Markdown 渲染器

安装支持数学公式的 Markdown 渲染器：

```bash
npm uninstall hexo-renderer-marked --save
npm install hexo-renderer-pandoc --save
# 卸载 pandoc 渲染器
npm uninstall hexo-renderer-pandoc --save
# 安装 kramed 渲染器（专门处理数学公式）
npm install hexo-renderer-kramed --save
```

在 `_config.yml` 文件末尾添加以下配置：

```yaml
kramed:
  enable: true
  blocks:
    math: true
  inlineMath:
    - ["$", "$"]
    - ["\\(", "\\)"]
  blockMath:
    - ["$$", "$$"]
    - ["\\[", "\\]"]
```

编辑 _config.next.yml 切换回 MathJax ：

```yaml
math:
  # Default (false) will load mathjax / katex script on demand.
  # That is it only render those page which has `mathjax: true` in front-matter.
  # If you set it to true, it will load mathjax / katex script EVERY PAGE.
  every_page: true

  mathjax:
    enable: true
    # Available values: none | ams | all
    tags: none

  katex:
    enable: false
    # See: https://github.com/KaTeX/KaTeX/tree/master/contrib/copy-tex
    copy_tex:
      enable: true
```
