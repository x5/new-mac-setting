<div align="center">

# 🖥️ Mac Mini × AI Agent — 开发环境完全配置指南

**The Ultimate macOS Setup for AI-Agent-Driven Development (2026)**

在一台全新的 Apple Silicon Mac Mini 上，搭建面向 AI Agent 开发的<br>
现代化、可复现、可配置的终极开发环境

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-Brewfile-FBB040?logo=homebrew&logoColor=white)](https://brew.sh/)
[![dotfiles](https://img.shields.io/badge/dotfiles-chezmoi-4B6EAF)](https://www.chezmoi.io/)
[![AI Agents](https://img.shields.io/badge/AI%20Agents-6%20CLIs-c8f24e)](https://github.com/x5/new-mac-setting)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](https://github.com/x5/new-mac-setting/pulls)

[English keywords](#-seo-keywords) · [完整手册](mac-mini-ai-dev-setup.md) · [精美单页版](mac-mini-ai-dev-setup.html) · [参考链接](#-参考)

</div>

---

![Hero](docs/hero.png)

## ✨ 这是什么

一份 2026 年视角的 Mac 开发环境搭建手册，覆盖一台新 Mac Mini 从开箱到长期运维的**完整生命周期**：

```
初始化 (§1-12)  →  资产化 (§13)  →  验收 (§14)  →  旧机迁移 (§15)  →  日常运维 (§16)
```

三条核心原则：

- 📜 **一切用代码声明** —— Brewfile + dotfiles + bootstrap 脚本，换机 30 分钟完整复原
- ⌨️ **终端优先** —— AI Agent 的主战场在终端：Ghostty + zsh + Starship + Nerd Font
- 🤖 **多 Agent 并存** —— Claude Code / Kimi Code / Codex / DSH / PI / WorkBuddy 六件套，按任务选型，配合 cc-switch 统一切换供应商

## 📖 内容形态

| 文件 | 说明 |
|---|---|
| 📄 [`mac-mini-ai-dev-setup.md`](mac-mini-ai-dev-setup.md) | 完整手册。16 章 + 名词脚注，可直接按章节执行 |
| 🎨 [`mac-mini-ai-dev-setup.html`](mac-mini-ai-dev-setup.html) | 同内容的单页精美版：深色终端美学、章节导航、悬停术语 tooltip、代码一键复制，浏览器直接打开 |

| Agent 工具栈 | 悬停术语解释 |
|---|---|
| ![Agents](docs/agents.png) | ![Tooltip](docs/tooltip.png) |

## 🗺️ 章节导航

| # | 章节 | 要点 |
|---|---|---|
| 01 | 🍎 系统初始化 | FileVault、defaults write、Xcode CLT |
| 02 | 🍺 Homebrew 地基 | 一切安装走 brew，拒绝鼠标装软件 |
| 03 | 💻 终端与 Shell | Ghostty + zsh + Starship + Nerd Font |
| 04 | 🔄 运行时管理 | mise（替代 nvm/pyenv 全家）+ uv |
| 05 | 🌿 Git 工具链 | gh、lazygit、git-delta、worktree |
| 06 | 🧰 现代 CLI 工具箱 | ripgrep / fd / bat / eza / fzf / zoxide 等 13 件，全跨平台 |
| 07 | 📝 编辑器与 IDE | VS Code 主力 + Zed 备选 |
| 08 | 🤖 AI Agent 工具栈 | 六件套 + cc-switch 供应商总开关 |
| 09 | 🔌 MCP 扩展 | Playwright / Context7 / GitHub / Figma，按需安装 |
| 10 | 🐳 容器与本地服务 | OrbStack 取代 Docker Desktop |
| 11 | 🔐 密钥与安全 | 免费路径优先：Keychain + direnv + age/sops，1Password 可选 |
| 12 | ⚡ 效率应用 | Raycast / Rectangle / AltTab / Stats / Karabiner（几乎全部免费） |
| 13 | 📦 一键复原自动化 | Brewfile + chezmoi + bootstrap.sh |
| 14 | ✅ 验收清单 | 逐条命令验证 |
| 15 | 🪟 附录：Windows 迁移 | 代码走 git、配置重建、依赖目录永不迁移 |
| 16 | 🔁 日常运维 | 装/删/改/更新的标准流程，dotsync 一键收尾 |

## 🚀 使用路径

- **🆕 装机当天**：按 §1 → §12 顺序执行（§1-2 必须手工；从 §3 起可以先装一个 Kimi Code，把手册丢给 Agent 替你执行和验证）。收尾做 §13，跑 §14 验收
- **🪟 从 Windows 迁移**：读 §15 —— git 优先、scp 兜底、`node_modules` 等依赖目录绝不迁移
- **🔁 日常运维**：读 §16 —— 任何环境变更后跑一次 `dotsync`（导出 Brewfile + 收纳配置 + 提交推送）
- **💻 换下一台机器**：只跑一条 `bootstrap.sh`

## 🤖 AI Agent 阵容

| Agent | 定位 |
|---|---|
| **Claude Code** | 主力：长任务、子 Agent、worktree 并行 |
| **Kimi Code CLI** | 开源（MIT），内置 coder / explore / plan 子 Agent |
| **Codex CLI** | 任务以 PR 形式交付 |
| **DSH（DeepSeek Harness）** | 插件化 Agent 运行时，一切皆插件 |
| **PI（Pi Agent Harness）** | 开源自我扩展，统一多 provider API |
| **WorkBuddy（腾讯）** | 桌面工作站：Coding Mode + 办公场景 |

配套：[cc-switch](https://github.com/farion1231/cc-switch) 统一管理各家 API 供应商，一键切换。

## 🧱 核心技术栈速览

```
Terminal   Ghostty · zsh · Starship · JetBrainsMono Nerd Font
Runtimes   mise (node/python/go) · uv · pnpm
CLI        ripgrep · fd · bat · eza · fzf · zoxide · jq/yq · httpie · bottom
Git        gh · lazygit · git-delta · worktree
AI Agents  Claude Code · Kimi Code · Codex · DSH · PI · WorkBuddy · cc-switch
Infra      OrbStack (Docker) · Syncthing
Config     Homebrew Brewfile · chezmoi · bootstrap.sh · dotsync
```

## 📚 参考

- [2026 Mac Setup for Web Development — Robin Wieruch](https://www.robinwieruch.de/mac-setup-web-development/)
- [Best AI Coding Agent Harness 2026](https://aitoolsrecap.com/Blog/best-ai-coding-agent-harness-2026)
- [Kimi Code 官方文档](https://www.kimi.com/code/docs/)
- [cc-switch](https://github.com/farion1231/cc-switch) · [mcpm](https://mcpm.sh/) · [chezmoi](https://www.chezmoi.io/) · [OrbStack](https://orbstack.dev/)
- 📐 [GitHub 发布标准（SOP）](docs/readme-standard.md) —— 本仓库 README / topics / 设置的提炼方法论

## 🔎 SEO Keywords

macOS setup, Mac Mini developer environment, AI coding agents, Claude Code, Kimi Code, Codex CLI, DeepSeek Harness, dotfiles, chezmoi, Homebrew Brewfile, Ghostty terminal, mise, uv, OrbStack, 开发环境配置, 苹果电脑开发环境, AI 编程工具

## 📄 License

[MIT](LICENSE) © 2026 x5 — 随意取用，欢迎 Star ⭐ 与 PR。
