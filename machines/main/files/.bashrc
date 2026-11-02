# Managed by home-manager (tech-stack machine/main/files/.bashrc). Full replacement.

# Home Manager session vars (nix profile PATH, JAVA_HOME, etc.)
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

# Interactive defaults
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend 2>/dev/null || true
shopt -s checkwinsize 2>/dev/null || true

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# direnv (binary + direnvrc via programs.direnv; hook wired here)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Toolchain shims
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env" 2>/dev/null || true
export ANDROID_HOME="$HOME/android"
export ANDROID_SDK_ROOT="$HOME/android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Prompt: green user, blue cwd
export PS1='\[\e[1;32m\]\u\[\e[1;34m\]:\w\[\e[1;0m\]\$ '
