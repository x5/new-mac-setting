# Mac × AI Agent — The Complete Development Environment Setup Guide

> 🇨🇳 中文版：[mac-mini-ai-dev-setup.zh-CN.md](mac-mini-ai-dev-setup.zh-CN.md)

> 🤖 **Using an AI agent?** Send it this prompt: `Read https://x5.github.io/new-mac-setting/mac-mini-ai-dev-setup.md and set up this Mac step by step. Prefer running setup.sh for the bulk install. Ask me before any irreversible action.` — or see [llms.txt](https://x5.github.io/new-mac-setting/llms.txt).
>
> ⚡ **One-command setup**: `curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash` (idempotent, step-by-step interactive)

> Goal: on a brand-new Apple Silicon Mac, build a modern, reproducible, fully declarative development environment **purpose-built for AI Agent development**. Works on MacBook Air/Pro, iMac, Mac Studio, Mac Mini — every Apple Silicon Mac.
>
> Principles: everything declared as code (Brewfile / dotfiles / setup scripts) so a new machine is fully restored within 30 minutes; terminal-first (the terminal is where AI Agents live); multiple Agents side by side (Claude Code / Kimi Code / Codex / DSH / PI / WorkBuddy / ZCode, each for what it does best).

---

## Table of Contents

1. [System Initialization (macOS Layer)](#1-system-initialization-macos-layer)
2. [Homebrew: The Foundation of Everything](#2-homebrew-the-foundation-of-everything)
3. [Terminal & Shell: The Agent's War Room](#3-terminal--shell-the-agents-war-room)
4. [Runtimes & Version Management: mise + uv](#4-runtimes--version-management-mise--uv)
5. [Git & GitHub Toolchain](#5-git--github-toolchain)
6. [The Modern CLI Toolbox](#6-the-modern-cli-toolbox-rust-based-replacements)
7. [Editors & IDEs](#7-editors--ides)
8. [The AI Agent Toolchain (Core Chapter)](#8-the-ai-agent-toolchain-core-chapter)
9. [MCP: Giving Agents "Hands"](#9-mcp-giving-agents-hands)
10. [Containers & Local Services](#10-containers--local-services)
11. [Secrets & Security Management](#11-secrets--security-management)
12. [macOS Productivity Apps](#12-macos-productivity-apps)
13. [Automation: Restore the Entire Environment with One Command](#13-automation-restore-the-entire-environment-with-one-command)
14. [Acceptance Checklist](#14-acceptance-checklist)
15. [Appendix: Migrating from Windows to Mac](#15-appendix-migrating-from-windows-to-mac)
16. [Daily Operations: The Standard Install/Remove/Change/Update Workflow](#16-daily-operations-the-standard-installremovechangeupdate-workflow)

---

## 1. System Initialization (macOS Layer)

During the first-boot setup assistant: enable **FileVault** disk encryption[^filevault]; after signing in with your Apple ID, don't turn on iCloud Desktop & Documents sync yet (it pollutes `~/Desktop` and `~/Documents`).

### 1.1 System Preferences Tuning (Declarative, via the Command Line[^defaults])

```bash
# Keyboard: fastest key repeat and shortest delay (humans need to type fast in the Agent era too)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Trackpad: tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Finder: show all extensions + status bar + path bar
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Dock: auto-hide, disable "recent apps", shrink to minimum
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 42

# Save all screenshots to ~/Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

killall Finder Dock
```

### 1.2 Mandatory Prerequisites[^clt]

```bash
# Xcode Command Line Tools (prerequisite for git, clang, and the whole compile toolchain)
xcode-select --install
```

> If you use Figma, design software, or need to debug fonts, also install Rosetta[^rosetta]: `softwareupdate --install-rosetta --agree-to-license`. Pure AI/backend development doesn't need it.

---

## 2. Homebrew: The Foundation of Everything

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# On Apple Silicon it installs to /opt/homebrew by default; add it to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update && brew doctor
```

**Key habit: from now on, never install any development software with a mouse — everything goes through `brew install` / `brew install --cask`**, and gets recorded in the Brewfile (see Chapter 13). This is the core of "reproducible".

---

## 3. Terminal & Shell: The Agent's War Room

In the AI Agent era, the terminal is the primary interface. Recommended combo: **Ghostty (terminal)[^ghostty] + zsh[^zsh] + Starship (prompt)[^starship] + Nerd Font (icon font)[^nerdfont]**.

```bash
# Pick one of three terminals (Ghostty has the best reputation right now: GPU-rendered, natively fast)
brew install --cask ghostty        # recommended
brew install --cask wezterm        # alternative: programmable in Lua
brew install --cask iterm2         # alternative: the veteran all-rounder

# Font (ligatures + file icons — required for rendering Agent output properly)
brew install --cask font-jetbrains-mono-nerd-font

# Starship prompt: one .toml file configures everything
brew install starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

Ghostty config (`~/.config/ghostty/config`) — the most configurable modern terminal:

```ini
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = catppuccin-mocha
background-opacity = 0.96
window-padding-x = 12
window-padding-y = 10
copy-on-select = clipboard
```

Optional enhancements (zsh plugin management, kept lightweight):

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting
cat >> ~/.zshrc <<'EOF'
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
```

> **Hands-on tip**: Sections 1 and 2 (system settings + Homebrew) must be done by hand; from this section on, you can install Kimi Code first (`curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash`), hand it this document, and let the Agent execute and verify chapter by chapter for you — that's this environment's first real-world battle.

---

## 4. Runtimes & Version Management: mise + uv

**Ditch nvm / pyenv / rbenv / sdkman**. The 2026 answer is:

- **mise**[^mise]: one tool to manage Node / Python / Go / Java / every runtime, with automatic per-project switching (`.mise.toml` declares versions, shared with the team).
- **uv**[^uv]: Python package and virtual environment management, 10–100× faster than pip; the standard for AI projects (which are mostly Python).

```bash
brew install mise uv
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Global default runtimes
mise use -g node@lts
mise use -g python@3.12
mise use -g go@latest

# Pin versions inside a project (commit to git; the team stays in sync automatically)
# mise use node@22 python@3.12   → generates .mise.toml
```

Python project workflow (daily AI development):

```bash
uv init my-agent && cd my-agent
uv add openai anthropic          # add dependencies
uv run main.py                   # run a script (automatically uses the project venv)
uv run --with ruff ruff check .  # ad-hoc tool, doesn't pollute the environment
```

On the Node side, also install pnpm: `brew install pnpm`.

---

## 5. Git & GitHub Toolchain

```bash
brew install git gh lazygit git-delta

# GitHub CLI login (browser-based authorization; handles git push authentication in one go)
gh auth login
```

The supporting trio: **gh**[^gh] is GitHub's official CLI; **lazygit**[^lazygit] is a terminal UI for Git; **git-delta**[^delta] is a diff beautifier (the `pager = delta` line in the config below is what enables it).

Recommended `~/.gitconfig`:

```ini
[user]
    name = Your Name
    email = you@example.com
[init]
    defaultBranch = main
[core]
    editor = code --wait
    pager = delta                 # delta: syntax-highlighted diffs
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

> **Why the emphasis on Git**: AI Agents change code fast and in bulk — Git is your only safety net. Habits: `git commit` before letting an Agent loose; use `git worktree`[^worktree] so multiple Agents can work in parallel on different tasks without stepping on each other.

---

## 6. The Modern CLI Toolbox (Rust-Based Replacements)

A set of modern rewrites in Rust/Go — better output for Agents and a better experience for humans. These tools are **all cross-platform**[^cross]:

```bash
brew install \
  ripgrep \      # rg: grep replacement; Agents rely on it for search
  fd \           # find replacement
  bat \          # cat with highlighting
  eza \          # ls replacement (icons + tree)
  fzf \          # fuzzy finder (Ctrl+R history search magic)
  zoxide \       # smarter cd
  jq yq \        # JSON / YAML processing
  sd \           # sed replacement
  httpie \       # friendlier curl (API debugging)
  hyperfine \    # command benchmarking
  dust duf \     # du / df replacements
  bottom \       # htop replacement (btm)
  tlrc           # tldr command cheat sheets
```

Finishing touches in `~/.zshrc`:

```bash
eval "$(zoxide init zsh)"
source <(fzf --zsh)
alias ls='eza --icons' ll='eza -l --icons' lt='eza --tree --icons'
alias cat='bat --style=plain'
```

### 6.1 One by One (All "Modern Rewrites of Classic Commands")

| Tool | Replaces | What it does | Typical scenario |
|---|---|---|---|
| **ripgrep** (rg) | grep | Searches an entire codebase by **content**, 10×+ faster, automatically skips `node_modules` and gitignored files | "Where is this function called?" → `rg "getUserInfo"`. **The underlying search engine for Agents like Claude Code** |
| **fd** | find | Finds files by **name**, with human-readable syntax | `fd config` vs. the old `find . -name "*config*"` |
| **fzf** | — | Fuzzy finder | `Ctrl+R` to search command history: you only remember a command from three days ago had "docker" in it — type a few letters and it's back |
| **bat** | cat | View files with syntax highlighting, line numbers, and git change markers | Quick code reading in the terminal |
| **eza** | ls | Colored + icon directory listing, `lt` for tree view | Entering an unfamiliar project, `lt` shows the directory structure at a glance |
| **tlrc** (tldr) | man | Command cheat sheets | `tldr tar` gives you the 5 most common examples — no man-page spelunking |
| **zoxide** | cd | Directory jumping that learns | Remembers directories you've visited; `z proj` jumps straight there without typing the full path |
| **sd** | sed | Find & replace with intuitive syntax | `sd "old text" "new text" file` — no regex escaping to memorize |
| **hyperfine** | time | Command benchmarking | `hyperfine 'approach A' 'approach B'` runs each multiple times and reports averages, so you can compare which is faster |
| **jq / yq** | — | Precise JSON / YAML extraction | An API returns a huge blob of JSON; `jq '.data[0].name'` pulls out just the field you want |
| **httpie** (http) | curl | Human-friendly API debugging | `http POST api.x.com name=Tom` — automatic JSON, automatic highlighting |
| **dust / duf** | du / df | Disk usage visualization | dust answers "which directory eats the most space", duf answers "how is each disk used", with graphical progress bars |
| **bottom** (btm) | htop | System monitoring | CPU/memory/network/processes on one screen — watch it while Agents run at full throttle |

---

## 7. Editors & IDEs

Terminal Agents are the main force, but you still need an editor for reviewing diffs and making fine adjustments:

```bash
brew install --cask visual-studio-code   # primary: the fullest ecosystem, stick with existing habits
brew install --cask zed                  # alternative: instant startup, built-in AI panel
```

Suggested strategy: **VS Code as the primary** (keep your existing habits, fullest plugin ecosystem), **Zed as a lightweight alternative**[^zed] (opens huge files in a blink, quick edits). Skip Cursor: your AI coding power already lives in the terminal Agents (the seven-agent lineup in Chapter 8) — stacking another AI subscription in the editor is overlapping value. JetBrains users just install `toolbox`. Tinkerers can add Neovim (`brew install neovim` + lazyvim), but it's not required.

---

## 8. The AI Agent Toolchain (Core Chapter)

The 2026 consensus: **don't bet on a single Agent — run multiple Agents side by side in the terminal and pick per task**. This setup centers on a seven-agent lineup:

| Agent | Install | Role |
|---|---|---|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh \| bash` | Primary: strongest overall capability — repo understanding, sub-agents, worktrees, long tasks |
| **Kimi Code CLI** | `curl -fsSL https://code.kimi.com/kimi-code/install.sh \| bash` | Open source (MIT), built-in coder/explore/plan sub-agents, great value (also via npm: `npm install -g @moonshot-ai/kimi-code`) |
| **Codex CLI** | `npm install -g @openai/codex` | Delivers tasks as PRs; included with a ChatGPT subscription |
| **DSH (DeepSeek Harness)** | `npx -y @deepseek-ai/dsh` | Plugin-based Agent runtime: models/tools/sub-agents are all plugins; can bridge other CLIs |
| **PI (Pi Agent Harness)** | `npm install -g @earendil-works/pi-coding-agent` | Open-source self-extending coding agent; pi-ai unifies multi-provider LLM APIs |
| **WorkBuddy (Tencent)** | Download the desktop app from the official site | Desktop AI Agent workstation: Coding Mode for code + Work Mode for office tasks, supports custom models |
| **ZCode (Zhipu)** | Download the macOS build at [zcode.z.ai/cn](https://zcode.z.ai/cn) | Zhipu's desktop ADE: Goal long-horizon tasks, Bot remote invocation, deep GLM-5.3 integration, visual management of other CLI Agents |

### 8.1 About the Lineup

- **DSH** is DeepSeek's plugin-based Agent runtime ([deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)); its philosophy is "everything is a plugin": models, tools, and sub-agents are freely composable. Early builds ship as Web/TUI; with [dshctl](https://github.com/deepseek-ai/deepseek-harness/discussions/2530) you can drive it purely from the terminal, and bridge plugins (e.g. [dsh-codex-bridge](https://github.com/pandashere/dsh-codex-bridge)) turn Codex / Kimi into its "second opinion" tools.
- **PI** is an MIT-licensed open-source Agent Harness ([earendil-works/pi](https://github.com/earendil-works/pi)); `pi-ai` unifies APIs from OpenAI/Anthropic/Google and others. Note: **PI has no built-in permission system** — by default it inherits all permissions of the launching user; for sensitive projects, run it containerized per its official docs (Docker / OpenShell).
- **WorkBuddy** is Tencent's desktop Agent workstation (same family as CodeBuddy): Coding Mode covers code generation/review/fixing/full-stack development, Work Mode handles office tasks, and it can plug into models like DeepSeek via local model configuration ([integration docs](https://api-docs.deepseek.com/quick_start/agent_integrations/workbuddy/)).
- **ZCode** is Zhipu's desktop Agent Development Environment (ADE, [official site](https://zcode.z.ai/cn)): download the macOS dmg and drag it into Applications. **Setup**: on first launch, choose "Connect BigModel" (China, GLM Coding Plan subscription) or "Connect Z.ai" (international) on the welcome page; afterwards click the model name in the dialog → Manage Models to adjust. Highlights: Goal long-horizon task management, Bot remote invocation (WeChat / Feishu / Telegram), deep GLM-5.3 integration (including Flash multimodal), and visual management of other CLI Agents. **Synergy tip**: one GLM Coding Plan subscription powers 20+ tools including Claude Code — combined with cc-switch in 8.2, you pay once for Chinese models and use them everywhere.

### 8.2 Companion Tool: cc-switch (The Provider Master Switch for Claude Code / Codex)

Claude Code and Codex pair daily with **cc-switch**[^ccswitch]:

```bash
brew tap farion1231/ccswitch
brew install --cask cc-switch
```

It turns each API provider's base URL / Key / model (official, DeepSeek, GLM, third-party gateways, etc.) into graphical presets — one click to switch, no hand-editing `settings.json`. Newer versions also integrate MCP / Skills management. If the brew install fails with a macOS version compatibility error (a known issue), download the DMG from [GitHub Releases](https://github.com/farion1231/cc-switch/releases) instead.

### 8.3 Three Configuration Habits That Make Agents Effective

1. **Write an `AGENTS.md` for every project** (Claude Code uses `CLAUDE.md`; all Agents recognize AGENTS.md): document build commands, coding conventions, directory structure, and no-go zones. An Agent's performance ceiling = the quality of context you give it.
2. **Configure permissions and hooks**: in each Agent's config (e.g. `~/.claude/settings.json`, Kimi's `config.toml`), declare permission modes, dangerous-command interception, and commit conventions, so you're not manually confirming every step.
3. **Centralize API key management**: see Chapter 11. Keys never go into project files or shell history.

### 8.4 Multi-Agent Parallel Workflow

```bash
# Use git worktree to create isolated workspaces so multiple Agents run in parallel without conflicts
git worktree add ../proj-feat-a feat-a
git worktree add ../proj-feat-b feat-b
# Window 1: cd ../proj-feat-a && claude
# Window 2: cd ../proj-feat-b && kimi
```

### 8.5 herdr: The Agent Runtime (Where Agents Live)

The fleet from 8.1 needs somewhere to live. **herdr**[^herdr] is an agent runtime: a background server that holds real terminal sessions for your coding agents. Agents keep running when the lid closes, the network drops, or the machine reboots — and you reattach from any device. It reads every pane and marks each agent working / blocked / idle, so the parallel workflow from 8.4 stops being a pile of terminal windows. Its CLI and socket API are one surface: agents can drive it themselves — split panes, start each other, prompt each other, wait on each other. It detects 21 agent CLIs out of the box (Claude Code, Codex, PI, opencode, Cursor, Grok, Copilot…) and ships as a single binary for macOS / Linux / Windows. Think of it as the agent-native successor to tmux: the runtime layer the fleet lives on.

```bash
# Preferred: Homebrew — updates ride along with brew upgrade
brew install herdr

# Alternative: mise (on old mise, fall back to: mise use -g github:herdrdev/herdr)
mise use -g herdr

# Direct installer — only direct installs use `herdr update` / `herdr channel set preview`
curl -fsSL https://herdr.dev/install.sh | sh
```

Caveat: herdr is a young (YC-backed) project — stay on the stable channel and prefer the brew-managed install so updates come through `brew upgrade`.

---

## 9. MCP: Giving Agents "Hands"

MCP (Model Context Protocol)[^mcp] lets Agents plug into external tools. Commonly used:

- **Playwright MCP** — browser automation, so Agents can verify frontend pages themselves
- **Context7** — pulls up-to-date library docs in real time, eliminating "stale API" hallucinations
- **GitHub MCP** — Issue / PR operations
- **Figma MCP** — design-to-code

Each Agent configures MCP differently (Claude Code uses `claude mcp add`; Kimi Code uses the conversational `/mcp-config`). Recommended: **only install what the current project actually uses** — the more MCP servers, the more bloated the context.

If you want to **manage MCP config for multiple Agents in one place**: the newer cc-switch (v3.x) you're already using has centralized MCP management built in (configure once, sync everywhere; it also manages Skills). A dedicated CLI option is **mcpm**[^mcpm] (`brew install mcpm`). Note that tools like this are essentially a "maintain once, sync everywhere" translation layer — the Agents' MCP config formats haven't fully converged, and a true single source of config doesn't exist yet.

---

## 10. Containers & Local Services

**OrbStack**[^orbstack] replaces Docker Desktop: the fastest, most power-efficient Docker / Linux runtime on macOS. Databases and the like all run in containers — keep the system clean:

```bash
# OrbStack: the fastest Docker/Linux runtime on macOS, replaces Docker Desktop
brew install --cask orbstack
brew install lazydocker   # container TUI: lazygit for Docker; manage containers/images

# Databases etc. all run containerized, never polluting the system
# docker run -d --name pg -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres:17
# docker run -d --name redis -p 6379:6379 redis:7
```

---

## 11. Secrets & Security Management

```bash
# Free path (recommended first)
brew install direnv age sops          # direnv auto-loads .env; age/sops encrypt sensitive config
# SSH private keys managed by the native macOS Keychain:
ssh-keygen -t ed25519 && ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Optional paid: 1Password (subscription, ~$3/month)
brew install --cask 1password 1password-cli
```

- **SSH keys**: the free option is the macOS Keychain (command above); the paid option is 1Password's SSH Agent, where private keys never touch disk.
- **API keys**: per-project, use `.env` + **direnv** (auto-loads on entering the directory; `.env` goes in `.gitignore`); cross-project, inject via 1Password CLI (`op run --env-file=.env.tpl -- claude`)[^1p]. For how to combine 1Password with the Keychain, see [^combo].
- **Iron rules**: keys never enter git, never sit in dotfiles as plaintext, never sit in `~/.zshrc` as plaintext.

---

## 12. macOS Productivity Apps

First tier (core productivity):

```bash
brew install --cask \
  raycast \          # launcher (replaces Spotlight; clipboard history / window management included)
  rectangle \        # window snapping shortcuts (open source)
  alt-tab \          # Windows-style window switching
  stats \            # menu-bar CPU/memory/network (watch the load while Agents run)
  karabiner-elements # keyboard remapping (e.g. CapsLock → Esc/Ctrl)
```

Second tier (daily enhancements; a macOS mapping inspired by the Omarchy[^omarchy] list):

```bash
brew install --cask \
  google-chrome \    # browser: the baseline for frontend debugging
  obsidian \         # Markdown notes: plain .md files, so Agents can read/write your knowledge base directly
  shottr \           # screenshot annotation: scrolling captures / redaction / measurements, free
  localsend \        # cross-platform AirDrop: Windows ↔ Mac file transfer (see Chapter 15)
  iina \             # video player: the best native one on macOS
  tailscale          # mesh VPN: keep your Mac always-on as a home server, securely reachable from outside
```

- **Obsidian's strategic value**: notes are stored as plain `.md` files — Agents can directly read and organize the knowledge base you write. That's the dividing line between note-taking software in the AI era and ordinary documents.
- **The Tailscale scenario**: your Mac stays on year-round; with Tailscale installed, you can securely SSH back into this machine from the office or anywhere else, and take over Agent tasks running on it at any time.
- **Pick as needed**: LibreOffice (office suite), Typora (Markdown writing, $15 one-time), Spotify, Dropbox.

Pricing[^free-apps]: Rectangle, AltTab, Stats, Karabiner-Elements are **all free and open source**; Raycast's free tier already covers the core launcher/clipboard/window-management features, and Pro (~$8/month) mainly buys AI and cloud sync — your AI needs live in the terminal Agents, so the free tier is enough. In the second tier, Chrome, Obsidian, LocalSend, and IINA are free; Shottr is free (Pro optional); Tailscale's free personal tier is sufficient.

---

## 13. Automation: Restore the Entire Environment with One Command

The soul of this whole setup: **software inventory, configuration, and runtimes all expressed as code**, stored in a private git repo. For the first install, follow Chapters 1–12 in order; **run this chapter once at the end of that initial setup**. The payoff comes with your next machine — then you skip every earlier chapter and just run the single bootstrap command: full restore in 30 minutes.

### 13.1 Brewfile (Software Inventory as Code)

After installing all software, export:

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
# On a new machine, reinstall everything with one command:
brew bundle --file=~/dotfiles/Brewfile
```

### 13.2 Dotfiles Management

Use **chezmoi**[^chezmoi] (recommended — supports templates and encryption) or GNU stow, and bring `~/.zshrc`, `~/.gitconfig`, `~/.config/ghostty/`, and every Agent's config into a private git repo:

```bash
brew install chezmoi
chezmoi init --apply <your-dotfiles-repo>
```

### 13.3 setup.sh (The Entry Point for a New Machine)

This repository ships a ready-to-use, idempotent installer — [`setup.sh`](https://github.com/x5/new-mac-setting/blob/main/setup.sh) — covering Chapters 1–8 end to end (macOS defaults, Xcode CLT, Homebrew, the full [Brewfile](https://github.com/x5/new-mac-setting/blob/main/Brewfile), shell/Ghostty config, mise runtimes, agent CLIs). On a fresh Mac:

```bash
curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash
```

Each step asks before running and skips whatever is already installed, so it is safe to re-run. For your *own* environment restore, extend it with your dotfiles repo:

```bash
chezmoi init --apply <your-dotfiles-repo>
gh auth login
```

---

## 14. Acceptance Checklist

After installation, verify item by item:

```bash
brew doctor && echo OK
git --version && gh auth status
mise ls                       # node/python/go in place
uv --version
node -v && python3 -V
claude --version 2>/dev/null; kimi --version; codex --version; pi --version; npx -y @deepseek-ai/dsh --version
# Desktop apps: ZCode / WorkBuddy — finish model sign-in on first launch
docker run hello-world        # OrbStack
rg --version && fzf --version
ssh -T git@github.com         # SSH authentication
```

Once everything passes, `brew bundle dump` + commit your dotfiles — your environment is now **reproducible, migratable, and evolvable**.

---

## 15. Appendix: Migrating from Windows to Mac

The overarching principle: **code travels via git, configuration is rebuilt, dependency directories are never migrated.**

### 15.1 Project Files (Workspace)

- **Git is the migration tool of choice**: push everything that can be pushed to GitHub, then `git clone` on the Mac — history, branches, and remotes all come along.
- For things not in git: on the Mac, enable "System Settings → General → Sharing → Remote Login", then in Git Bash on Windows run:

```bash
# Windows Git Bash → Mac (exclude dependency directories — they must be rebuilt for a different architecture)
scp -r /c/Users/TUF/Workspace/<project> user@<mac-ip>:~/Workspace/
```

- The easiest option for small files: **LocalSend** (installed in Chapter 12) — a cross-platform AirDrop; on the same LAN, drag files straight from Windows to the Mac, no commands needed.
- Fallback for large files: an exFAT-formatted external drive (natively read/write on both sides); or enable "File Sharing" (SMB) on the Mac and access `\\<mac-ip>` from Windows Explorer to drag and drop.
- **Never migrate**: `node_modules`, `.venv`, `target`, `__pycache__`, `dist` — x86 and arm64 binaries are incompatible; rebuild on the Mac with `mise install && uv sync / pnpm install`. Migrate only source code + `.git`.

### 15.2 Configuration Files (Rebuild by Default; a Few Can Move)

Don't carry over Windows `%APPDATA%` or registry settings; rebuild dotfiles on the Mac per Chapter 13. Exceptions:

- **VS Code**: turn on Settings Sync (GitHub account); sign in on the Mac and all settings / extensions / keybindings sync automatically.
- **Agent configs**: `~/.claude/`, Kimi's `config.toml`, etc. are JSON/TOML and can be copied directly to the Mac's `~/`; just fix any Windows path fields inside them.
- **SSH keys**: regenerate them on the Mac (Chapter 11) and revoke the old ones once the old machine retires; take the migration as an opportunity to record API keys into 1Password / Keychain.
- **Browsers**: bookmarks and passwords sync via the browser's built-in account sync.

### 15.3 Running Both Machines in Parallel (Optional)

- Code syncs via git itself: build the habit of "push before switching machines".
- For real-time directory sync, use **Syncthing** (free, open source, peer-to-peer): bidirectional sync of Workspace, with ignore rules excluding dependency directories.
- End state: Mac as the primary, Windows as backup, git at the center — eventually you won't need bidirectional sync at all.

---

## 16. Daily Operations: The Standard Install/Remove/Change/Update Workflow

Core mental model: **two layers of assets, each with its own discipline** — the software layer answers to the Brewfile, the configuration layer answers to chezmoi. **You don't run chezmoi at every step**: set up a `dotsync` alias that packs all the wrap-up actions into one command.

### 16.1 Software Layer: Install / Remove / Update (Answers to the Brewfile)

```bash
brew install <tool>          # install (same for casks)
brew uninstall <tool>        # remove
brew autoremove              # clean up dependencies no longer needed
brew cleanup                 # clear caches

brew update && brew upgrade  # update all brew software
mise upgrade                 # update runtimes (node / python / go)
# Agent CLIs upgrade individually: kimi upgrade / npm update -g @openai/codex ...

# The wrap-up after installing / removing is always the same: re-export the inventory
brew bundle dump --file=~/dotfiles/Brewfile --force
```

The Brewfile doesn't record version numbers by default, so after `brew upgrade` there's no need to edit the inventory — just dump once to keep it tidy.

### 16.2 Configuration Layer: Changing Dotfiles (This Is chezmoi's Job)

chezmoi is only needed when you modify managed files (`.zshrc`, `.gitconfig`, Ghostty config, Agent configs):

```bash
# Habit: edit the live file directly (e.g. ~/.zshrc), then absorb it into the repo
chezmoi re-add

# Bring a new file under management
chezmoi add ~/.config/xxx
```

### 16.3 dotsync: One Command for All Wrap-Up

Recommended: make the chezmoi source directory simply `~/dotfiles` (`chezmoi init --source ~/dotfiles <repo>`), and keep the Brewfile in there too. Then add to `~/.zshrc`:

```bash
dotsync() {
  brew bundle dump --file=~/dotfiles/Brewfile --force   # software inventory
  chezmoi re-add                                        # absorb config changes
  git -C ~/dotfiles add -A
  git -C ~/dotfiles commit -m "chore: sync $(date +%F)"
  git -C ~/dotfiles push
}
```

**Habit: after installing / removing / changing anything, run `dotsync` once.** Forgetting won't break anything — the next machine will just be missing a few changes.

### 16.4 Suggested Cadence

- **Whenever**: `dotsync` after any environment change
- **Weekly or monthly**: `brew update && brew upgrade && brew cleanup`, `mise upgrade`
- **Lazy option**: write the maintenance routine as a prompt and have an Agent run it periodically; or use macOS launchd to run `brew upgrade` on a schedule

---

*References: [2026 Mac Setup for Web Development](https://www.robinwieruch.de/mac-setup-web-development/), [Best AI Coding Agent Harness 2026](https://aitoolsrecap.com/Blog/best-ai-coding-agent-harness-2026), [Kimi Code Installation Guide](https://backgrind.com/blog/install-kimi-code/)*

---

## Glossary

[^filevault]: **FileVault** is macOS full-disk encryption. On Apple Silicon the data volume is always encrypted; FileVault ties the decryption key to your login password — without logging in, nobody can read anything. A developer's machine holds SSH private keys, API keys, and login sessions for everything; this is your last line of defense if the machine is lost or serviced. Hardware-accelerated encryption means near-zero performance cost — just turn it on, and keep the recovery key safe.

[^defaults]: `defaults write` is the command-line interface to macOS preferences, reading and writing apps' plist configs directly. The win: scriptable and dotfiles-friendly — run the script once on a new machine and every preference lands, no clicking through System Settings.

[^clt]: **Xcode Command Line Tools** is Apple's standalone command-line developer package (git, clang, make, etc.) — no full Xcode IDE required. Homebrew and virtually every compiler toolchain depend on it.

[^rosetta]: **Rosetta 2** is Apple's x86_64 translation layer, letting Intel-only apps run on Apple Silicon. Pure AI / backend development rarely needs it.

[^zsh]: **zsh is a shell (command interpreter)** — every command you type in a terminal is parsed by the shell and handed to the OS, and the same goes for commands an AI agent executes. zsh has been the macOS default since 2019 (previously bash); your aliases, PATH, plugins, and prompt all live in `~/.zshrc`. Know the division of labor: **Ghostty is the window (terminal emulator), zsh is the language running inside it, Starship is just the prompt's appearance, Nerd Font renders the icons**.

[^ghostty]: **Ghostty** is a terminal emulator — it provides the window, rendering, and interaction layer. Built by Mitchell Hashimoto (HashiCorp founder): GPU-accelerated rendering, native macOS feel, everything configured in a single `~/.config/ghostty/config` file.

[^starship]: **Starship** is a cross-shell prompt: it renders the current directory, git branch, Node/Python versions, last command duration, and more into your prompt. One `starship.toml` configures everything; switch shells without reconfiguring.

[^nerdfont]: **Nerd Font** is a patch set that adds thousands of icons (file types, git, folders…) onto programming fonts. Starship, eza, lazygit and friends need one installed or their icons render as boxes and question marks.

[^mise]: **mise is the version manager for all your language runtimes**. Different projects need different runtime versions (an old project wants Node 18, a new one Node 22); previously each language had its own manager (nvm for Node, pyenv for Python, rbenv for Ruby…) — mise replaces them all. Declare versions in a project's `.mise.toml`, and `cd` into the directory auto-switches; commit the file to git and the whole team stays in sync. Phone analogy: mise manages "which OS version is installed", uv manages "which apps".

[^uv]: **uv is a Python package manager** (installs third-party libraries like openai, anthropic), written in Rust, 10–100× faster than pip. It automatically creates an isolated virtual environment per project so dependencies never collide; `uv run` executes scripts inside the project environment with no manual activation.

[^gh]: **gh is GitHub's official CLI**: issues, PRs, and repo management from the terminal. One `gh auth login` also covers `git push/pull` authentication — no manual token setup.

[^lazygit]: **lazygit is a terminal UI for Git (TUI)**: stage, commit, branch, rebase, and resolve conflicts with the keyboard, no command memorization. A killer tool in the agent era — after an agent edits a dozen files, you review diff by diff in lazygit and commit in batches.

[^delta]: **git-delta is a renderer for git diff**: stock diff is plain text with +/- signs; delta adds syntax highlighting, line numbers, and side-by-side view. Enabled by `pager = delta` in `.gitconfig`, it improves `git diff`, `git log -p`, and lazygit's diff views all at once. Division of labor: lazygit is for *doing*, delta is for *seeing*.

[^worktree]: **git worktree** checks out multiple branches of the same repo into separate directories (e.g. `../proj-feat-a`, `../proj-feat-b`) — independent working trees sharing one `.git`. This is the foundation of multi-agent parallelism: one worktree per agent, no stepping on each other.

[^cross]: **Every tool in this chapter is cross-platform** (written in Rust/Go); on Windows install the same set via `winget` or `scoop` with identical commands. The genuinely macOS-only items in this guide: Homebrew (Windows: winget/scoop), Ghostty (no Windows build — use Windows Terminal or WezTerm), zsh (Windows: PowerShell 7 or WSL), the Raycast-family productivity apps (Windows: PowerToys), and OrbStack (Windows: Docker Desktop + WSL2). mise, uv, Starship, lazygit, delta, and all AI agent CLIs are cross-platform.

[^zed]: **Zed is built by Zed Industries** — founder Nathan Sobo and team are the original GitHub Atom crew (they also created Tree-sitter, the syntax engine now used by nearly every editor). After Atom was sunset in 2022 they rewrote everything from scratch in Rust: GPU-accelerated rendering, millisecond startup, native multiplayer — open-sourced in early 2024, with a built-in AI panel and agent mode.

[^ccswitch]: **cc-switch** is an open-source cross-platform desktop app (Tauri + Rust, [farion1231/cc-switch](https://github.com/farion1231/cc-switch)) that manages multiple API providers for Claude Code, Codex, Gemini CLI, OpenCode and friends: base URLs, keys, and models saved as GUI presets, switched with one click. It essentially turns hand-editing `settings.json` into a point-and-click affair — no more restarting terminals to swap providers or gateways.

[^mcp]: **MCP (Model Context Protocol) is the standardized socket between agents and external tools** — an open protocol initiated by Anthropic in late 2024, now widely supported. Think USB-C: before it, every agent × every tool needed a custom integration (N×M); with it, an agent implements one MCP client and a tool implements one MCP server, and everything interconnects (N+M). A server exposes three things: **tools** (callable functions — 99% of daily use), **resources** (data), and **prompts** (templates). Local servers are child processes of the agent (stdio); remote ones speak HTTP.

[^mcpm]: **mcpm ([mcpm.sh](https://mcpm.sh/)) is an open-source MCP package manager**: Homebrew for MCP servers — search and install from a central registry, group servers into profiles (work/personal) you can toggle, sync one config to many clients, and aggregate multiple servers behind a single router endpoint. Caveat: native Claude Code support is limited and needs manual wiring. The easier daily answer is cc-switch's built-in MCP management.

[^herdr]: **herdr ([herdr.dev](https://herdr.dev/)) is an agent runtime — the agent-native successor to tmux**: a background server that holds persistent terminal sessions for coding agents, surviving lid close, network drops, and reboots, reattachable from any device. It reads every pane and labels each agent working / blocked / idle; its CLI and socket API are a single surface, so agents themselves can split panes and start / prompt / wait on each other; 21 agent CLIs detected out of the box. Single binary for macOS / Linux / Windows. Caveat: a young, YC-backed project — stay on the stable channel and prefer brew-managed installs over the direct installer.

[^orbstack]: **OrbStack is the work of indie developer Danny Lin (kdrag0n)** — a one-person company, launched 2023. Previously known in the Android custom-kernel scene (Proton Kernel), he rewrote the entire Docker + Linux virtualization stack natively in Swift/Rust: instant startup, near-zero idle CPU, far better battery life than Docker Desktop. Famous as "one person beating Docker's official product". Free for personal use, paid for business.

[^1p]: **1Password is a paid subscription** (~$3/mo billed annually for individuals, no free tier, 14-day trial). In this guide it's optional — the free path covers the essentials: SSH keys in the native macOS Keychain (`ssh-add --apple-use-keychain`), passwords in Bitwarden (free tier, also has a CLI and SSH agent), and sensitive dotfiles encrypted with age/sops. 1Password's unique value is `op run` runtime secret injection and cross-device polish; adopt it when you need it.

[^combo]: **The 1Password + Keychain combo, divided by layer**: the system layer goes to Keychain (SSH passphrases unlock once at boot, then invisible all day; iCloud Keychain syncs system passwords), the application layer goes to 1Password (website passwords, API key storage and injection). Typical flow: a project holds only an `.env.tpl` template with references (`KEY=op://Dev/Anthropic/key`, not plaintext); running `op run --env-file=.env.tpl -- claude` prompts for one Touch ID authorization, and keys exist only in the process environment. Discipline: enable **only one** of the two SSH agents (Keychain recommended) or ssh authentication gets confusing. One-liner: Keychain serves "what the system needs", 1Password serves "what you and your agents need".

[^free-apps]: **Nearly everything in this chapter is free**: Rectangle, AltTab, Stats, and Karabiner-Elements are free and open source (Rectangle has an optional $9.99 Pro; the base version suffices). Raycast is freemium (~$8/mo Pro): the free tier covers the launcher, clipboard history, and window management — Pro mainly buys AI features and cloud sync, and your AI needs are already covered by the terminal agents. In the second tier, Chrome, Obsidian, LocalSend, and IINA are free; Shottr is free (optional Pro); Tailscale's personal tier is enough.

[^omarchy]: **Omarchy** is the opinionated "batteries-included" Linux distribution led by DHH (creator of Ruby on Rails) ([omarchy.org](https://omarchy.org/manual/)), shipping a curated set of dev/productivity tools — a hit in 2025. This chapter's second tier maps its picks to macOS; its fzf, zoxide, ripgrep, eza, lazygit, Neovim/LazyVim, and 1Password picks are already covered in earlier chapters of this guide.

[^chezmoi]: **chezmoi is a free, open-source dotfiles manager** (a single Go binary by Tom Payne, released 2019, MPL-2.0, the most popular tool in its category). It collects your scattered dotfiles into one git repo and restores everything on a new machine with `chezmoi init --apply <repo>`. Two superpowers over manual symlinks: **templates** (one repo adapts to per-machine differences, e.g. different git emails for work vs personal) and **encryption** (sensitive configs encrypted with age before entering the repo — a leaked private repo is not a disaster).
