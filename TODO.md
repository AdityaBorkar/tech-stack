# TODO

There must be a validate command to validate all configs

NOTE: EAS/Expo, agent-browser, context7-mcp, githits, expect-cli,
pi-coding-agents are NOT in nixpkgs — reinstall via bun/npm per HOW_TO §4.
pacman-contrib is Arch-only (paccache etc.) — no nixpkgs equivalent; skip on NixOS/Ubuntu.

age key at ~/.config/sops/age/keys.txt

- `rustup default stable` (source had no toolchain)
- nvm install 24.15.0 / bun add -g ... / npm i -g agent-browser
- pip ML stack in a venv (torch 2.13.0, easyocr 1.7.2, opencv, ...)
- Android SDK payload via sdkmanager + adb pair/connect
- mkcert -install, caddy/dnsmasq/cockpit system units, docker login,
  cloudflared cert, ssh key copy.
  To rotate a secret: sops secrets.yaml (from this dir), then re-apply.
