[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
. "$HOME/.deno/env" 2>/dev/null || true
. "$HOME/.cargo/env" 2>/dev/null || true
