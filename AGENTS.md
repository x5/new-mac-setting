# AGENTS.md

本文件是给所有 Agent / 维护者的项目操作手册。改动本仓库前必读。

## 项目概况

《Mac × AI Agent — 开发环境完全配置指南》。内容型仓库：一份 16 章的 macOS AI Agent 开发环境手册（适用所有 Apple Silicon Mac），以 MD 和 HTML 双形态发布，GitHub Pages 自动部署。

## 文件结构与职责

```
mac-mini-ai-dev-setup.md    # 内容源头（single source of truth），16 章 + 文末名词脚注区
mac-mini-ai-dev-setup.html  # 同内容的精美单页版（深色终端美学），必须与 MD 同步
README.md                   # 仓库门面：徽章、章节导航表、Agent 阵容表、技术栈速览
CHANGELOG.md                # Keep a Changelog 格式，每个版本记录变更
docs/                       # README 截图（hero/agents/tooltip）、social-preview、readme-standard.md
```

## 变更同步清单（核心纪律）

**任何内容改动，按此清单逐项检查，缺一不可：**

1. **先改 MD**（内容源头）
2. **同步 HTML** 对应章节：导语 `p.lead`、终端卡片 `.term`、工具卡 `.tool`、Agent 卡 `.agent`、提示块 `.note`、规则列表 `.rule`
3. **检查 README** 是否需要同步：
   - 章节导航表（章节标题/要点变化）
   - AI Agent 阵容表（Agent 增删）
   - 技术栈速览代码块
   - 徽章（如 Agent 数量变化）
4. **CHANGELOG.md 加条目**：按 Added / Changed / Fixed 分类，写日期
5. **发 Release**：内容新增 → minor，修订勘误 → patch，结构重构 → major
   `gh release create vX.Y.Z --title "..." --notes "..."`
6. **验证 Pages 部署**（push 后自动触发，无需手动）：
   `gh api repos/x5/new-mac-setting/pages/builds/latest --jq '{status, commit: .commit[0:7]}'`

## 机制与约定

### MD 脚注

- 术语解释用脚注：`[^name]` 引用，定义集中在文末「名词注释」区
- 脚注可含链接；内容 = 通俗解释 + 背景 + 注意事项

### HTML tooltip

- 行内术语：`<span class="tip">术语<span class="tip-bubble"><b>标题</b>解释</span></span>`
- 工具卡片：`.tool` 内直接加 `<span class="tip-bubble">`（CSS 已支持 `.tool:hover` 触发）
- **禁止把 tooltip 放进 `.term` 代码卡内**（`overflow:hidden` 会裁切气泡）

### HTML 新章节

- 结构：`section#sNN` + `.sec-head`（`.sec-no` 大号描边数字 + `.sec-title` 含 `.tag` 和 `h2`）+ 内容块
- 左侧导航 `#nav` 里同步加 `<a href="#sNN">`
- 内容块统一带 `reveal` class（入场动画）
- 终端卡片代码高亮：注释 `.c`、提示符 `.p`、字符串 `.s`

### 验证

- 每次 HTML 改动后用 Playwright 截图复验（`uv run --with playwright`，viewport 1440×900，截图文件不入库）
-  tooltip 要悬停验证一次（CSS 选择器曾踩过坑）

### 提交与发布

- 提交信息：英文 Conventional Commits（`docs: ...`），单一目的
- 内容中文，代码/命令/标识符保持原文
- 推送后 Pages 自动构建，构建完成即上线

### 版本号规则

- minor：新增工具、新增章节、新增内容
- patch：勘误、命令修正、措辞优化
- major：章节结构重构、方向性调整

## 相关文档

- 发布方法论：[docs/readme-standard.md](docs/readme-standard.md)
- 版本历史：[CHANGELOG.md](CHANGELOG.md)
