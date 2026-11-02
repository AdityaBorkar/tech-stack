# PC Migration Report — Ubuntu 24.04 (WSL2) → New Linux Machine

Generated: 2026-10-31 (UTC)
Source host: `Aditya-Borkar` (`Linux 6.18.54.1-microsoft-standard-WSL2 x86_64`)
Source OS: `Ubuntu 24.04.5 LTS (Noble Numbat)` — WSL2, `systemd=true` in `/etc/wsl.conf`
Report scope: software that **must be reinstalled** + exact **config/data paths to copy**. Secrets are listed by path only (values redacted).

How this was collected: `apt-mark showmanual`, `dpkg-query -W`, `snap list`, `brew list --versions`, `nvm`/`node`/`bun`/`deno`/`go`/`rustup`/`java`/`docker`/`aws`/`pulumi` version checks, `code --list-extensions`, `ls ~/.config ~/ ~/bin ~/.local/bin`, and reading `~/.bashrc`, `~/.profile`, `~/.gitconfig`.

> WSL caveat: VS Code (`1.136.1`) runs on the Windows host at `/mnt/c/Users/adity/AppData/Local/Programs/Microsoft VS Code/bin/code`. `code --list-extensions` inside WSL returned empty. Extensions live on Windows + `~/.vscode-server/`. Docker is rootless static binaries in `~/bin/` (daemon not running, no `/etc/docker/`).

---

## 1. Base OS & package managers to reinstall first

| Component | Version on source | Install on target |
|---|---|---|
| Ubuntu | 24.04.5 LTS Noble | Install Ubuntu 24.04+ (or same). If WSL2, enable `systemd=true` in `/etc/wsl.conf` |
| APT (1338 `ii` packages) | see §2 | `sudo apt update && sudo apt install <list>` — full manual list via `apt-mark showmanual` |
| Snap | `snapd 2.77.1` | `sudo apt install snapd`; snaps present were only bases: `bare`, `core22`, `core24`, `core26`, `cups 2.4.20-1`, `gnome-46-2404`, `gtk-common-themes`, `mesa-2404`. No user snap apps. `chromium-browser` is a snap stub (requires chromium snap, not installed) |
| Linuxbrew | `/home/linuxbrew/.linuxbrew` | Reinstall from https://brew.sh, then `brew install <list in §2>` |
| NVM + Node | `nvm` with `node v24.15.0`, `npm 11.16.0` | Install nvm, `nvm install 24.15.0`, `nvm alias default 24.15.0` |
| Bun | `1.4.4` (`~/.bun`) | `curl -fsSL https://bun.sh/install \| bash -s -- bun-v1.4.4` |
| Deno | `2.5.4` (`~/.deno`) | `curl -fsSL https://deno.land/install.sh \| sh` |
| Rustup | installed, **no toolchain** (`rustup toolchain list` empty) | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh`, then `rustup default stable` |
| Go | `1.27.3` (brew) | `brew install go@1.27.3` or official tarball; `GOPATH=~/go` (currently empty `~/go/bin` missing) |
| Python | system `/usr/bin/python3 3.12.3`, brew `3.15.2`, uv shim `~/.local/bin/python3.11 -> ~/.local/share/uv/python/...` | `sudo apt install python3.12-venv python3-pip python3-numpy python3-pil`, `brew install python@3.15`, reinstall `uv` if used |
| Git LFS / build | `build-essential 12.10ubuntu1`, `pkg-config 1.8.1`, `curl 8.5.0`, `wget 1.21.4`, `unzip` | `sudo apt install build-essential pkg-config curl wget unzip` |

PATH assembly on source (`~/.bashrc` + `~/.profile`, in order):
`~/.bun/bin` → `nvm` → `~/.local/bin` → `linuxbrew` → `~/.cargo/bin` → `/snap/bin` → `~/android/cmdline-tools/latest/bin:~/android/platform-tools:...` → `/usr/bin` → `/root/.local/bin` → `/opt/nanobrew/prefix/bin` → `~/.steel/bin` → `~/.deno` (`~/.deno/env`) → `~/bin` (via `~/.profile`) → `~/.local/bin` (Antigravity). Copy `~/.bashrc` + `~/.profile` then adjust.

---

## 2. Software inventory (must-install)

### 2.1 CLI essentials (APT)

| Package | Version | Config |
|---|---|---|
| `git` | `1:2.43.0-1ubuntu7.4` | `~/.gitconfig` |
| `gh` | `2.45.0-1ubuntu0.3` | `~/.config/gh/hosts.yml` (token — re-auth) |
| `curl` / `wget` | `8.5.0` / `1.21.4-1ubuntu4.5` | `~/.wget-hsts` |
| `jq` | `1.7.1` | none |
| `ripgrep` | `14.1.0-1` | none |
| `htop` | `3.3.0-4build1` | `~/.config/htop/` |
| `tree` | `2.1.1-2ubuntu3.24.04.2` | none |
| `ncdu` | `1.19-0.1` | none |
| `socat` | `1.8.0.0-4ubuntu0.1` | none |
| `dnsmasq` | `2.91-0ubuntu0.24.04.2` | `/etc/dnsmasq.conf`, `/etc/dnsmasq.d/` |
| `sqlite3` | `3.45.1-1ubuntu2.8` | DB files wherever you keep them |
| `net-tools` | `2.10-0.1ubuntu4.4` | none |
| `unzip`, `file`, `acl`, `login`, `uidmap` | stock Noble | none |
| `gnome-keyring` | stock | `~/.local/share/keyrings/` |
| `vim` | `9.1` | no `~/.vimrc`/`~/.vim/` on source (stock); `~/.viminfo` is history only |
| `nano` | stock | none |
| `xvfb` | `2:21.1.12-1ubuntu1.9` | none (used for headless Chrome) |

### 2.2 Languages / toolchains

| Software | Version | Install method | Config |
|---|---|---|---|
| Node.js | `v24.15.0` | nvm (`~/.nvm/versions/node/v24.15.0`) | `~/.nvmrc` (none on source), `~/.npmrc` (token — re-auth), `~/.npm/`, project `.nvmrc` files |
| Yarn | `1.22.22` | bundled with Node (`~/.nvm/.../bin/yarn`) | `~/.config/yarn/` |
| pnpm | `10.33.0` | bundled with Node | `~/.local/share/pnpm/`, `~/.config/` |
| Bun | `1.4.4` | `~/.bun` | `~/.bun/install/global/` (see §3), `~/.config/bun` if present |
| Deno | `2.5.4` + V8 `14.0.365.5` + TS `5.9.2` | `~/.deno` | `~/.deno/env` (sourced by `~/.profile`), `DENO_DIR=~/.cache/deno` |
| Go | `1.27.3 linux/amd64` | brew | `~/go/` (`GOPATH`), `~/.config/go/` |
| Rust | rustup, no default toolchain | rustup | `~/.cargo/env` (sourced by `~/.bashrc`+`~/.profile`), `~/.cargo/`, `~/.rustup/` |
| Java 17 (default) | `17.0.20.1+1-1~24.04` | `openjdk-17-jdk` | `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64` (set in `~/.bashrc`), `~/.gradle/` |
| Java 8 | `8u504-ga-1ubuntu1~24.04.3` | `openjdk-8-jdk-headless` | `update-alternatives --config java` to restore default |
| Gradle | `4.4.1` (very old, 2012) | `gradle` apt | `~/.gradle/` (10 entries on source — copy), wrapper per-project |
| Python brew | `3.15.2`, pip `26.2.2` | `python@3.15` brew | `~/.cache/pip/`, `~/.python_history` |
| Python system | `3.12.3` | apt + `python3.12-venv python3-pip python3-numpy python3-pil` | venvs per-project (recreate, don't copy) |
| C/C++ build | `gcc-12`, `build-essential`, SDL2 dev (`libsdl2-dev`, `-image`, `-mixer`, `-ttf`), `libfreetype-dev`, `librsvg2-dev`, `libwebkit2gtk-4.1-dev`, `libmariadb-dev`, `libssl-dev`, `libxdo-dev`, Vulkan/Mesa | apt | none — reinstall dev headers |

### 2.3 Containers / cloud / IaC

| Software | Version | Config |
|---|---|---|
| Docker (rootless static) | `28.5.1, build e180ab8` — binaries in `~/bin/` (`docker`, `dockerd`, `containerd`, `runc`, `rootlesskit`, `docker-proxy`, `ctr`) | `~/.docker/config.json` (`credsStore=desktop.exe` — Windows integration; re-login on Linux), `~/.config/docker/` (absent on source), `~/bin/dockerd-rootless.sh`. No `/etc/docker/daemon.json` on source. `docker compose` plugin **missing** (`docker: unknown command: docker compose`) — install compose plugin on target |
| AWS CLI | `2.39.3` (brew, Python 3.15) | `~/.aws/config` (`region=ap-south-1`) + `~/.aws/credentials` (secret) |
| Pulumi | `3.273.0` (brew) | `~/.pulumi/` (`credentials.json`, `stacks/`, `workspaces/`, `plugins/`, `meta.yaml`) — re-login (`pulumi login`) |
| cloudflared | `2026.10.7` (brew) | `~/.cloudflared/cert.pem` (secret), `~/.config/cloudflare/` |
| act (GitHub Actions local) | `0.2.92` (brew) | `~/.config/act/` |
| hyperfine | `2.0.0` (brew) | none |
| Caddy | `2.6.2-6ubuntu0.24.04.3` | `/etc/caddy/Caddyfile` (default `:80` site), `~/.config/caddy/autosave.json` |
| mkcert | `1.4.4-1ubuntu3.2` | `CAROOT=~/.local/share/mkcert/` (`rootCA.pem` + `rootCA-key.pem` secret) + `~/.vite-plugin-mkcert/` |
| dnsmasq, socat | above | see §2.1 |
| Cockpit | `314-1` | `/etc/cockpit/` (`disallowed-users`, `machines.d`, `ws-certs.d`) — `cockpit` binary not on PATH in WSL |
| steel/nanobrew | `~/.steel` (PATH only, `bin/` missing), `/opt/nanobrew/prefix/bin` (`cppcheck`, `nb`) | reinstall nanobrew/steel, copy PATH lines |

### 2.4 Mobile / frontend / media

| Software | Version | Config |
|---|---|---|
| Android SDK (`ANDROID_HOME=~/android`, `ANDROID_SDK_ROOT` same) | `build-tools 30.0.3/35.0.0/36.0.0`, `cmake 3.22.1`, `ndk 27.1.12297006`, `platforms android-30/36`, `platform-tools 37.0.0` (via `sdkmanager`) + apt `android-sdk-platform-tools 28.0.2+9`, `adb 34.0.4-debian` | `~/android/` (copy whole tree or re-download via `sdkmanager`), `~/.android/` |
| EAS CLI | `eas-cli/27.2.0 wsl-x64 node-v24.15.0` (bun global) | `~/.config/eas-cli-nodejs/user-settings.json`, `~/.expo/` |
| Expo | via bun global `expo` (no standalone `expo` bin) | `~/.expo/` |
| ffmpeg | `7:6.1.1-3ubuntu5` | none |
| wkhtmltox | `1:0.12.6.1-2.jammy` | none |
| Google Chrome Dev | `159.0.8130.0 dev` (`google-chrome-unstable`) | `~/.config/google-chrome/`, `~/.config/google-chrome-unstable/` (40 entries), `~/.config/google-chrome-for-testing/`, `~/.cache/` |
| Chromium | snap stub only | install `chromium` snap or keep Chrome Dev on target |
| Chromedriver | `chromium-chromedriver` apt | none (prefer webdriver-manager) |
| Fonts | `fonts-freefont-ttf`, `fonts-ipafont-gothic`, `fonts-liberation`, `fonts-noto-color-emoji`, `fonts-tlwg-loma-otf`, `fonts-unifont`, `fonts-wqy-zenhei`, `xfonts-cyrillic`, `xfonts-scalable` | `~/.fonts/`, `~/.local/share/fonts/`, `~/.config/fontconfig/` (157 families via `fc-list`) |
| Tesseract data | `tesseract` bin missing, but `~/tesseract/` + `~/.EasyOCR/` (model, user_network) + pip `easyocr 1.7.2`, `pytesseract 0.3.13`, `opencv-python-headless 5.0.0.93`, `pillow 10.2.0` | `~/tesseract/`, `~/.EasyOCR/` |

### 2.5 DB clients

| Software | Version | Config |
|---|---|---|
| PostgreSQL client | `psql 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)`, `postgresql-client-common` | `~/.psql_history`, `~/.pgpass`, `~/.pg_service.conf` (create if needed), `PGHOST/PGUSER` env |
| SQLite | `3.54.1` (brew) + `3.45.1` (apt) | DB files |

No `mysql`, `mongosh`, `redis-cli`, `kubectl`, `helm`, `terraform`, `ansible`, `nginx`, `apache2`, `mvn` on source — skip unless needed.

### 2.6 Editors / AI coding tools

| Software | Version | Config to copy |
|---|---|---|
| VS Code (Windows host) | `1.136.1` | Windows `%APPDATA%\Code\User\settings.json` + extensions; WSL side: `~/.vscode-server/`, `~/.vscode-remote-containers/`, repo `machines/presets/vscode/settings.json` is the desired baseline |
| Cursor | server `~/.cursor-server/`, `~/.cursor/` | `~/.cursor/` (`mcp.json`, `agents/`, `skills*/`, `projects/`, `plugins/`) |
| Zed | server `~/.zed_server/zed-remote-server-stable-...` | `~/.config/zed/` + repo `machines/presets/zed/settings.json` |
| Vim | `9.1` | no vimrc on source — create from repo if desired; `~/.viminfo` optional |
| opencode | `v2.2.5` (`~/.bun/bin/opencode` + `@opencode/cli 2.2.5`) | `~/.config/opencode/opencode.json` (contains context7 key — rotate), `~/.config/opencode/{agents,skills,plugins,auth.json,opencode.json}`, `~/.local/share/opencode/` (db, auth, storage — re-auth), `~/.opencode/`, repo `machines/presets/opencode/` |
| agent-browser (npm) | `0.37.1` (`~/.nvm/.../lib/node_modules`) | `~/.agent-browser/` |
| codebase-memory-mcp | `~/.local/bin/codebase-memory-mcp` | `CBM_CACHE_DIR`/`CBM_RUNTIME_DIR`, `~/.local/share/codebase-memory*` if present, `~/.config/githits/`, `~/.githits/` |
| codedb | `~/bin/codedb` + `~/.codedb/` | `~/.codedb/`, `~/.claude/hooks/codedb-*.sh` |
| Claude Code | — | `~/.claude/` (`settings.json`, `agents/`, `hooks/`, `skills/`), `~/.claude.json` |
| Gemini CLI | — | `~/.gemini/` (`settings.json`, `config/`, `agents/`) |
| Codex CLI | — | `~/.codex/` (`config.toml`, `AGENTS.md`, `agents/`, `skills/`, `sqlite/`) |
| Copilot | — | `~/.copilot/`, `~/.config/github-copilot/` if present |
| Wakatime | — | `~/.wakatime.cfg` (api_key — re-enter), `~/.wakatime/` |
| Biome (preset only) | not installed as bin | repo `machines/presets/biome/settings.json` |

`~/.config/gh/hosts.yml`, `~/.config/opencode/auth.json`, `~/.local/share/opencode/auth.json`, `~/.pulumi/credentials.json` contain live tokens — **do not paste into git; re-auth on target** (see §5).

---

## 3. Global JS / Python packages (reinstall, don't copy node_modules)

NPM global (`~/.nvm/versions/node/v24.15.0/lib`):
`agent-browser@0.37.1`, `corepack@0.35.0`, `npm@11.16.0`.

Bun global (`~/.bun/install/global`, 1580 pkgs) — top-level:
`@earendil-works/pi-coding-agent@1.4.0`, `@oh-my-pi/pi-coding-agent@18.14.1`, `@opencode/cli@2.2.5`, `@upstash/context7-mcp@4.4.4`, `eas-cli@27.2.0`, `expect-cli@0.1.3`, `githits@0.37.0`.
Plus bins in `~/.bun/bin/`: `opencode`, `opencode2`, `githits`, `context7-mcp`, `eas`, `expect*`, `gemini`, `omp`, `pi`, `node-which`, `aspen`, `bunx`, etc. Regenerate with `bun add -g <pkg>` (list via `bun pm -g ls`).

Brew top-level (user): `act`, `awscli`, `cloudflared`, `go`, `hyperfine`, `pulumi`, `python@3.15` (+ auto deps). Regenerate with `brew list --versions`.

pip (system `pip list`, includes CUDA + ML): `torch 2.13.0`, `torchvision 0.28.0`, `nvidia-*`, `numpy 2.5.1`, `scipy 1.18.0`, `scikit-image 0.26.0`, `opencv-python-headless 5.0.0.93`, `easyocr 1.7.2`, `pytesseract 0.3.13`, `pymupdf 1.28.0`, `pypdf 6.19.0`, `pillow 10.2.0`, `cockpit 314`, plus `~/.local/bin/` shims (`easyocr`, `torchrun`, `f2py`, `pytesseract`, ...). Recreate venv/conda env and `pip install` from `pip freeze`; don't copy `site-packages`.

`~/.local/bin/` custom binaries to copy/reinstall: `agy`, `codebase-memory-mcp`, `codedb` (symlink to pipx venv — reinstall pipx venv), `droid`, `ninja`, `python3.11` symlink (uv).

---

## 4. Config & data paths master list (copy these)

Shell / identity:
`~/.bashrc`, `~/.profile`, `~/.bash_logout`, `~/.gitconfig`, `~/.ssh/` (`id_ed25519*`, `known_hosts*`), `~/.aws/`, `~/.npmrc` (re-auth), `~/.wakatime.cfg` (re-auth), `~/.lesshst`, `~/.wget-hsts`, `~/.node_repl_history`, `~/.python_history`, `~/.viminfo`, `~/.motd_shown`, `~/.sudo_as_admin_successful`.

Cloud / dev:
`~/.config/gh/`, `~/.config/opencode/`, `~/.opencode/`, `~/.local/share/opencode/` (re-auth), `~/.claude/`, `~/.claude.json`, `~/.gemini/`, `~/.codex/`, `~/.cursor/`, `~/.cursor-server/`, `~/.copilot/`, `~/.config/Code/` (`User/settings.json`), `~/.vscode-server/`, `~/.config/zed/`, `~/.zed_server/`, `~/.config/githits/`, `~/.githits/`, `~/.codedb/`, `~/.codeium/`, `~/.agents/`, `~/.config/agents/`, `~/.config/crush/`, `~/.config/goose/`, `~/.config/devin/`, `~/.factory/`, `~/.dsh/`.

Runtimes:
`~/.nvm/` (or reinstall), `~/.npm/`, `~/.cache/` (selective), `~/.bun/` (selective — `bin/` + global list), `~/.deno/` + `~/.deno/env`, `~/.cargo/`, `~/.rustup/`, `~/go/`, `/home/linuxbrew/.linuxbrew/` (reinstall, don't copy), `~/.gradle/`, `~/.config/go/`, `~/.config/yarn/`, `~/.config/eas-cli-nodejs/`, `~/.expo/`, `~/.config/nx/`, `~/.nx/`, `~/.config/turborepo/`, `~/.config/tanstack/`, `~/.config/steel*/`, `~/.config/astro/`, `~/.biome/`, `~/.local/share/mkcert/`, `~/.vite-plugin-mkcert/`, `~/.cloudflared/`, `~/.config/cloudflare/`, `~/.config/caddy/`, `~/.docker/`, `~/.pulumi/`, `~/.config/pulse/`, `~/.local/share/pipx/` (for `codegraphcontext`).

Android / browsers / system:
`~/android/`, `~/.android/`, `~/.config/google-chrome*/`, `~/.config/Electron/`, `~/.local/share/applications/` if customized, `/etc/caddy/Caddyfile`, `/etc/cockpit/`, `/etc/wsl.conf`, `/etc/dnsmasq.conf` + `/etc/dnsmasq.d/`, `~/.config/systemd/user/` (`openusage-telemetry.service`, `uma-machine.service`), `~/.config/dconf/` (partial), `~/.local/share/keyrings/`, `~/.gnupg/` (absent on source — create if needed), `~/.pki/`.

Project / secrets-adjacent (copy carefully, never commit):
`~/.EasyOCR/`, `~/tesseract/`, `~/.config/ggshield/`, `~/.config/docucraft*/`, `~/.config/tokscale/`, `~/.config/uma-machine/`, `~/.config/tally-gateway/`, `~/.config/vale/`, `~/.config/bifrost/`, `~/.config/kiset/`, `~/.config/rtk/`, `~/.config/steel*/`, `~/.config/react-doctor-nodejs/`, `~/.config/nextjs-nodejs/`, `~/.config/*-nodejs/` telemetry dirs, `~/.azure -> /mnt/c/Users/adity/.azure` (symlink — recreate on target; empty on source).

This repo's desired-state presets (apply after install):
`machines/presets/vscode/settings.json`, `machines/presets/zed/settings.json`, `machines/presets/biome/settings.json`, `machines/presets/opencode/` (`config.json`, `agents/`, `commands/`, `skills/`, `tui.json`), `machines/presets/adb/README.md`, `machines/presets/wsl/`.

---

## 5. Secrets — re-authenticate, do not copy values

These files contain live tokens/keys. Copy the **path/structure** only, re-login on the new machine, and never commit them:

- `~/.npmrc` (`//registry.npmjs.org/:_authToken=...`)
- `~/.wakatime.cfg` (`api_key = waka_...`)
- `~/.aws/credentials`
- `~/.config/gh/hosts.yml` (`oauth_token: gho_...`)
- `~/.config/opencode/opencode.json` (`context7` `ctx7sk-...`), `~/.config/opencode/auth.json`, `~/.local/share/opencode/auth.json`
- `~/.pulumi/credentials.json` (`accessTokens`, `accounts`)
- `~/.cloudflared/cert.pem`
- `~/.ssh/id_ed25519` (private key — move via encrypted medium, `chmod 600`)
- `~/.local/share/mkcert/rootCA-key.pem`
- `~/.docker/config.json` (desktop credsStore — `docker login` anew on Linux)
- `~/.config/eas-cli-nodejs/user-settings.json` (device id — harmless, but re-login `eas login`)
- `~/.gemini/`, `~/.codex/`, `~/.claude/` oauth sections

---

## 6. Restore playbook (new Ubuntu 24.04 machine)

1. Base: `sudo apt update && sudo apt install -y git curl wget build-essential pkg-config python3.12-venv python3-pip unzip jq ripgrep htop tree ncdu socat dnsmasq sqlite3 net-tools openjdk-17-jdk openjdk-8-jdk-headless postgresql-client caddy mkcert ffmpeg xvfb android-sdk-platform-tools gradle cockpit vim nano gh` (+ dev headers as needed). If WSL2: set `/etc/wsl.conf` `[boot] systemd=true`.
2. Brew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`, then `brew install act awscli cloudflared go hyperfine pulumi python@3.15`.
3. Shell: copy `~/.bashrc`, `~/.profile`, `~/.gitconfig`, `~/.ssh/` (fix `chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_*`), then `source ~/.bashrc`. Set `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT` as in §1.
4. Runtimes: nvm (`nvm install 24.15.0`), Bun 1.4.4, Deno 2.5.4, `rustup default stable`, Go (brew). Reinstall npm globals (`npm i -g agent-browser`) and bun globals (`bun add -g @opencode/cli eas-cli githits @upstash/context7-mcp expect-cli @oh-my-pi/pi-coding-agent`). Recreate Python venvs + `pip install torch torchvision easyocr opencv-python-headless pymupdf pypdf scikit-image` (pin CUDA builds).
5. Docker: reinstall `docker` + `docker compose` plugin (or copy `~/bin/` + `~/bin/dockerd-rootless.sh` and `dockerd-rootless-setuptool.sh`), then `docker login`, `gh auth login`, `aws configure`, `pulumi login`, `eas login`, `opencode auth login`, `codebase-memory-mcp` + `codedb` reinstall.
6. Android: copy `~/android/` + `~/.android/`, or `sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;27.1.12297006" "cmake;3.22.1"`. Then `adb pair/connect` per `machines/presets/adb/README.md`.
7. Certs/web: copy `~/.local/share/mkcert/` + `mkcert -install`, restore `/etc/caddy/Caddyfile` (or merge), `~/.config/caddy/`, `~/.cloudflared/`, dnsmasq/cockpit `/etc` files.
8. Editors: install VS Code/Cursor/Zed/Vim, apply `machines/presets/{vscode,zed,biome,opencode}/`, copy `~/.config/Code/User/`, `~/.cursor/`, `~/.config/zed/`, `~/.claude/`, `~/.gemini/`, `~/.codex/`, `~/.config/opencode/`, `~/.opencode/`.
9. Reboot / `wsl --shutdown` if WSL, then run §7 checks.

Regenerate this report on demand with: `apt-mark showmanual`, `dpkg -l | grep '^ii' | wc -l` (1338 on source), `snap list`, `brew list --versions`, `bun pm -g ls`, `npm list -g --depth=0`, `sdkmanager --list_installed`, `code --list-extensions`.

---

## 7. Verification checklist

- [ ] `lsb_release -a`, `uname -a`, `java -version`, `node --version`, `bun --version`, `deno --version`, `go version`, `docker --version`, `aws --version`, `pulumi version`, `cloudflared --version`, `psql --version`, `caddy version`, `adb version`, `ffmpeg -version` match §2
- [ ] `git config --global --list`, `gh auth status`, `aws sts get-caller-identity`, `pulumi whoami`, `docker ps`, `adb devices`, `sdkmanager --list_installed` succeed
- [ ] `google-chrome-unstable --version` (or replacement), `code --version`, `opencode --version` (`v2.2.5` on source), `eas --version` succeed
- [ ] Shell PATH contains bun/nvm/brew/cargo/android entries; `echo $JAVA_HOME $ANDROID_HOME` correct
- [ ] No secret values committed: `git status`, `git diff --cached`, plus grep for `gho_`, `ctx7sk-`, `waka_`, `npm_l6f` before push

*Note: `~/.npmrc`, `hosts.yml`, `credentials.json`, `auth.json`, `cert.pem`, `id_ed25519`, `rootCA-key.pem` were read only to confirm paths — values are intentionally omitted here.*
