# Managed by home-manager (tech-stack machine/main/files/.zshrc). Full replacement.

# Home Manager session vars (nix profile PATH, JAVA_HOME, etc.)
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd

fpath=("$HOME/.nix-profile/share/zsh/site-functions" $fpath)
autoload -Uz compinit && compinit

# Plugins (installed via home.packages)
if [ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  . "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  . "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# direnv (binary + direnvrc via programs.direnv; hook wired here)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Toolchain shims (same as .bashrc)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env" 2>/dev/null || true
export ANDROID_HOME="$HOME/android"
export ANDROID_SDK_ROOT="$HOME/android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

PROMPT=$'%{\e[1;32m%}%n%{\e[1;34m%}:%~%{\e[1;0m%}$ '
