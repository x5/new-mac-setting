#!/bin/bash
# =============================================================================
# Mac × AI Agent — one-command setup
# https://github.com/x5/new-mac-setting
#
# Usage:
#   curl -fsSL https://x5.github.io/new-mac-setting/setup.sh | bash
#   or from a repo clone:  ./setup.sh
#
# Idempotent: safe to re-run; every step skips what is already done.
# Interactive: each step asks before running (answer "a" to accept all).
# =============================================================================
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/x5/new-mac-setting/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

# ---- pretty logging ---------------------------------------------------------
if [ -t 1 ]; then
  LIME=$'\033[38;5;190m'; DIM=$'\033[0;90m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  LIME=""; DIM=""; BOLD=""; RESET=""
fi
step()  { printf "\n%s==>%s %s%s%s\n" "$LIME" "$RESET" "$BOLD" "$1" "$RESET"; }
info()  { printf "    %s%s%s\n" "$DIM" "$1" "$RESET"; }
ok()    { printf "    %s✓%s %s\n" "$LIME" "$RESET" "$1"; }

AUTO=0
ask() {  # ask "<description>" -> returns 0 to run
  [ "$AUTO" = "1" ] && return 0
  printf "    Run this step? [Y]es / [n]o / [a]ll: "
  read -r a < /dev/tty || a="y"
  case "$a" in
    n|N) return 1 ;;
    a|A) AUTO=1; return 0 ;;
    *)   return 0 ;;
  esac
}

# =============================================================================
step "1/9  macOS system defaults (keyboard, Finder, Dock, screenshots)"
if ask; then
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock show-recents -bool false
  mkdir -p ~/Screenshots
  defaults write com.apple.screencapture location ~/Screenshots
  killall Finder Dock 2>/dev/null || true
  ok "defaults applied"
fi

# =============================================================================
step "2/9  Xcode Command Line Tools (git, clang — required by everything)"
if ask; then
  if xcode-select -p &>/dev/null; then
    ok "already installed"
  else
    xcode-select --install || true
    info "A system dialog appeared — finish it, then re-run this script."
    exit 0
  fi
fi

# =============================================================================
step "3/9  Homebrew"
if ask; then
  if command -v brew &>/dev/null; then
    ok "already installed"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || \
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  ok "$(brew --version | head -1)"
fi

# =============================================================================
step "4/9  Brewfile — all tools & apps (this takes a while)"
if ask; then
  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/Brewfile" ]; then
    BF="$SCRIPT_DIR/Brewfile"
  else
    BF="$(mktemp -t Brewfile)"
    curl -fsSL "$REPO_RAW/Brewfile" -o "$BF"
  fi
  brew bundle --file="$BF"
  ok "brew bundle done"
fi

# =============================================================================
step "5/9  Shell setup (zsh plugins, Starship, fzf, zoxide, aliases, dotsync)"
if ask; then
  MARK="# >>> mac-ai-agent-setup >>>"
  if grep -qF "$MARK" ~/.zshrc 2>/dev/null; then
    ok "~/.zshrc already configured"
  else
    cat >> ~/.zshrc <<'EOF'

# >>> mac-ai-agent-setup >>>
eval "$(starship init zsh)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias ls='eza --icons' ll='eza -l --icons' lt='eza --tree --icons'
alias cat='bat --style=plain'

# dotsync: after any env change, snapshot everything into your dotfiles repo
dotsync() {
  brew bundle dump --file=~/dotfiles/Brewfile --force
  chezmoi re-add 2>/dev/null || true
  git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m "chore: sync $(date +%F)" && git -C ~/dotfiles push
}
# <<< mac-ai-agent-setup <<<
EOF
    ok "~/.zshrc configured"
  fi
fi

# =============================================================================
step "6/9  Ghostty config (JetBrainsMono Nerd Font, catppuccin-mocha)"
if ask; then
  GCFG=~/.config/ghostty/config
  if [ -f "$GCFG" ]; then
    ok "config exists, left untouched ($GCFG)"
  else
    mkdir -p ~/.config/ghostty
    cat > "$GCFG" <<'EOF'
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = catppuccin-mocha
background-opacity = 0.96
window-padding-x = 12
window-padding-y = 10
copy-on-select = clipboard
EOF
    ok "$GCFG written"
  fi
fi

# =============================================================================
step "7/9  Runtimes via mise (node@lts, python@3.12, go@latest)"
if ask; then
  eval "$(mise activate bash)" 2>/dev/null || true
  mise use -g node@lts python@3.12 go@latest
  ok "mise runtimes installed"
fi

# =============================================================================
step "8/9  AI agent CLIs (Claude Code, Kimi Code, Codex, PI; DSH via npx)"
if ask; then
  eval "$(mise activate bash)" 2>/dev/null || true
  command -v claude &>/dev/null || curl -fsSL https://claude.ai/install.sh | bash
  command -v kimi   &>/dev/null || curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
  npm install -g @openai/codex @earendil-works/pi-coding-agent
  info "DSH runs via: npx -y @deepseek-ai/dsh"
  info "Desktop agents (install manually): ZCode — https://zcode.z.ai/cn · WorkBuddy — official site"
  ok "agent CLIs installed"
fi

# =============================================================================
step "9/9  Done — manual finishing touches"
cat <<'EOF'

  Remaining manual steps (need your accounts):
    1. gh auth login                                  → GitHub auth
    2. ssh-keygen -t ed25519 && ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    3. Optional: 1Password / Bitwarden for API keys
    4. Desktop agents: ZCode (zcode.z.ai/cn), WorkBuddy — sign in on first launch
    5. Finish: create your dotfiles repo, then run `dotsync` once

  Verify everything: run the acceptance checklist in the guide (§14):
    https://x5.github.io/new-mac-setting/mac-mini-ai-dev-setup.html

EOF
ok "All done. Restart your terminal (or: source ~/.zshrc)"
