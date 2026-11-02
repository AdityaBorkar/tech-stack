# HOW_TO — Replicate This Machine With Nix (from REPORT.md)

Source machine: Ubuntu 24.04.5 LTS on WSL2 (`Aditya-Borkar`), 1338 APT packages.
Full inventory: [`REPORT.md`](REPORT.md). This guide applies that report with Nix.

## 1. What the machines/blueprints/main/nix/ files are

| File                                                                                           | Purpose                                                             | REPORT mapping                                          |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------- |
| [`machines/blueprints/main/nix/flake.nix`](machines/blueprints/main/nix/flake.nix)               | Flake inputs (`nixos-unstable` + `home-manager`) and two outputs    | REPORT §1 package managers                              |
| [`machines/blueprints/main/nix/home.nix`](machines/blueprints/main/nix/home.nix)                 | home-manager user config for `aditya` — use on **Ubuntu/WSL**       | REPORT §2 (user packages), §4 (dotfiles)                |
| [`machines/blueprints/main/nix/nixos-configuration.nix`](machines/blueprints/main/nix/nixos-configuration.nix) | NixOS system config `wsl-target` — use on a **fresh NixOS** machine | REPORT §2 (system half), `/etc` services, fonts, docker |
| [`machines/blueprints/main/nix/flake.lock`](machines/blueprints/main/nix/flake.lock)             | Pinned inputs (generated, commit it)                                | Reproducibility                                         |
| [`machines/presets/`](machines/presets/)                                                       | Desired-state dotfiles linked by `home.file`                        | REPORT §4                                               |

Two paths:

- **Path A (current type): Ubuntu/WSL + Nix** → apply `homeConfigurations."aditya"` only. Nix manages user tools; APT still owns kernel, systemd services, and snap bases.
- **Path B (fresh NixOS / NixOS-WSL / bare metal)** → apply `nixosConfigurations."wsl-target"` + home-manager. Nix owns the system (docker, caddy, dnsmasq, cockpit, fonts).

`nix flake check ./machines/blueprints/main/nix --no-build` passes on the source machine (verified 2026-10-31).

## 2. Prerequisites

1. 64-bit Linux, `x86_64-linux`.
2. Nix with flakes:
   ```bash
   nix --version  # need >= 2.18; source has 2.34.7
   # enable flakes if needed:
   mkdir -p ~/.config/nix
   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
   ```
3. Git (flake must be git-tracked — `git add -N machines/blueprints/main/nix/` at minimum, then commit `machines/blueprints/main/nix/flake.lock`).
4. On Ubuntu/WSL: keep APT for the base (`sudo apt update && sudo apt install -y git curl`).
5. ~4 GB free for `/nix/store` on first apply.

## 3. Path A — Ubuntu / WSL (recommended for this REPORT)

```bash
cd /home/aditya/repo/tech-stack   # or your clone on the new machine

# 1. Install nix (if missing) + home-manager runner
sh <(curl -L https://nixos.org/nix/install) --daemon
nix --extra-experimental-features "nix-command flakes" --version

# 2. Review what will be installed (matches REPORT §2)
less machines/blueprints/main/nix/home.nix   # ~50 pkgs: git gh jq ripgrep htop bun deno go rustup jdk17/8 gradle python312/313 docker awscli2 pulumi cloudflared act caddy mkcert android-tools ffmpeg postgresql_16 chromium google-chrome vscode zed-editor opencode ...

# 3. Apply
nix run home-manager -- switch --flake ./machines/blueprints/main/nix#aditya

# 4. Restart shell so ~/.bashrc PATH order (bun -> nvm -> ~/.local/bin -> brew -> cargo -> android) takes effect
exec bash
which git gh node bun deno go docker aws pulumi caddy adb psql ffmpeg | sort
```

What this does NOT do (do §5 post-steps next): nvm Node 24.15.0, bun/npm globals, pip ML stack, Android SDK payload, docker/gh/aws/pulumi logins, ssh keys, mkcert CA, caddy/dnsmasq `/etc` units.

## 4. Path B — Fresh NixOS machine

```bash
# On the NixOS installer / NixOS-WSL target:
sudo nixos-rebuild switch --flake ./machines/blueprints/main/nix#wsl-target

# Then apply the user layer (same home.nix):
nix run home-manager -- switch --flake ./machines/blueprints/main/nix#aditya
```

Before reboot, edit [`machines/blueprints/main/nix/nixos-configuration.nix`](machines/blueprints/main/nix/nixos-configuration.nix):

- `fileSystems."/"` + `boot.loader.grub.devices` are stubs — replace with your disk (or disko / `nixos-wsl` module).
- `networking.hostName`, `time.timeZone`, `users.users.aditya`.
- `services.caddy.virtualHosts` — source had the stock `:80 file_server` default; paste your real Caddyfile.
- `services.dnsmasq.extraConfig` — only if you exported custom `/etc/dnsmasq.d` rules.

## 5. Post-steps Nix cannot own (from REPORT §4–§6)

Run in order; secrets are **re-entered, never copied from git**:

```bash
# Rust (source had rustup with NO toolchain)
rustup default stable && rustc --version

# Node via nvm (nix gives nodejs_24, nvm pins 24.15.0 + npm 11.16.0)
export NVM_DIR="$HOME/.nvm"; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install 24.15.0 && nvm alias default 24.15.0 && node --version  # v24.15.0

# Bun + Deno (if you prefer installers over nix pkgs)
curl -fsSL https://bun.sh/install | bash -s -- bun-v1.4.4   # REPORT: 1.4.4
curl -fsSL https://deno.land/install.sh | sh                # REPORT: 2.5.4

# JS globals (REPORT §3 — don't copy node_modules, reinstall)
npm i -g agent-browser@0.37.1
bun add -g @opencode/cli@2.2.5 eas-cli@27.2.0 githits@0.37.0 @upstash/context7-mcp@4.4.4 expect-cli@0.1.3 @oh-my-pi/pi-coding-agent@18.14.1
bun pm -g ls; npm list -g --depth=0

# Python ML (REPORT §3: torch 2.13.0, easyocr 1.7.2, opencv, pymupdf, ...)
python3 -m venv ~/.venvs/ml && source ~/.venvs/ml/bin/activate
pip install torch torchvision easyocr opencv-python-headless pymupdf pypdf scikit-image pillow scipy numpy
# recreate per-project venvs; never copy site-packages

# Brew-only (if the target keeps brew alongside nix)
brew install act awscli cloudflared go hyperfine pulumi python@3.15  # REPORT versions in §2-§3

# Android SDK payload (REPORT §2.4 — ~/android is too large for git)
export ANDROID_HOME=$HOME/android ANDROID_SDK_ROOT=$HOME/android
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;27.1.12297006" "cmake;3.22.1"
sdkmanager --list_installed   # expect build-tools 30.0.3/35/36, cmake 3.22.1, ndk 27.x, android-30/36
adb pair <special-ip:port>; adb connect <ip:port>  # see machines/presets/adb/README.md

# Certs + system services
mkcert -install  # CAROOT ~/.local/share/mkcert (copy rootCA.pem; re-issue rootCA-key.pem securely)
# Ubuntu target: sudo apt install -y caddy dnsmasq cockpit; merge /etc/caddy/Caddyfile, /etc/dnsmasq.d/, /etc/cockpit/

# Logins (REPORT §5 — values redacted in REPORT.md)
chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_*   # copy id_ed25519 via encrypted medium
gh auth login; aws configure  # region ap-south-1 on source
pulumi login; eas login; opencode auth login
docker login  # source credsStore was desktop.exe (Windows) — re-login on Linux
# ~/.npmrc, ~/.wakatime.cfg, ~/.cloudflared/cert.pem, ~/.pulumi/credentials.json, opencode auth.json: re-auth, don't paste
```

Copy dotfiles (REPORT §4 master list) after the nix apply:

```bash
# Shell/identity + editor/agent configs (examples — full list in REPORT §4):
cp -r /backup/home/.{bashrc,profile,gitconfig,ssh,aws,npmrc,wakatime.cfg} ~/
cp -r /backup/home/.config/{gh,opencode,Code,zed,githits} ~/.config/
cp -r /backup/home/.{claude,gemini,codex,cursor,vscode-server,gradle,android,pulumi,docker} ~/
cp -r /backup/home/android ~/android
# Apply repo presets over the top:
cp machines/presets/vscode/settings.json ~/.config/Code/User/settings.json
cp machines/presets/zed/settings.json ~/.config/zed/settings.json
```

## 6. Verify (mirrors REPORT §7)

```bash
nix --version; nix --extra-experimental-features "nix-command flakes" flake check ./machines/blueprints/main/nix --no-build  # all checks passed
node --version      # v24.15.0 (nvm) | nix nodejs_24 may differ — nvm wins on PATH
bun --version       # 1.4.4
deno --version      # 2.5.4
go version          # 1.27.3 on source; nixpkgs may lag — note drift, don't force-downgrade
java -version       # 17.0.20.1 default; /usr/lib/jvm/java-8 for legacy
docker --version; docker compose version  # compose was MISSING on source — now present
aws --version; pulumi version; cloudflared --version
psql --version; caddy version; adb version; ffmpeg -version
gh auth status; aws sts get-caller-identity; pulumi whoami; docker ps; adb devices
opencode --version  # v2.2.5 on source
echo "JAVA_HOME=$JAVA_HOME ANDROID_HOME=$ANDROID_HOME"
git status  # ensure no secret (gho_/ctx7sk-/waka_/npm_l6f) staged
```

## 7. Troubleshooting

| Symptom                                                     | Cause / fix                                                                                                                                                                                        |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Path 'machines/blueprints/main/nix/flake.nix' is not tracked by Git`                | Run `git add -N machines/blueprints/main/nix/` (or `git add machines/blueprints/main/nix/flake.lock`), then retry. Nix only sees tracked files.                                                                                                      |
| `warning: Git tree ... is dirty`                            | Harmless — commit before final replication.                                                                                                                                                        |
| `error: experimental Nix feature 'nix-command' is disabled` | Add `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`.                                                                                               |
| `attribute 'foo' missing` on `home-manager switch`          | That nixpkgs attr was renamed/removed — comment it out in `machines/blueprints/main/nix/home.nix`, open an issue, install that one tool manually (likely candidates: `cockpit`, `opencode`, `zed-editor`, `google-chrome`). |
| `go version` / `python --version` differs from REPORT       | Expected drift: REPORT pins brew go 1.27.3 / python 3.15.2; nixpkgs unstable may ship older. Keep nix version unless the project pins otherwise.                                                   |
| `gradle --version` shows newer than 4.4.1                   | REPORT source used ancient APT gradle 4.4.1 — use the Gradle wrapper per-project instead of downgrading system gradle.                                                                             |
| `rustup: no default toolchain`                              | Expected (source had none) — run `rustup default stable`.                                                                                                                                          |
| `docker: unknown command: docker compose` persists          | You used the old `~/bin/docker` static install — prefer nix/system docker + `docker-compose`, and drop `~/bin/docker*` from PATH.                                                                  |
| `cockpit`/`caddy`/`dnsmasq` units do nothing on Ubuntu      | Correct — those `services.*` only apply on Path B (NixOS). On Ubuntu use APT + `/etc` files per REPORT §6.                                                                                         |
| Unfree error (`google-chrome`, `vscode`)                    | Flake + home.nix already set `allowUnfree = true` — don't remove it.                                                                                                                               |
| `chromium-browser requires the chromium snap`               | Source artifact — use nix `chromium` or `google-chrome` instead.                                                                                                                                   |

## 8. Maintain

```bash
nix flake update ./machines/blueprints/main/nix          # bump nixpkgs/home-manager monthly
nix flake check ./machines/blueprints/main/nix --no-build
apt-mark showmanual > /tmp/manual.txt  # diff against REPORT §1 when re-auditing
bun pm -g ls; npm list -g --depth=0; sdkmanager --list_installed  # refresh REPORT §3
```

Keep [`REPORT.md`](REPORT.md) as the audit source and `machines/blueprints/main/nix/` as the executable mirror. When they disagree, trust a fresh audit, then update the corresponding `machines/blueprints/main/nix/*.nix` package pin.
