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
- Node.js: v20.19.0 (从 v18.20.8 升级)
- Hexo: 8.1.1
- 主题: NexT (通过 npm 安装)

**步骤**:

1. 环境检查与升级
```bash
node --version # v20.19.0
npm --version # 10.8.2
git --version # 2.43.0

# 解决 Node.js 版本兼容性问题
nvm install 20.19.0
nvm use --delete-prefix v20.19.0
```

2. 项目初始化与主题安装
```bash
mkdir Cyblog
cd Cyblog/
hexo init .
npm install
npm install hexo-theme-next
```

3. 基础配置
- 修改 `_config.yml` 设置主题为 next
- 配置站点基本信息：标题、语言、时区等

4. 数学公式功能配置
- 创建 NexT 主题配置文件 `_config.next.yml`
- 初始尝试使用 KaTeX，但渲染失败
- 更换多种 Markdown 渲染器：
  - 尝试 hexo-renderer-pandoc（需要系统依赖，失败）
  - 最终使用 hexo-renderer-kramed（成功）
- 配置 kramed 渲染器支持数学公式语法
- 最终切换回 MathJax，行内公式渲染成功

5. 版本控制与部署
- 初始化 Git 仓库并连接到远程仓库
- 解决合并冲突（配置文件、依赖版本）
- 成功推送到 GitHub 并触发 Cloudflare Pages 自动部署

6. 依赖兼容性问题解决
- 遇到 ESM 模块兼容性错误（ERR_REQUIRE_ESM）
- 通过清理缓存和重新安装依赖解决问题：
```bash
npm cache clean --force
rm -rf node_modules
npm install
```

**技术决策记录**:
- 选择 MathJax 而非 KaTeX：虽然 KaTeX 性能更好，但 MathJax 在当前环境下兼容性更佳
- 使用 hexo-renderer-kramed：专门优化数学公式渲染的 Markdown 解析器
- 启用全局数学公式渲染：简化文章 Front-matter 配置
- 锁定依赖版本：避免未来出现类似的 ESM 兼容性问题

**关键配置**:
```yaml
# _config.next.yml 数学公式配置
math:
  every_page: true
  mathjax:
    enable: true
    tags: none
  katex:
    enable: false
```
