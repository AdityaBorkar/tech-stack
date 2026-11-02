# Managed by home-manager (tech-stack machine/main/files/.profile). Full replacement.

# Home Manager session vars (nix profile PATH, JAVA_HOME, etc.)
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
. "$HOME/.deno/env" 2>/dev/null || true
. "$HOME/.cargo/env" 2>/dev/null || true

# Pull in interactive config for bash login shells
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
