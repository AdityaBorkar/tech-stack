# AGENTS.md

Data-only registry of machine + project blueprints. No app source, tests, or CI here. `registry.json` is the entrypoint; `projects/*.json` files are blueprints; `projects/files/` holds grouped payload files copied into generated projects (templates, not runnable here).

## Layout

- `registry.json` — lists `machines[]` + `projects[]`. Every project file must have an entry here.
- `projects/<name>.json` — blueprint: `description` + `files[]` (what gets copied) + `file_structure[]` (empty dirs/files to create, e.g. `src/`, `AGENTS.md`, `README.md`) + `js` (package manager + deps) + optional `github` (only `cli-app` sets one → `files/github-config/npm-package.json`).
- `projects/files/` — payload files grouped by tool (`bunfig/`, `gitignore/`, `husky/`, `knip/`, `oxfmt/`, `oxlint/`, `tsconfig/`, `zed/` subdirs + flat files). Base variant = CLI default; grouped variants per stack (`astro`, `tanstack`, `cli-tanstack`, `webext`). Manifests are source of truth for what gets copied — e.g. `biome.json` exists but no manifest references it (dead file, toolchain is oxlint + oxfmt).
- `machines/main/` — standalone home-manager flake for one Linux user home (packages, dotfiles, `bun` CLIs, sops-rendered secrets). No NixOS system config. See `HOW_TO.md` for bootstrap.
- `machines/wsl/` — Windows/WSL-side config, not Nix-managed.

## Editing blueprints

- `files[]` entries: `source` is root-relative (`projects/files/<group>/<variant>`), `target` is the destination path in the generated project. After adding/renaming a preset file, update every manifest that references it and confirm each `source` exists — a missing source silently breaks scaffolding.
- `projects/files/package/cli.json` is a template with `<...>` placeholders (`name`, `version`, `description`, `keywords`, owner/repo URLs, binary name) — never copy verbatim; every placeholder must be replaced per project.
- `files[]` entries may declare `compare`: `ignore["overrides"]` on oxlint/oxfmt configs, `required` on `package.json` (listed keys like `type`/`scripts`/`files`/`name`/`version`/`bin` must be defined with per-project values, never placeholders). Keep `compare` groups disjoint.
- `js.pm` is `bun` for all blueprints. `bunfig.toml` sets `install.exact = true` and `install.ignore-scripts = true` — deps pin exact versions.

## Conventions baked into presets

- Generated-project verification order (`verify` script in `package/cli.json`): `format` → `check:lint` (`oxlint`) → `check:types` (`tsrs`) → `test` (`bun test`) → `build` (`bun ./scripts/build.ts`). Husky hooks enforce `bun fmt --staged` on pre-commit and `commitlint` on commit-msg.
- `oxlint` bans URL imports (`http(s)://`) and package-protocol imports (`npm:*`, `jsr:*`), and enforces `sort-keys` ascending. `oxfmt`: tabs, width 100, sorted imports (`builtin`/`bun` first), sorted `scripts`.
- Commit messages must follow conventional-commits (commitlint).

## Machines notes

- `machines/main/flake.nix` requires `GIT_NAME`/`GIT_EMAIL` env vars and `--impure` (`builtins.getEnv`).
- `machines/main/secrets.yaml` is sops-encrypted (age key in `.sops.yaml`); the private key lives at `~/.config/sops/age/keys.txt` and must never be committed. Without it the credential files render empty.

## Verify here

- `bun install`, then `bun run lint` (`oxlint`) and `bun run format` (`bun fmt` builtin here — `oxfmt` is not a root dep, only generated projects use the `oxfmt` binary). No test runner in this repo.
- After touching JSON: parse-check it, e.g. `bun -e 'for (const f of ["registry.json","projects/cli-app.json"]) JSON.parse(await Bun.file(f).text())'`.
