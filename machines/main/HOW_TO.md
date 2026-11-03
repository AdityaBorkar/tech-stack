# HOW_TO — bootstrap a brand-new Arch Linux machine from `machines/main/`

Standalone home-manager flake. No NixOS system config, no CI here.
It manages **one Linux user home** (`/home/$USER`): packages, dotfiles,
`git`/`gh`/`ssh`/`direnv` config, global `bun` CLIs, and secret-rendered
credentials via `sops-nix`. `services.nix` is an empty stub.

Target state verified against `flake.nix:16-44`, `home.nix:1-119`,
`packages.nix:1-66`, `programs.nix:1-43`, `bun.nix:1-31`.

## 0. What you need from the old machine

1. This repo (push `tech-stack` to a git remote first).
2. The **age private key** matching `.sops.yaml` public key
   `age1gs2gwlraraek3hrhy9ylgddhzs2m4j2fp4sqzewvrx5utglfp5ss75vfn5`
   (`machines/main/.sops.yaml:1-7`). It lives at:
   `~/.config/sops/age/keys.txt` (`home.nix:38`).
   Copy it over USB/SSH — never commit it. Without it, `secrets.yaml`
   (9 keys, `secrets.yaml:1-9`) cannot decrypt and the 6 credential files
   below come out empty.
3. Your `GIT_NAME` / `GIT_EMAIL` (baked into git config at build time,
   `flake.nix:24-29`, `programs.nix:13-21`).

## 1. Prepare the fresh Arch user

```bash
# as root: create user with sudo
useradd -m -G wheel -s /bin/bash <newuser>
passwd <newuser>
# /etc/sudoers via visudo: uncomment %wheel ALL=(ALL:ALL) ALL

# as <newuser>: base tools + updates
sudo pacman -Syu --needed git curl xz sudo base-devel
```

## 2. Install Nix (multi-user) and enable flakes

Prefer the pacman build on Arch (simplest with systemd):

```bash
sudo pacman -S --needed nix
sudo systemctl enable --now nix-daemon.service
```

Then enable flakes for your user (required — this flake has no output
without it):

```bash
# /etc/nix/nix.conf (sudo):
#   experimental-features = nix-command flakes
#   allow-unfree is NOT needed here — flake.nix:20-23 already sets it.
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon.service
nix --version  # expect Nix 2.x
```

Alternative: Determinate Systems installer
`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
— same `/etc/nix/nix.conf` step applies.

## 3. Clone this repo and restore the age key

```bash
git clone <your-remote> ~/repo/tech-stack
cd ~/repo/tech-stack/machines/main

mkdir -p ~/.config/sops/age
chmod 700 ~/.config ~/.config/sops ~/.config/sops/age
# paste the old machine's keys.txt content here, then:
chmod 600 ~/.config/sops/age/keys.txt
```

Key file must contain the `AGE-SECRET-KEY-...` line whose public key is
`age1gs...vfn5`. If the key is lost, generate a new one on any machine
(`nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt`),
replace the key in `.sops.yaml`, and re-encrypt:
`sops updatekeys secrets.yaml` (needs old key or fresh `sops set` values).

## 4. First switch (bootstrap home-manager)

The flake reads `$USER`, `$GIT_NAME`, `$GIT_EMAIL` via `builtins.getEnv`,
so **`--impure` is mandatory** (`flake.nix:19-29`). `home-manager` is not
installed yet, so bootstrap through `nix run`:

```bash
cd ~/repo/tech-stack/machines/main
export GIT_NAME="Your Name" GIT_EMAIL="you@example.com"
# $USER must equal the login user; target is .#$(whoami)
nix run home-manager -- init --switch --flake .#$(whoami) --impure
```

What this does: builds `homeConfigurations.<username>`
(`flake.nix:32-43`), installs ~50 packages (`packages.nix`), symlinks
~19 dotfiles (`home.nix:15-35`), configures git/gh/ssh/direnv
(`programs.nix`), installs 9 global bun CLIs idempotently
(`bun.nix:4-30`), and decrypts `secrets.yaml` into 6 files
(`home.nix:37-118`):

| secret(s) | rendered file | mode |
|---|---|---|
| `aws_*` (4) | `~/.aws/credentials` | 0600 |
| `gh_oauth_token` | `~/.config/gh/hosts.yml` | 0600 |
| `npm_auth_token` | `~/.npmrc` | 0600 |
| `eas_analytics_device_id` | `~/.config/eas-cli-nodejs/user-settings.json` | 0644 |
| `opencode_context7_api_key` | `~/.config/opencode/opencode.json` | 0644 |
| `wakatime_api_key` | `~/.wakatime.cfg` | 0644 |

Source templates with `@@PLACEHOLDERS@@` live under `files/` next to them.

## 5. Post-switch checks

```bash
exec zsh  # or: exec bash
home-manager generations
which git gh node bun go aws opencode zed  # spot-check packages.nix
ls -l ~/.aws/credentials ~/.npmrc ~/.config/gh/hosts.yml  # must exist, 0600
head -2 ~/.aws/credentials  # real keys, no @@...@@ left
```

Arch caveats:

- `docker` from nix is the **client only**. For the daemon:
  `sudo pacman -S docker && sudo systemctl enable --now docker.service`,
  then `sudo usermod -aG docker $USER` and re-login.
- `zsh` is installed but not set as login shell: `chsh -s $(which zsh)`.
- `stateVersion = "25.05"` (`home.nix:6`) — leave it; do not follow the
  latest release on a fresh box.

## 6. Daily use / updates

```bash
cd ~/repo/tech-stack/machines/main
git pull
export GIT_NAME="Your Name" GIT_EMAIL="you@example.com"
home-manager switch --flake .#$(whoami) --impure
nix flake update  # bump nixpkgs/home-manager/sops-nix, then switch again
home-manager generations  # rollback: home-manager switch --rollback
```

`bun.nix` skips already-installed globals (`bun -g list` check), so
re-switches are safe offline except for `nix` fetches.

## Troubleshooting

| symptom | cause / fix |
|---|---|
| `error: GIT_NAME is not set` | `export GIT_NAME/GIT_EMAIL` and keep `--impure` (`flake.nix:26,30`). |
| `attribute 'homeConfigurations."root"'` | ran with `sudo` — `$USER=root`. Run as the real user. |
| `experimental feature 'flakes' is disabled` | missing `/etc/nix/nix.conf` line from §2. |
| `sops … failed to decrypt` / empty credential files | wrong/missing `~/.config/sops/age/keys.txt` (§3), must be `600`. |
| `bun … installing` hangs | network needed once for 9 globals; re-run the switch, it resumes. |
| dirty-tree warning | normal when the repo has uncommitted edits; commit before switching on a new box. |

## File map

`flake.nix` inputs + per-`$USER` output · `home.nix` user, dotfiles, sops
templates · `packages.nix` package list · `programs.nix` git/gh/ssh/direnv ·
`bun.nix` global npm CLIs · `services.nix` empty · `.sops.yaml` age
recipient · `secrets.yaml` 9 encrypted values (sops 3.13.3) ·
`files/` dotfile/credential templates · `flake.lock` pinned inputs.
