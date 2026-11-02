{ pkgs, lib, ... }:

let
  bunGlobalPackages = [
    "@earendil-works/pi-coding-agent"
    "@oh-my-pi/pi-coding-agent"
    "@oh-my-pi/pi-natives"
    "@oh-my-pi/pi-natives-linux-x64"
    "@opencode/cli"
    "@upstash/context7-mcp"
    "eas-cli"
    "expect-cli"
    "githits"
  ];
in
{
  home.activation.bunGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export BUN_INSTALL="$HOME/.bun"
    $DRY_RUN_CMD mkdir -p "$BUN_INSTALL/bin"
    BUN_BIN="${pkgs.bun}/bin/bun"
    INSTALLED="$("$BUN_BIN" -g list 2>/dev/null || true)"
    for pkg in ${lib.escapeShellArgs bunGlobalPackages}; do
      if printf '%s\n' "$INSTALLED" | grep -Fq "$pkg@"; then
        echo "bun global OK: $pkg"
      else
        echo "bun global installing: $pkg@latest"
        $DRY_RUN_CMD "$BUN_BIN" add -g "$pkg@latest"
      fi
    done
  '';
}
