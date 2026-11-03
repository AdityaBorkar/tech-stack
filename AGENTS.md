# AGENTS.md

Data-only registry. No root `package.json`, no test/lint/build runner, no CI. Only check available here is JSON validation: `python3 -m json.tool <file>` or `jq empty <file>`. There is no repo `validate` command (see `TODO.md`). `bun`/`verify` scripts live only in `projects/$presets/package.json` as a template for generated projects — not runnable here.

## Layout

- `registry.json` — entrypoint listing `machines[]` + `projects[]`.
- `machines/main/` — home-manager flake (`flake.nix`, `home.nix`, `packages.nix`, `programs.nix`, `services.nix` empty stub, `files/` dotfile payloads, `secrets.yaml` sops-encrypted).
- `machines/wsl/` — Windows-side `wsl.conf`/`.wslconfig`, not Nix.
- `projects/<name>/manifest.json` — blueprint (`type: project.blueprint`, `presets: [...]`). Only `cli-app` is fully specified (11 presets); the other four blueprints list just `oxlint` (stubs).
- `projects/$presets/` — flat preset payloads deployed to new projects. Literal `$` in dirname: quote it in shell (`"projects/\$presets/..."`).
- `projects/cli-app/manifest-2.json` — preset-package index (`type: project.presets`).

## Stale refs (do not copy literally)

- `registry.json` `machines[0].path` says `./machine/main/` (singular); real dir is `machines/main/` (plural). Project paths also mix trailing slashes.
- `projects/cli-app/manifest-2.json` `path` fields still say `project/presets/<group>/<file>`; real files are flat under `projects/$presets/<file>`. `target: "docs: ..."` entries are docs-only, not file copies.

## Editing project presets/blueprints

- Keep `$schema`/`type`/`name` fields; blueprint `presets` names must match a package `name` in `manifest-2.json`.
- Generated-project `verify` order is `format && check:lint && check:types && build` (see `projects/$presets/package.json` `scripts`).

## Editing machine blueprint

- `files/` is source of truth for `home.file` in `home.nix`. New dotfiles: add file under `files/` + entry in `home.nix`.
- Secrets: `files/` templates use `@@PLACEHOLDER@@`; values live only in sops-encrypted `machines/main/secrets.yaml`, wired via `sops.templates` in `home.nix`. Never commit real tokens. Rotate with `sops secrets.yaml` from `machines/main` (age key at `~/.config/sops/age/keys.txt`, recipients in `.sops.yaml`); keep `secrets.yaml` keys, `home.nix` template names, and `files/` placeholders in sync.
- Apply from `machines/main` requires `--impure` plus env vars — `flake.nix` throws without `GIT_NAME`/`GIT_EMAIL` (`builtins.getEnv`), username comes from `$USER`.
- `programs.nix` sets git `init.defaultBranch = "dev"`; git credential helpers come from the `gh` module default (`gitCredentialHelper`, nix-store `gh`).
- `TODO.md` lists steps Nix does not cover: `rustup default stable`, nvm/bun/npm globals (`agent-browser`, EAS/Expo, context7-mcp, githits, expect-cli), pip ML stack, Android SDK, `mkcert -install`, system units, `docker login`, cloudflared/ssh setup.

## Commits

History uses conventional types from `projects/$presets/commitlint.config.json` (`build/chore/ci/docs/feat/fix/perf/refactor/revert/test/wip`). No repo-level hook config.
