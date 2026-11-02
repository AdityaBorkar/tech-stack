# machines/blueprints/main/nix/home.nix: bun + deno shims (same order as source ~/.bashrc)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env" 2>/dev/null || true
export ANDROID_HOME="$HOME/android"
export ANDROID_SDK_ROOT="$HOME/android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
# Custom prompt from source ~/.bashrc (green user, blue cwd)
export PS1='\[\e[1;32m\]\u\[\e[1;34m\]:\w\[\e[1;0m\]\$ '
