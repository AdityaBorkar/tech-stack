# CONFIG — Files to Backup / Migrate

Source: `REPORT.md` §2 (per-tool config), §4 (master list), §5 (secrets).
Rule: copy configs, reinstall payloads, re-auth secrets (never commit values).

## 1. Shell / identity

| Path | Belongs to | Action |
|---|---|---|
| `~/.bashrc`, `~/.profile`, `~/.bash_logout` | shell, PATH/JAVA_HOME/ANDROID_HOME (§1) | copy, then adjust |
| `~/.gitconfig` | git `2.43.0` | copy |
| `~/.ssh/` (`id_ed25519*`, `known_hosts*`) | ssh | copy via encrypted medium; `chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_*`; §5 secret |
| `~/.bash_logout`, `~/.lesshst`, `~/.wget-hsts`, `~/.node_repl_history`, `~/.python_history`, `~/.viminfo`, `~/.motd_shown`, `~/.sudo_as_admin_successful` | history/state | copy (optional) |
| `~/.npmrc` | npm | re-auth, do not copy value (§5) |
| `~/.wakatime.cfg`, `~/.wakatime/` | wakatime | re-enter `api_key`, copy rest (§5) |
| `~/.gnupg/` | gpg | absent on source — create if needed |
| `~/.pki/`, `~/.local/share/keyrings/` | gnome-keyring / browsers | copy |

## 2. Cloud / dev / AI tools

| Path | Belongs to | Action |
|---|---|---|
| `~/.config/gh/` (`hosts.yml`) | gh `2.45.0` | copy dir, `gh auth login` anew (§5) |
| `~/.config/opencode/`, `~/.opencode/`, `~/.local/share/opencode/` | opencode `v2.2.5` | copy configs, re-auth `auth.json`/`opencode.json` (§5) |
| `~/.claude/`, `~/.claude.json` | Claude Code | copy, re-auth oauth section (§5) |
| `~/.gemini/` | Gemini CLI | copy, re-auth oauth (§5) |
| `~/.codex/` | Codex CLI | copy, re-auth oauth (§5) |
| `~/.cursor/`, `~/.cursor-server/` | Cursor | copy |
| `~/.copilot/`, `~/.config/github-copilot/` | Copilot | copy |
| `~/.config/Code/` (`User/settings.json`), `~/.vscode-server/`, `~/.vscode-remote-containers/` | VS Code `1.136.1` (Windows host) | copy WSL side + `%APPDATA%\Code\User\settings.json` |
| `~/.config/zed/`, `~/.zed_server/` | Zed | copy |
| `~/.config/githits/`, `~/.githits/` | codebase-memory / githits | copy |
| `~/.codedb/`, `~/.claude/hooks/codedb-*.sh` | codedb (`~/bin/codedb`) | copy |
| `~/.codeium/`, `~/.agents/`, `~/.config/agents/`, `~/.config/crush/`, `~/.config/goose/`, `~/.config/devin/`, `~/.factory/`, `~/.dsh/` | misc agents | copy if present |
| `~/.config/docker/`, `~/.docker/config.json` | docker `28.5.1` rootless | copy, `docker login` anew (§5, `credsStore=desktop.exe`) |
| `~/.aws/` (`config` + `credentials`) | aws-cli `2.39.3` (`region=ap-south-1`) | copy `config`, re-enter `credentials` (§5) |
| `~/.pulumi/` (`credentials.json`, `stacks/`, `workspaces/`, `plugins/`, `meta.yaml`) | pulumi `3.273.0` | copy stacks, `pulumi login` anew (§5) |
| `~/.cloudflared/` (`cert.pem`), `~/.config/cloudflare/` | cloudflared `2026.10.7` | copy config, re-issue `cert.pem` (§5) |
| `~/.config/act/` | act `0.2.92` | copy |
| `~/.config/pulse/` | pulse | copy |
| `~/bin/dockerd-rootless.sh`, `~/bin/docker*` | docker static binaries | copy or reinstall + compose plugin |

## 3. Runtimes / languages

| Path | Belongs to | Action |
|---|---|---|
| `~/.nvm/`, `~/.npm/`, `~/.npmrc`, project `.nvmrc` | node `v24.15.0` / nvm | reinstall `nvm install 24.15.0`, copy `.npmrc` path only (§5) |
| `~/.config/yarn/`, `~/.local/share/pnpm/` | yarn `1.22.22` / pnpm `10.33.0` | copy |
| `~/.bun/` (`bin/` + `install/global/`), `~/.config/bun` | bun `1.4.4` | reinstall (`bun add -g ...` per §3), copy `bin/` list |
| `~/.deno/` + `~/.deno/env` (`DENO_DIR=~/.cache/deno`) | deno `2.5.4` | reinstall, copy `env` |
| `~/.cargo/`, `~/.rustup/` (`~/.cargo/env`) | rustup (no toolchain) | copy, run `rustup default stable` |
| `~/go/`, `~/.config/go/` | go `1.27.3` (`GOPATH=~/go`) | copy `~/go/`, reinstall toolchain |
| `~/.gradle/` | gradle `4.4.1` / java | copy (10 entries on source) |
| `~/.cache/` (selective: `pip/`, `deno`) | pip / deno | copy selectively, recreate venvs |
| `~/.local/share/pipx/` | pipx (`codegraphcontext`) | reinstall venvs |
| `~/.local/share/mkcert/` (`rootCA.pem` + `rootCA-key.pem`), `~/.vite-plugin-mkcert/` | mkcert `1.4.4` | copy `rootCA.pem`, re-issue key securely (§5) |
| `~/.config/caddy/` (`autosave.json`), `/etc/caddy/Caddyfile` | caddy `2.6.2` | merge `/etc` file, copy user config |
| `~/.config/eas-cli-nodejs/`, `~/.expo/` | eas-cli `27.2.0` / expo | copy, `eas login` anew (§5) |
| `~/.config/htop/` | htop | copy |
| `~/.config/nx/`, `~/.nx/`, `~/.config/turborepo/`, `~/.config/tanstack/`, `~/.config/astro/`, `~/.biome/`, `~/.config/steel*/` | JS tooling caches | copy if present |
| `/home/linuxbrew/.linuxbrew/` | Linuxbrew | reinstall, don't copy |
| `~/.agent-browser/` | agent-browser `0.37.1` | copy |
| `~/.local/share/codebase-memory*` | codebase-memory-mcp | copy if present |

## 4. Android / browsers / system

| Path | Belongs to | Action |
|---|---|---|
| `~/android/`, `~/.android/` | Android SDK (`ANDROID_HOME`) build-tools 30/35/36, ndk `27.1.12297006` | copy tree or `sdkmanager` re-download |
| `~/.config/google-chrome/`, `~/.config/google-chrome-unstable/`, `~/.config/google-chrome-for-testing/`, `~/.cache/` | Chrome Dev `159.0.8130.0` | copy |
| `~/.config/Electron/` | electron apps | copy |
| `~/.local/share/applications/` | desktop entries | copy if customized |
| `~/.fonts/`, `~/.local/share/fonts/`, `~/.config/fontconfig/` | fonts (157 families) | copy |
| `~/tesseract/`, `~/.EasyOCR/` | easyocr / tesseract data | copy |
| `~/.psql_history`, `~/.pgpass`, `~/.pg_service.conf` | psql `16.15` | copy (create `pg_service.conf` if needed) |
| `~/.config/systemd/user/` (`openusage-telemetry.service`, `uma-machine.service`) | user services | copy |
| `~/.config/dconf/` | dconf | copy partial |
| `/etc/wsl.conf`, `/etc/dnsmasq.conf`, `/etc/dnsmasq.d/`, `/etc/cockpit/` | system (`systemd=true`, dnsmasq `2.91`, cockpit `314`) | merge on target |
| `~/.azure -> /mnt/c/Users/adity/.azure` | azure (empty symlink) | recreate on target |

## 5. Project / secrets-adjacent (copy carefully, never commit)

`~/.EasyOCR/`, `~/tesseract/`, `~/.config/ggshield/`, `~/.config/docucraft*/`, `~/.config/tokscale/`, `~/.config/uma-machine/`, `~/.config/tally-gateway/`, `~/.config/vale/`, `~/.config/bifrost/`, `~/.config/kiset/`, `~/.config/rtk/`, `~/.config/steel*/`, `~/.config/react-doctor-nodejs/`, `~/.config/nextjs-nodejs/`, `~/.config/*-nodejs/`.

## 6. Repo presets to apply last

`machines/presets/vscode/settings.json`, `machines/presets/zed/settings.json`, `machines/presets/biome/settings.json`, `machines/presets/opencode/` (`config.json`, `agents/`, `commands/`, `skills/`, `tui.json`), `machines/presets/adb/README.md`, `machines/presets/wsl/`.
