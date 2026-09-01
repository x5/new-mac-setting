# Changelog

本项目的所有重要变更都记录在此文件。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)：内容新增用 minor，修订与勘误用 patch，结构重构用 major。

## [2.0.0] - 2026-08-27

### 变更

- **品牌更名**：「Mac Mini × AI Agent」→「Mac × AI Agent」——手册内容本就适用于所有 Apple Silicon Mac（MacBook / iMac / Mac Studio / Mac Mini），标题与正文同步调整，并明确标注适用范围
- README / HTML / AGENTS.md 全部同步更名，Hero 截图与社交分享图重制

## [1.1.0] - 2026-08-27

### 新增

- **AI Agent 阵容扩展为七件套**：新增智谱 ZCode（桌面 ADE，Goal 长程任务 / Bot 远程唤起 / GLM-5.3 深度集成），含安装与配置说明（§8）
- **效率应用第二梯队**：参考 [Omarchy](https://omarchy.org/manual/) 清单的 macOS 映射——Chrome、Obsidian、Shottr、LocalSend、IINA、Tailscale（§12）
- 容器章新增 **lazydocker**（容器 TUI，§10）
- Windows 迁移章新增 **LocalSend** 传输选项（§15）
- README 头版新增 GitHub Pages 在线阅读入口（徽章 + 醒目链接）
- 新增 `docs/readme-standard.md`：GitHub 发布标准 SOP
- 新增社交分享图 `docs/social-preview.png`（1280×640）

### 变更

- Kimi Code 安装命令改为官网脚本（`code.kimi.com/kimi-code/install.sh`），npm 作为备选
- 验收清单补充桌面端 Agent（ZCode / WorkBuddy）的登录验证步骤

## [1.0.0] - 2026-08-26

### 新增

- 初版发布：16 章完整手册（`mac-mini-ai-dev-setup.md`）
  - 初始化（§1-2）、终端与 Shell（§3）、运行时 mise+uv（§4）、Git 工具链（§5）
  - 现代 CLI 工具箱（§6）、编辑器（§7）、AI Agent 六件套 + cc-switch（§8）、MCP（§9）
  - 容器 OrbStack（§10）、密钥安全（§11）、效率应用（§12）
  - 一键复原 Brewfile + chezmoi + bootstrap（§13）、验收清单（§14）
  - Windows 迁移附录（§15）、日常运维 dotsync（§16）
- 同内容精美单页 HTML（`mac-mini-ai-dev-setup.html`）：深色终端美学、章节导航、悬停术语 tooltip、代码一键复制
- README、MIT License、GitHub Pages 在线版、12 个 topics

[1.1.0]: https://github.com/x5/new-mac-setting/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/x5/new-mac-setting/releases/tag/v1.0.0
