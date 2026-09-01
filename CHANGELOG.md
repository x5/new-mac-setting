# Changelog

All notable changes to this project are documented in this file.
本项目的所有重要变更都记录在此文件。

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/): new content → minor, fixes → patch, restructure → major.
格式遵循 Keep a Changelog，版本号遵循语义化版本：内容新增用 minor，修订与勘误用 patch，结构重构用 major。

## [3.1.0] - 2026-08-27

### Added / 新增

- **EN:** `setup.sh` — idempotent one-command installer covering Chapters 1–8 (defaults, Xcode CLT, Homebrew, Brewfile, shell/Ghostty config, mise runtimes, agent CLIs): `curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash`
- **中文：** 新增 `setup.sh` 幂等一键安装脚本，覆盖第 1-8 章全流程：`curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash`
- **EN:** `Brewfile` — full software manifest (formulae + casks, optional items commented).
- **中文：** 新增 `Brewfile` 完整软件清单（含注释掉的自选项）。
- **EN:** `llms.txt` — machine-readable summary for AI agents; "I'm an Agent / I'm a Human" entry blocks in README and on both HTML hero sections (with copy buttons).
- **中文：** 新增 `llms.txt`（Agent 机器可读摘要）；README 与两个 HTML 首页新增「我是 Agent / 我是人类」分流区块（带一键复制）。

### Changed / 变更

- **EN:** §13.3 now points to the real `setup.sh` instead of pseudo-code bootstrap.
- **中文：** §13.3 的 bootstrap 伪代码替换为真实的 `setup.sh`。

## [3.0.0] - 2026-08-27

### Changed / 变更

- **EN:** Full internationalization. English is now the default version: `mac-mini-ai-dev-setup.md` / `.html` are English; Chinese versions moved to `*.zh-CN.md` / `*.zh-CN.html`. Language cross-links on every page.
- **中文：** 全面国际化。英文成为默认版本：`mac-mini-ai-dev-setup.md` / `.html` 为英文；中文版移至 `*.zh-CN.md` / `*.zh-CN.html`。所有页面互挂语言切换链接。
- **EN:** AGENTS.md rewritten in full English, with the bilingual sync discipline (4 files per content change). README is now bilingual (English first, then 中文). CHANGELOG entries bilingual.
- **中文：** AGENTS.md 重写为全英文，含双语同步纪律（每次内容变更同步 4 个文件）。README 改为双语（先英后中）。CHANGELOG 双语条目。

### Breaking / 注意

- **EN:** File renames break old direct links to the Chinese MD/HTML files. The Pages URL now serves the English edition; Chinese edition at `mac-mini-ai-dev-setup.zh-CN.html`.
- **中文：** 文件重命名会影响旧的手册直链。Pages 默认地址现为英文版；中文版在 `mac-mini-ai-dev-setup.zh-CN.html`。

## [2.0.0] - 2026-08-27

### Changed / 变更

- **EN:** Rebrand: "Mac Mini × AI Agent" → "Mac × AI Agent" — the guide applies to all Apple Silicon Macs (MacBook / iMac / Mac Studio / Mac Mini). Hero screenshot and social preview regenerated.
- **中文：** 品牌更名：「Mac Mini × AI Agent」→「Mac × AI Agent」——手册适用于所有 Apple Silicon Mac。Hero 截图与社交分享图重制。

## [1.1.0] - 2026-08-27

### Added / 新增

- **EN:** Zhipu ZCode joins the agent fleet (now 7) with install & config notes (§8). Omarchy-inspired daily apps tier (§12): Chrome, Obsidian, Shottr, LocalSend, IINA, Tailscale. lazydocker (§10). LocalSend transfer option for Windows migration (§15). CHANGELOG.md + version badge.
- **中文：** 智谱 ZCode 加入 Agent 阵容（七件套），含安装与配置（§8）。参考 Omarchy 的效率应用第二梯队（§12）：Chrome、Obsidian、Shottr、LocalSend、IINA、Tailscale。容器章新增 lazydocker（§10）。Windows 迁移章新增 LocalSend 选项（§15）。CHANGELOG 上线、版本徽章进 README。

### Changed / 变更

- **EN:** Kimi Code install command switched to the official script.
- **中文：** Kimi Code 安装命令改为官网脚本。

## [1.0.0] - 2026-08-26

### Added / 新增

- **EN:** Initial release: 16-chapter manual, styled single-page HTML (dark terminal aesthetic, hover tooltips, one-click code copy), README, MIT License, GitHub Pages, 12 topics.
- **中文：** 初版发布：16 章完整手册、精美单页 HTML（深色终端美学 / 悬停术语 tooltip / 代码一键复制）、README、MIT License、GitHub Pages 在线版、12 个 topics。

[3.0.0]: https://github.com/x5/new-mac-setting/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/x5/new-mac-setting/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/x5/new-mac-setting/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/x5/new-mac-setting/releases/tag/v1.0.0
