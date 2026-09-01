# Mac × AI Agent 开发环境完全配置指南

> 🌐 English version: [mac-mini-ai-dev-setup.md](mac-mini-ai-dev-setup.md)

> 🤖 **给 AI Agent 用？** 把这句话发给它：`Read https://x5.github.io/new-mac-setting/mac-mini-ai-dev-setup.md and set up this Mac step by step. Prefer running setup.sh for the bulk install. Ask me before any irreversible action.`——或参阅 [llms.txt](https://x5.github.io/new-mac-setting/llms.txt)。
>
> ⚡ **一键安装**：`curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash`（幂等，逐步确认）

> 目标：在一台全新的 Apple Silicon Mac 上，搭建一套**面向 AI Agent 开发**的现代化、可复现、可配置的终极开发环境。适用于 MacBook Air/Pro、iMac、Mac Studio、Mac Mini——一切 Apple Silicon Mac。
>
> 原则：一切用代码声明（Brewfile / dotfiles / setup 脚本），换机 30 分钟内完整复原；终端优先（AI Agent 的主战场在终端）；多 Agent 并存（Claude Code / Kimi Code / Codex / DSH / PI / WorkBuddy / ZCode 各取所长）。

---

## 目录

1. [系统初始化（macOS 层）](#1-系统初始化macos-层)
2. [Homebrew：一切的地基](#2-homebrew一切的地基)
3. [终端与 Shell：Agent 的作战室](#3-终端与-shellagent-的作战室)
4. [运行时与版本管理：mise + uv](#4-运行时与版本管理mise--uv)
5. [Git 与 GitHub 工具链](#5-git-与-github-工具链)
6. [现代 CLI 工具箱（rust 系全家桶）](#6-现代-cli-工具箱)
7. [编辑器与 IDE](#7-编辑器与-ide)
8. [AI Agent 工具栈（核心章节）](#8-ai-agent-工具栈核心章节)
9. [MCP：给 Agent 装上"手"](#9-mcp给-agent-装上手)
10. [容器与本地服务](#10-容器与本地服务)
11. [密钥与安全管理](#11-密钥与安全管理)
12. [macOS 效率应用](#12-macos-效率应用)
13. [自动化：一键复原整个环境](#13-自动化一键复原整个环境)
14. [验收清单](#14-验收清单)
15. [附录：从 Windows 迁移](#15-附录从-windows-迁移到-mac)
16. [日常运维：装、删、改、更新的标准流程](#16-日常运维装删改更新的标准流程)

---

## 1. 系统初始化（macOS 层）

开机向导里注意：开启 **FileVault** 磁盘加密[^filevault]；Apple ID 登录后先别开 iCloud 桌面同步（会污染 `~/Desktop` 和 `~/Documents`）。

### 1.1 系统偏好调优（命令行声明式[^defaults]）

```bash
# 键盘：最快的按键重复与最短延迟（Agent 时代人也要敲得快）
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# 触控板：轻点即点击
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Finder：显示所有扩展名 + 状态栏 + 路径栏
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Dock：自动隐藏、关掉"最近使用"、缩到最小
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 42

# 截图统一存到 ~/Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

killall Finder Dock
```

### 1.2 必装前置[^clt]

```bash
# Xcode 命令行工具（git、clang 等编译链的前提）
xcode-select --install
```

> 如果你会用 Figma、设计软件或调试字体，再装 Rosetta[^rosetta]：`softwareupdate --install-rosetta --agree-to-license`。纯 AI/后端开发不需要。

---

## 2. Homebrew：一切的地基

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon 默认装在 /opt/homebrew，写入 PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update && brew doctor
```

**关键习惯：从此不用鼠标装任何开发软件，全部 `brew install` / `brew install --cask`**，并记录进 Brewfile（见第 13 章），这是"可复现"的核心。

---

## 3. 终端与 Shell：Agent 的作战室

AI Agent 时代，终端是第一界面。推荐组合：**Ghostty（终端）[^ghostty] + zsh[^zsh] + Starship（提示符）[^starship] + Nerd Font（图标字体）[^nerdfont]**。

```bash
# 终端三选一（Ghostty 是当下口碑最好的，GPU 渲染、原生快）
brew install --cask ghostty        # 推荐
brew install --cask wezterm        # 备选：Lua 可编程
brew install --cask iterm2         # 备选：老牌全能

# 字体（连字符 + 文件图标，Agent 输出显示必备）
brew install --cask font-jetbrains-mono-nerd-font

# Starship 提示符：一个 .toml 文件配置一切
brew install starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

Ghostty 配置（`~/.config/ghostty/config`）——最可配置的现代终端：

```ini
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = catppuccin-mocha
background-opacity = 0.96
window-padding-x = 12
window-padding-y = 10
copy-on-select = clipboard
```

可选增强（zsh 插件管理，保持轻量）：

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting
cat >> ~/.zshrc <<'EOF'
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
```

> **装机实战建议**：第一、二节（系统设置 + Homebrew）必须手工；从本节开始，可以先装一个 Kimi Code（`curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash`），把本文档丢给它，让 Agent 按章节替你执行和验证——这是这套环境的第一场实战。

---

## 4. 运行时与版本管理：mise + uv

**抛弃 nvm / pyenv / rbenv / sdkman**。2026 年的答案是：

- **mise**[^mise]：一个工具管理 Node / Python / Go / Java / 等所有运行时，按项目目录自动切换（`.mise.toml` 声明版本，团队共享）。
- **uv**[^uv]：Python 包与虚拟环境管理，比 pip 快 10-100 倍，AI 项目（Python 居多）的标配。

```bash
brew install mise uv
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# 全局默认运行时
mise use -g node@lts
mise use -g python@3.12
mise use -g go@latest

# 项目内固定版本（提交到 git，团队自动一致）
# mise use node@22 python@3.12   → 生成 .mise.toml
```

Python 项目工作流（AI 开发日常）：

```bash
uv init my-agent && cd my-agent
uv add openai anthropic          # 加依赖
uv run main.py                   # 跑脚本（自动用项目 venv）
uv run --with ruff ruff check .  # 临时工具，不污染环境
```

Node 侧建议再装 pnpm：`brew install pnpm`。

---

## 5. Git 与 GitHub 工具链

```bash
brew install git gh lazygit git-delta

# GitHub CLI 登录（浏览器授权，一次搞定 git push 认证）
gh auth login
```

三件套补充：**gh**[^gh] 是 GitHub 官方命令行；**lazygit**[^lazygit] 是 Git 的终端图形界面；**git-delta**[^delta] 是 diff 美化渲染器（下面配置里的 `pager = delta` 就是在启用它）。

`~/.gitconfig` 推荐配置：

```ini
[user]
    name = Your Name
    email = you@example.com
[init]
    defaultBranch = main
[core]
    editor = code --wait
    pager = delta                 # delta：语法高亮的 diff
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    line-numbers = true
[merge]
    conflictstyle = zdiff3
[pull]
    rebase = true
[alias]
    lg = log --graph --oneline --decorate --all
    st = status -sb
```

> **为什么强调 Git**：AI Agent 会大量、快速地改代码，Git 是你唯一的安全网。习惯：让 Agent 动手前先 `git commit`；用 `git worktree`[^worktree] 让多个 Agent 并行干不同的活而互不干扰。

---

## 6. 现代 CLI 工具箱

一套 rust/go 重写的现代替代品，Agent 的输出和人的体验都会变好。这些工具**全部跨平台**[^cross]：

```bash
brew install \
  ripgrep \      # rg：grep 的替代品，Agent 搜索全靠它
  fd \           # find 的替代品
  bat \          # cat 高亮版
  eza \          # ls 替代品（图标+树）
  fzf \          # 模糊搜索（Ctrl+R 历史搜索神器）
  zoxide \       # cd 智能跳转
  jq yq \        # JSON / YAML 处理
  sd \           # sed 替代品
  httpie \       # curl 友好版（API 调试）
  hyperfine \    # 命令耗时基准
  dust duf \     # du / df 替代品
  bottom \       # htop 替代品（btm）
  tlrc           # tldr 命令速查
```

`~/.zshrc` 收尾：

```bash
eval "$(zoxide init zsh)"
source <(fzf --zsh)
alias ls='eza --icons' ll='eza -l --icons' lt='eza --tree --icons'
alias cat='bat --style=plain'
```

### 6.1 逐个详解（都是"老命令的现代重写版"）

| 工具 | 替代谁 | 干什么 | 典型场景 |
|---|---|---|---|
| **ripgrep**（rg） | grep | 按**内容**搜整个代码库，快 10 倍+，自动跳过 `node_modules` 和 gitignore 文件 | "这个函数在哪被调用？" → `rg "getUserInfo"`。**Claude Code 等 Agent 搜索代码的底层引擎** |
| **fd** | find | 按**文件名**找文件，语法像人话 | `fd config` 对比老命令 `find . -name "*config*"` |
| **fzf** | — | 模糊搜索器 | `Ctrl+R` 搜历史命令：只记得三天前那条命令里有 "docker"，敲几个字母就捞回来 |
| **bat** | cat | 看文件，带语法高亮、行号、git 改动标记 | 终端里快速读代码 |
| **eza** | ls | 彩色 + 图标列目录，`lt` 树形展示 | 进陌生项目，`lt` 一眼看懂目录结构 |
| **tlrc**（tldr） | man | 命令速查手册 | `tldr tar` 直接给最常用的 5 个例子，不用啃 man |
| **zoxide** | cd | 会学习的目录跳转 | 记住你去过的目录，`z proj` 直接跳，不敲全路径 |
| **sd** | sed | 查找替换，语法即直觉 | `sd "旧文本" "新文本" 文件`，不记正则转义 |
| **hyperfine** | time | 命令计时基准 | `hyperfine '方案A' '方案B'` 各跑多次给平均耗时，对比谁快 |
| **jq / yq** | — | JSON / YAML 精确提取 | API 返回一大坨 JSON，`jq '.data[0].name'` 只取要的字段 |
| **httpie**（http） | curl | 人性化 API 调试 | `http POST api.x.com name=Tom`，自动 JSON、自动高亮 |
| **dust / duf** | du / df | 磁盘空间可视化 | dust 答"哪个目录最占地方"，duf 答"各磁盘用量"，图形化进度条 |
| **bottom**（btm） | htop | 系统监控 | CPU/内存/网络/进程一屏看全，Agent 满载跑任务时看它 |

---

## 7. 编辑器与 IDE

终端 Agent 是主力，但仍需要一个编辑器看 diff、做精细调整：

```bash
brew install --cask visual-studio-code   # 主力：生态最全，沿用既有习惯
brew install --cask zed                  # 备选：极速启动、内置 AI 面板
```

策略建议：**以 VS Code 为主力**（沿用已有使用习惯，插件生态最全），**Zed 作轻量备选**[^zed]（秒开大文件、快速编辑）。不装 Cursor：AI 编码主力已在终端 Agent（第 8 章六件套），编辑器里再叠一个 AI 订阅价值重叠。JetBrains 用户装 `toolbox` 即可。喜欢折腾可加 Neovim（`brew install neovim` + lazyvim），但非必需。

---

## 8. AI Agent 工具栈（核心章节）

2026 年的共识：**不押注单一 Agent，终端里多 Agent 并存，按任务选型**。本方案以七件套为核心阵容：

| Agent | 安装 | 定位 |
|---|---|---|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh \| bash` | 主力：综合能力最强，仓库理解、子 Agent、worktree、长任务 |
| **Kimi Code CLI** | `curl -fsSL https://code.kimi.com/kimi-code/install.sh \| bash` | 开源（MIT）、内置 coder/explore/plan 子 Agent、性价比高（亦可用 npm：`npm install -g @moonshot-ai/kimi-code`） |
| **Codex CLI** | `npm install -g @openai/codex` | 任务以 PR 形式交付，ChatGPT 订阅内含 |
| **DSH（DeepSeek Harness）** | `npx -y @deepseek-ai/dsh` | 插件化 Agent 运行时：模型/工具/子 Agent 皆为插件，可桥接其他 CLI |
| **PI（Pi Agent Harness）** | `npm install -g @earendil-works/pi-coding-agent` | 开源自我扩展 coding agent，pi-ai 统一多 provider LLM API |
| **WorkBuddy（腾讯）** | 官网下载桌面端 | 桌面 AI Agent 工作站：Coding Mode 写码 + Work Mode 办公，支持自定义模型 |
| **ZCode（智谱）** | [zcode.z.ai/cn](https://zcode.z.ai/cn) 下载 macOS 版 | 智谱桌面 ADE：Goal 长程任务、Bot 远程唤起、GLM-5.3 深度集成，可视化管理其他 CLI Agent |

### 8.1 阵容说明

- **DSH** 是 DeepSeek 的插件化 Agent 运行时（[deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)），理念是"一切皆插件"：模型、工具、子 Agent 自由拼装；早期为 Web/TUI 形态，配 [dshctl](https://github.com/deepseek-ai/deepseek-harness/discussions/2530) 可纯终端驱动，还有 bridge 插件（如 [dsh-codex-bridge](https://github.com/pandashere/dsh-codex-bridge)）把 Codex / Kimi 变成它的"第二意见"工具。
- **PI** 是 MIT 开源的 Agent Harness（[earendil-works/pi](https://github.com/earendil-works/pi)），`pi-ai` 统一 OpenAI/Anthropic/Google 等多家 API。注意：**PI 无内置权限系统**，默认继承启动用户的全部权限，敏感项目建议按其官方文档容器化运行（Docker / OpenShell）。
- **WorkBuddy** 是腾讯桌面 Agent 工作站（与 CodeBuddy 同族），Coding Mode 覆盖代码生成/审查/修复/全栈开发，Work Mode 处理办公任务，可通过本地模型配置接入 DeepSeek 等模型（[接入文档](https://api-docs.deepseek.com/quick_start/agent_integrations/workbuddy/)）。
- **ZCode** 是智谱的桌面 Agent 开发环境（ADE，[官网](https://zcode.z.ai/cn)）：下载 macOS 版 dmg 拖入 Applications 即可；**配置**：首次启动在欢迎页选「连接 BigModel」（国内，GLM Coding Plan 订阅）或「连接 Z.ai」（海外），之后在对话框点模型名 → 管理模型调整。特色：Goal 长程任务管理、Bot 远程唤起（微信 / 飞书 / Telegram）、GLM-5.3 深度集成（含 Flash 多模态）、可视化管理其他 CLI Agent。**联动提示**：GLM Coding Plan 一个订阅同时支持 Claude Code 等 20+ 工具——配合 8.2 的 cc-switch，国产模型一处付费多处用。

### 8.2 配套工具：cc-switch（Claude Code / Codex 的供应商总开关）

Claude Code 和 Codex 日常配合 **cc-switch**[^ccswitch] 使用：

```bash
brew tap farion1231/ccswitch
brew install --cask cc-switch
```

它把各家 API 供应商（官方、DeepSeek、GLM、第三方网关等）的 base URL / Key / 模型做成图形化预设，点一下即切换，不用手改 `settings.json`；新版本还集成了 MCP / Skills 管理。若 brew 安装报 macOS 版本兼容错误（已知问题），改从 [GitHub Releases](https://github.com/farion1231/cc-switch/releases) 下载 DMG 安装。

### 8.3 让 Agent 好用的三个配置习惯

1. **每个项目写 `AGENTS.md`**（Claude Code 用 `CLAUDE.md`，各 Agent 均认 AGENTS.md）：写明构建命令、代码规范、目录结构、禁区。Agent 的表现上限 = 你给它的上下文质量。
2. **配权限与钩子**：在各 Agent 的配置（如 `~/.claude/settings.json`、kimi 的 `config.toml`）里声明权限模式、危险命令拦截、提交规范，避免每次手动确认。
3. **API Key 集中管理**：见第 11 章，Key 绝不写进项目文件和 shell 历史。

### 8.4 多 Agent 并行工作流

```bash
# 用 git worktree 开隔离工作区，多个 Agent 并行不打架
git worktree add ../proj-feat-a feat-a
git worktree add ../proj-feat-b feat-b
# 窗口 1: cd ../proj-feat-a && claude
# 窗口 2: cd ../proj-feat-b && kimi
```

---

## 9. MCP：给 Agent 装上"手"

MCP（Model Context Protocol）[^mcp]让 Agent 接入外部工具。常用：

- **Playwright MCP** — 浏览器自动化，让 Agent 自己验证前端页面
- **Context7** — 实时拉取库的最新文档，消除"过时 API"幻觉
- **GitHub MCP** — Issue / PR 操作
- **Figma MCP** — 设计稿转代码

各 Agent 配置方式不同（Claude Code 用 `claude mcp add`，Kimi Code 用 `/mcp-config` 对话式配置），建议**只装当前项目真正用到的**，MCP 越多上下文越臃肿。

想**统一管理多个 Agent 的 MCP 配置**：你在用的 cc-switch 新版（v3.x）已内置 MCP 集中管理（一处配置、多处同步，兼管 Skills）；专门的 CLI 方案还有 **mcpm**[^mcpm]（`brew install mcpm`）。注意这类工具本质是"一处维护、多处同步"的翻译层——各家 Agent 的 MCP 配置格式尚未完全收敛，真正的单一配置源目前还不存在。

---

## 10. 容器与本地服务

**OrbStack**[^orbstack] 取代 Docker Desktop：macOS 上最快、最省电的 Docker / Linux 运行环境。数据库等一律容器化，不污染系统：

```bash
# OrbStack：macOS 上最快的 Docker/Linux 运行环境，取代 Docker Desktop
brew install --cask orbstack
brew install lazydocker   # 容器 TUI：lazygit 的 Docker 版，管理容器/镜像

# 数据库等一律容器化，不污染系统
# docker run -d --name pg -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres:17
# docker run -d --name redis -p 6379:6379 redis:7
```

---

## 11. 密钥与安全管理

```bash
# 免费路径（推荐先走这条）
brew install direnv age sops          # direnv 自动加载 .env；age/sops 加密敏感配置
# SSH 私钥用 macOS 原生钥匙串托管：
ssh-keygen -t ed25519 && ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# 可选付费：1Password（订阅制，约 $3/月）
brew install --cask 1password 1password-cli
```

- **SSH Key**：免费方案用 macOS 钥匙串托管（上面命令）；付费方案用 1Password 的 SSH Agent，私钥不落盘。
- **API Key**：项目内用 `.env` + **direnv**（进目录自动加载，`.env` 进 `.gitignore`）；跨项目可用 1Password CLI 注入（`op run --env-file=.env.tpl -- claude`）[^1p]。1Password 与钥匙串的组合用法见 [^combo]。
- **铁律**：Key 不进 git、不进 dotfiles 明文、不进 `~/.zshrc` 明文。

---

## 12. macOS 效率应用

第一梯队（核心效率）：

```bash
brew install --cask \
  raycast \          # 启动器（取代 Spotlight，剪贴板历史/窗口管理全包）
  rectangle \        # 窗口分屏快捷键（开源）
  alt-tab \          # Windows 式窗口切换
  stats \            # 菜单栏 CPU/内存/网速（跑 Agent 时看负载）
  karabiner-elements # 键盘改键（如 CapsLock → Esc/Ctrl）
```

第二梯队（日常增强，参考 Omarchy[^omarchy] 清单做的 macOS 映射）：

```bash
brew install --cask \
  google-chrome \    # 浏览器：前端调试基准
  obsidian \         # Markdown 笔记：纯 md 文件，Agent 也能直接读写你的知识库
  shottr \           # 截图标注：滚动截图/打码/量尺寸，免费
  localsend \        # 跨平台 AirDrop：Windows ↔ Mac 互传文件（见第 15 章）
  iina \             # 视频播放器：macOS 原生最强
  tailscale          # mesh VPN：Mac 常开当 home server，外网安全访问
```

- **Obsidian 的战略价值**：笔记存纯 `.md` 文件——你写的知识库，Agent 可以直接读、直接整理，这是 AI 时代笔记软件和普通文档的分水岭。
- **Tailscale 的场景**：Mac 常年开着，装好 Tailscale 后，你在公司/外面能安全 SSH 回家里这台机器，跑在上面的 Agent 任务随时接管。
- 按需自选：LibreOffice（办公套件）、Typora（Markdown 写作，$15 买断）、Spotify、Dropbox。

收费情况[^free-apps]：Rectangle、AltTab、Stats、Karabiner-Elements **全部免费开源**；Raycast 免费档已覆盖启动器/剪贴板/窗口管理核心功能，Pro（约 $8/月）主要买 AI 与云同步——AI 需求都在终端 Agent 上，免费档够用。第二梯队中 Chrome、Obsidian、LocalSend、IINA 免费，Shottr 免费（Pro 可选），Tailscale 个人免费档够用。

---

## 13. 自动化：一键复原整个环境

整套方案的灵魂：**软件清单、配置、运行时全部代码化**，存进 git 私有仓库。首次装机按第 1-12 章顺序执行，**本章在装机收尾时做一次**；回报在下一台机器——届时跳过前面全部章节，只跑 bootstrap 一条命令，30 分钟复原。

### 13.1 Brewfile（软件清单即代码）

安装完所有软件后导出：

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
# 新机器上一键装回：
brew bundle --file=~/dotfiles/Brewfile
```

### 13.2 dotfiles 管理

用 **chezmoi**[^chezmoi]（推荐，支持模板和加密）或 GNU stow，把 `~/.zshrc`、`~/.gitconfig`、`~/.config/ghostty/`、各 Agent 的配置全部纳入 git 私有仓库：

```bash
brew install chezmoi
chezmoi init --apply <你的dotfiles仓库>
```

### 13.3 setup.sh（新机器总入口）

本仓库内置了可直接使用的幂等安装脚本 [`setup.sh`](https://github.com/x5/new-mac-setting/blob/main/setup.sh)，覆盖第 1-8 章全流程（macOS 设置、Xcode CLT、Homebrew、完整 [Brewfile](https://github.com/x5/new-mac-setting/blob/main/Brewfile)、shell/Ghostty 配置、mise 运行时、Agent CLI）。新 Mac 上：

```bash
curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash
```

每一步执行前都会询问，已安装的内容自动跳过，可重复运行。要复原**你自己的**环境，再追加你的 dotfiles 仓库：

```bash
chezmoi init --apply <你的dotfiles仓库>
gh auth login
```

---

## 14. 验收清单

装完后逐项验证：

```bash
brew doctor && echo OK
git --version && gh auth status
mise ls                       # node/python/go 就位
uv --version
node -v && python3 -V
claude --version 2>/dev/null; kimi --version; codex --version; pi --version; npx -y @deepseek-ai/dsh --version
# 桌面端：ZCode / WorkBuddy 首次启动完成模型登录
docker run hello-world        # OrbStack
rg --version && fzf --version
ssh -T git@github.com         # SSH 认证
```

全部通过后，`brew bundle dump` + 提交 dotfiles —— 你的环境从此**可复现、可迁移、可演进**。

---

## 15. 附录：从 Windows 迁移到 Mac

总原则：**代码走 git，配置重建为主，依赖目录永不迁移。**

### 15.1 项目文件（Workspace）

- **git 是首选迁移工具**：能 push 的全部 push 到 GitHub，Mac 上 `git clone`——历史、分支、remote 全都在。
- 未入库的：Mac 打开「系统设置 → 通用 → 共享 → 远程登录」，在 Windows 的 Git Bash 里执行：

```bash
# Windows Git Bash → Mac（排除依赖目录，架构不同必须重装）
scp -r /c/Users/TUF/Workspace/<项目> user@<mac-ip>:~/Workspace/
```

- 最省事的小文件方案：**LocalSend**（第 12 章已装）——跨平台 AirDrop，同一局域网下 Windows 直接拖给 Mac，不用任何命令。
- 大文件兜底：exFAT 格式化的移动硬盘（两边原生读写）；或 Mac 开「文件共享」SMB，Windows 资源管理器访问 `\\<mac-ip>` 直接拖拽。
- **绝不迁**：`node_modules`、`.venv`、`target`、`__pycache__`、`dist`——x86 与 arm64 不通用，到 Mac 后 `mise install && uv sync / pnpm install` 重建。只迁源码 + `.git`。

### 15.2 配置文件（重建为主，少数可搬）

Windows 的 `%APPDATA%`、注册表配置不要直接搬，按第 13 章在 Mac 上重建 dotfiles。例外：

- **VS Code**：开 Settings Sync（GitHub 账号），Mac 登录自动同步全部设置 / 插件 / 快捷键。
- **各 Agent 配置**：`~/.claude/`、kimi 的 `config.toml` 等是 JSON/TOML，可直接复制到 Mac 的 `~/`，注意改掉里面的 Windows 路径字段。
- **SSH Key**：建议在 Mac 上重新生成（第 11 章），旧机器退役后吊销；API Key 趁迁移录入 1Password / Keychain。
- **浏览器**：书签密码走浏览器自带账号同步。

### 15.3 两台机器并行期（可选）

- 代码同步靠 git 本身：养成"换机器前 push"的习惯。
- 实时同步目录用 **Syncthing**（免费开源、点对点）：Workspace 双向同步，忽略规则排除依赖目录。
- 终态：Mac 主力、Windows 备用、git 为中心——最终不需要双向同步。

---

## 16. 日常运维：装、删、改、更新的标准流程

核心心智：**两层资产，各有一条纪律**——软件层对 Brewfile 负责，配置层对 chezmoi 负责。**不是每步都要跑 chezmoi**：配一个 `dotsync` 别名，把所有收尾动作打包成一条命令。

### 16.1 软件层：安装 / 删除 / 更新（对 Brewfile 负责）

```bash
brew install <tool>          # 装（cask 同理）
brew uninstall <tool>        # 删
brew autoremove              # 清掉不再被需要的依赖
brew cleanup                 # 清缓存

brew update && brew upgrade  # 更新全部 brew 软件
mise upgrade                 # 更新运行时（node / python / go）
# Agent CLI 各自升级：kimi upgrade / npm update -g @openai/codex ...

# 装 / 删后的收尾动作永远一样：重新导出清单
brew bundle dump --file=~/dotfiles/Brewfile --force
```

Brewfile 默认不记版本号，`brew upgrade` 后无需改清单，dump 一次保持整洁即可。

### 16.2 配置层：改 dotfiles（这才是 chezmoi 的活）

只有修改被纳管的文件（`.zshrc`、`.gitconfig`、Ghostty 配置、Agent 配置）才需要 chezmoi：

```bash
# 习惯：直接改源文件（如 ~/.zshrc），改完收进仓库
chezmoi re-add

# 新纳管一个文件
chezmoi add ~/.config/xxx
```

### 16.3 dotsync：一条命令完成全部收尾

建议让 chezmoi 源目录就用 `~/dotfiles`（`chezmoi init --source ~/dotfiles <仓库>`），Brewfile 也放里面。然后在 `~/.zshrc` 加：

```bash
dotsync() {
  brew bundle dump --file=~/dotfiles/Brewfile --force   # 软件清单
  chezmoi re-add                                        # 收纳配置变更
  git -C ~/dotfiles add -A
  git -C ~/dotfiles commit -m "chore: sync $(date +%F)"
  git -C ~/dotfiles push
}
```

**习惯：装 / 删 / 改完任何东西，跑一次 `dotsync`。**忘了跑也不会坏——只是下一台机器会少一点变化。

### 16.4 节奏建议

- **随手**：任何环境变更后 `dotsync`
- **每周或每月**：`brew update && brew upgrade && brew cleanup`、`mise upgrade`
- **懒人选项**：把维护流程写成 prompt 让 Agent 定期执行；或用 macOS launchd 定时跑 `brew upgrade`

---

*参考：[2026 Mac Setup for Web Development](https://www.robinwieruch.de/mac-setup-web-development/)、[Best AI Coding Agent Harness 2026](https://aitoolsrecap.com/Blog/best-ai-coding-agent-harness-2026)、[Kimi Code 安装指南](https://backgrind.com/blog/install-kimi-code/)*

---

## 名词注释

[^filevault]: **FileVault** 是 macOS 的全盘加密。Apple Silicon 的数据卷本就处于加密状态，FileVault 的作用是把解密钥匙绑定到你的登录密码上——不登录就无法读取任何数据。开发者的机器上有 SSH 私钥、API Key、各平台登录态，机器丢失或送修时这是唯一防线；硬件级加密，性能损耗几乎为零，建议必开。开启后务必保管好恢复密钥。

[^defaults]: `defaults write` 是 macOS 偏好设置的命令行接口，直接读写应用的 plist 配置。好处是可脚本化、可收进 dotfiles 仓库——新机器跑一次脚本全部生效，不用手点系统设置。

[^clt]: **Xcode Command Line Tools** 是苹果独立的命令行开发工具包（git、clang、make 等），不需要安装完整的 Xcode IDE。Homebrew 和几乎所有编译型工具都依赖它。

[^rosetta]: **Rosetta 2** 是苹果的 x86_64 翻译层，让只提供 Intel 版本的老软件能运行在 Apple Silicon 上。纯 AI / 后端开发基本用不到。

[^zsh]: **zsh 是一种 shell（命令行解释器）**——你在终端敲的每条命令都由 shell 解析后交给系统执行，AI Agent 执行的命令同样跑在 shell 里。macOS 从 2019 年起默认 shell 就是 zsh（之前是 bash），你的别名、PATH、插件、提示符全部配置在 `~/.zshrc`。注意区分四者分工：**Ghostty 是窗口（终端模拟器），zsh 是跑在窗口里的"语言"，Starship 只是提示符的外观，Nerd Font 负责图标显示**。

[^ghostty]: **Ghostty** 是终端模拟器，提供窗口、渲染与交互层。由 HashiCorp 创始人 Mitchell Hashimoto 开发，GPU 加速渲染、原生 macOS 体验，全部设置收在单个 `~/.config/ghostty/config` 文件里。

[^starship]: **Starship** 是跨 shell 的提示符（prompt）工具：把当前目录、git 分支、Node/Python 版本、上条命令耗时等信息渲染在提示符上。用一个 `starship.toml` 配置，换 shell 不用重配。

[^nerdfont]: **Nerd Font** 是在编程字体上追加数千个图标（文件类型、git、文件夹等）的补丁字体集。Starship、eza、lazygit 等工具输出的图标要靠它才能正常显示，否则全是问号方块。

[^mise]: **mise 是"编程语言版本的总管家"**。不同项目需要不同版本的运行时（老项目要 Node 18，新项目要 Node 22），以前每个语言要一个专属管理器（nvm 管 Node、pyenv 管 Python、rbenv 管 Ruby……），mise 一个工具全部取代。在项目里写 `.mise.toml` 声明版本，`cd` 进目录自动切换、离开恢复全局默认；文件提交到 git，团队版本自动一致。类比手机：mise 管"系统装哪个版本"，uv 管"装哪些 App"。

[^uv]: **uv 是 Python 的包管理器**（装 openai、anthropic 这类第三方库），Rust 编写，比官方 pip 快 10-100 倍。它自动为每个项目创建隔离的"虚拟环境"——各项目的库互不干扰，不会出现"升级一个库把另一个项目搞崩"的问题。`uv run` 跑脚本时自动使用项目环境，无需手动激活。

[^gh]: **gh 是 GitHub 官方 CLI**：在终端里完成 issue、PR、仓库管理等操作。`gh auth login` 一次登录后，`git push/pull` 的认证也一并搞定，不用再手动配 token。

[^lazygit]: **lazygit 是 Git 的终端图形界面（TUI）**：不用背命令，全键盘完成暂存、提交、分支、rebase、解决冲突。AI Agent 时代的利器——Agent 一次改了十几个文件，你在 lazygit 里逐个过 diff、分批提交，审查效率高一个量级。

[^delta]: **git-delta 是 git diff 的"美颜渲染器"**：默认 diff 只有白字 +- 号，delta 加上语法高亮、行号、并排对比。`.gitconfig` 里 `pager = delta` 启用后，`git diff`、`git log -p`、lazygit 里的变更视图全部生效。与 lazygit 的分工：lazygit 管"操作"，delta 管"显示"。

[^worktree]: **git worktree** 让同一个仓库同时检出多个分支到不同目录（如 `../proj-feat-a`、`../proj-feat-b`），各有独立工作区但共享同一个 `.git`。这是多 Agent 并行的基础：每个 Agent 一个 worktree，各改各的，互不踩踏。

[^cross]: **本章工具全部跨平台**（Rust/Go 编写），Windows 上可用 `winget` 或 `scoop` 安装同一批，命令完全一致。文档中真正 macOS 专有的是：Homebrew（Windows 用 winget/scoop）、Ghostty（无 Windows 版，用 Windows Terminal 或 WezTerm）、zsh（Windows 用 PowerShell 7 或 WSL）、Raycast/Rectangle/Karabiner（Windows 用 PowerToys）、OrbStack（Windows 用 Docker Desktop + WSL2）。mise、uv、Starship、lazygit、delta 及所有 AI Agent CLI 均跨平台。

[^zed]: **Zed 由 Zed Industries 开发**，创始人 Nathan Sobo 及核心团队是 GitHub Atom 编辑器的原班人马（他们还创造了如今几乎所有编辑器都在用的 Tree-sitter 语法解析引擎）。2022 年 Atom 停更后，团队用 Rust 从零重写 Zed：GPU 加速渲染、启动毫秒级、原生多人协作，2024 年初开源，内置 AI 面板与 Agent 模式。

[^ccswitch]: **cc-switch** 是开源跨平台桌面应用（Tauri + Rust，[farion1231/cc-switch](https://github.com/farion1231/cc-switch)），为 Claude Code、Codex、Gemini CLI、OpenCode 等工具统一管理多家 API 供应商：base URL、Key、模型存为图形化预设，一键切换。本质是把 `settings.json` 的手工修改图形化，切换国产模型 / 第三方网关时免去改配置、重启终端的麻烦。

[^mcp]: **MCP（Model Context Protocol）是 Agent 与外部工具之间的"标准化插座"**，Anthropic 于 2024 年底发起的开放协议，现已被各家 Agent 广泛支持。类比 USB-C：没有它之前，每个 Agent 接每个工具都要定制集成（N×M）；有了它，Agent 实现一次 MCP 客户端、工具方实现一次 MCP Server 即可互插（N+M）。Server 向 Agent 暴露三样东西：**tools**（可调用函数，日常 99% 的用途）、**resources**（数据）、**prompts**（提示词模板）。本地 Server 是 Agent 启动的子进程（stdio 通信），远程走 HTTP。

[^mcpm]: **mcpm（[mcpm.sh](https://mcpm.sh/)）是开源的 MCP 包管理器**：像 Homebrew 管软件一样管 MCP Server——中央注册表搜索安装、按 profile 分组启停（工作 / 个人环境一键切换）、一处配置同步到多个客户端，路由器还能把多个 Server 聚合成一个端点共享会话。注意：对 Claude Code 的原生支持有限，需手动接线。日常更省心的选择是 cc-switch 内置的 MCP 集中管理。

[^orbstack]: **OrbStack 是独立开发者 Danny Lin（kdrag0n）的作品**——一个人创办的公司，2023 年发布。他此前是 Android 定制内核圈知名开发者（Proton Kernel 作者），转战 macOS 后用 Swift / Rust 原生重写整套 Docker + Linux 虚拟化栈：启动秒级、空闲几乎零 CPU、续航消耗远低于 Docker Desktop。口碑来自"一个人打败了 Docker 官方产品"。个人使用免费，商用付费。

[^1p]: **1Password 是付费订阅制**（个人版约 $3/月按年付，无免费档，仅 14 天试用）。文档中它是可选项，免费替代路径完全够用：SSH 私钥用 macOS 原生钥匙串（`ssh-add --apple-use-keychain`）；密码管理用 Bitwarden（免费档，同样有 CLI 和 SSH Agent）；dotfiles 敏感配置用 age / sops 加密。1Password 的独特价值在 `op run` 运行时注入 API Key 和跨设备体验，需要时再上。

[^combo]: **1Password + Keychain 组合的分工**：系统层走 Keychain（SSH passphrase 开机解锁一次、整天无感；iCloud 钥匙串同步系统密码），应用层走 1Password（网站密码、API Key 存储与注入）。典型流程：项目里只放 `.env.tpl` 模板（`KEY=op://Dev/Anthropic/key` 引用，非明文），执行 `op run --env-file=.env.tpl -- claude` 时桌面端指纹授权一次，Key 只存在于进程环境变量。纪律：两者的 SSH Agent **只启用一个**（建议固定在 Keychain），否则 ssh 认证来源混乱。一句话：Keychain 管"系统自己要用的"，1Password 管"你和 Agent 要用的"。

[^free-apps]: **本章应用几乎全免费**：第一梯队中 Rectangle、AltTab、Stats、Karabiner-Elements 均为免费开源（Rectangle 另有个 $9.99 的 Pro 版，基础版够用）；Raycast 是免费 + Pro（约 $8/月）模式，免费档已覆盖核心。第二梯队中 Chrome、Obsidian、LocalSend、IINA 免费，Shottr 免费（Pro 可选），Tailscale 个人免费档够用。

[^omarchy]: **Omarchy** 是 DHH（Ruby on Rails 作者）主导的"满配"Linux 发行版（[omarchy.org](https://omarchy.org/manual/)），预装一整套精选开发/效率工具，2025 年很火。本章第二梯队参考其清单做了 macOS 映射；它清单中的 fzf、zoxide、ripgrep、eza、lazygit、Neovim/LazyVim、1Password 等本指南前面章节已覆盖。

[^chezmoi]: **chezmoi 是免费开源的 dotfiles 管理器**（Go 编写单文件程序，Tom Payne 2019 年发布，MPL-2.0 协议，目前该领域最主流）。它把散落各处的点文件收进一个 git 仓库，新机器 `chezmoi init --apply <仓库>` 一条命令全部还原。比手动建软链接强在两点：**模板**（同一仓库适配多台机器差异，如工作机 / 个人机用不同 git 邮箱）和**加密**（敏感配置用 age 加密后入库，私仓泄露也不慌）。
