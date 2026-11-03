# AGENTS.md

Data-only registry. No root `package.json`, no test/lint/build runner, no CI here. Toolchain configs under `projects/$presets/` are templates for generated projects — not runnable here.

## Layout

- `registry.json` — entrypoint listing `machines[]` + `projects[]`.
- `machines/main/` — home-manager flake (`flake.nix`, `home.nix`, `packages.nix`, `programs.nix`, `bun.nix`, `services.nix` empty stub, `files/` dotfile payloads, sops-encrypted `secrets.yaml`).
- `machines/wsl/` — Windows-side `wsl.conf` / `.wslconfig`, not Nix.
- `projects/cli-app/manifest.json` — only non-empty blueprint: `description` + `files[]` (10 entries, `source: "../$presets/..."`). The other four manifests (`astro-website`, `cli-tanstack-webapp`, `tanstack-webapp`, `tanstack-website`) are `{}` stubs.
- `projects/$presets/` — flat payload files copied to new projects. Literal `$` in dirname: quote in shell (`"projects/\$presets/..."`). `package.json` is a template with `<placeholders>`.
- `TODO.md` — validate-command wishlist + manual steps Nix doesn't cover (docker login, cloudflared cert, ssh key copy).

## Stale path ref (do not copy)

- `registry.json` `machines[0].path` says `./machine/main/` (singular); real dir is `machines/main/` (plural). Project paths also mix trailing slashes.

## Checks

- `registry.json` and `projects/*/manifest.json` are strict JSON: `python3 -m json.tool <file>`.
- `$presets/*.json` are tool-consumed, not all strict JSON (`biome.json` has a trailing comma — `json.tool` fails on it). Don't "fix" that.
- Generated-project verify order (from `$presets/package.json` `scripts`, runs in generated repos only): `bun format && bun check:lint && bun check:types && bun run build`.

## Editing machine blueprint

- `files/` is source of truth for `home.file` in `home.nix`. New dotfile: add file under `files/` + entry in `home.nix`.
- Secrets: `files/` templates use `@@NAME@@` placeholders; real values live only in sops-encrypted `secrets.yaml`, wired via `sops.templates` in `home.nix`. Never commit real tokens. Rotate with `sops secrets.yaml` from `machines/main` (age key at `~/.config/sops/age/keys.txt`, recipients in `.sops.yaml`), then re-apply. Keep `secrets.yaml` keys, `home.nix` template names, and `files/` placeholders in sync.
- Apply from `machines/main` requires `--impure` plus env vars — `flake.nix` throws without `GIT_NAME`/`GIT_EMAIL`, username comes from `$USER`.
- `programs.nix`: git `init.defaultBranch = "dev"`, `pull.rebase = false`; `gh` uses `https` with `co = "pr checkout"` alias.
- Bun globals (`opencode`, `eas-cli`, `githits`, `expect-cli`, context7-mcp, pi agents) are installed by `bun.nix` `home.activation`, not manually.

## Editing project presets

- Blueprint `files[]` entries use `source` relative to the manifest dir (`../$presets/<file>`) and `target` as the destination path in the generated project.
- Template husky hooks: `husky-commit-msg` runs `bun commitlint --edit $1`, `husky-pre-commit` runs `bun fmt --staged`. Commit types allowed by `$presets/commitlint.config.json`: `build/chore/ci/docs/feat/fix/perf/refactor/revert/test/wip`.
