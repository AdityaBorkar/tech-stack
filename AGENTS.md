# AGENTS.md

Data-only registry of machine + project blueprints. No app source, tests, or CI here. `registry.json` is the entrypoint; `projects/*.json` are blueprints; `projects/files/` holds payload files copied into generated projects (templates, not runnable here).

## Layout

- `registry.json` — lists `machines[]` + `projects[]`. Every blueprint must have an entry here. Only `machines/main/` is registered; `machines/wsl/` (`.wslconfig`, `wsl.conf`) exists but is unregistered and not Nix-managed.
- `projects/<name>.json` — blueprint: `description` + `files[]` (what gets copied) + `file_structure[]` (`src/` dir + empty `AGENTS.md`/`README.md` files; `web-extension` also creates `entrypoints/`) + optional `github` (only `cli-app` sets one → `files/github-config/npm-package.json`).
- `projects/files/` — payloads grouped by tool (`bunfig/`, `gitignore/`, `husky/`, `knip/`, `oxfmt/`, `oxlint/`, `tsconfig/`, `zed/` + flat files). Base variant = default; per-stack variants (`astro`, `tanstack`, `cli-tanstack`, `webext`). Manifests are source of truth — e.g. `biome.json` exists but no manifest references it (dead file, toolchain is oxlint + oxfmt).

## Editing blueprints

- `files[]`: `source` is root-relative (`projects/files/<group>/<variant>`), `target` is the destination path. After adding/renaming a preset file, update every manifest referencing it and confirm each `source` exists — a missing source silently breaks scaffolding.
- `projects/files/package/*.json` and `wrangler.json` are templates with `<...>` placeholders (`name`, `version`, owner/repo URLs, binary name, dependency versions, worker name/domain) — never copy verbatim; every placeholder must be replaced per project.
- `compare.ignore["overrides"]` is set on oxlint/oxfmt entries only. Any golden holding `<...>` placeholders is a template on its own — each slot accepts any per-project value, every other field must match. Keep `compare` groups disjoint.
- `bunfig.toml` sets `install.exact = true` and `install.ignore-scripts = true`. Exception: `bunfig/astro.toml` sets `[run] bun = false` (Cloudflare adapter hangs under `bun`); do not "fix" it back to `true`.
- Generated-project `verify` (in every `package/*.json`) is `bun format && bun check:lint && bun check:types && bun test` — `build` (`bun ./scripts/build.ts`) is intentionally excluded, run it separately.

## Conventions baked into presets

- Husky hooks: pre-commit runs `bun fmt --staged`, commit-msg runs `bun commitlint --edit $1`. Commit messages must follow conventional-commits.
- `oxlint` bans URL imports (`http(s)://`) and package-protocol imports (`npm:*`, `jsr:*`), enforces `sort-keys` ascending. `oxfmt`: tabs, width 100, sorted imports (`builtin`/`bun` first), sorted `scripts`.

## Machines notes

- `machines/main/flake.nix` requires `GIT_NAME`/`GIT_EMAIL` env vars and `--impure` (`builtins.getEnv`). See `machines/main/HOW_TO.md` for bootstrap.
- `machines/main/secrets.yaml` is sops-encrypted (age key in `.sops.yaml`); private key lives at `~/.config/sops/age/keys.txt` and must never be committed. Without it credential files render empty.

## Verify here

- Root has no test runner and no `.oxlintrc.json`/`.oxfmtrc.json` — `lint` is bare `oxlint` (defaults), `format` is `bun fmt` (config in root `bunfig.toml` `[fmt]`).
- After `bun install`, run `bun run verify` (= `format && lint && validate`). `validate` (`@adistack/conform validate`) checks `registry.json` + blueprints against the `$schema` URLs; it fails before install.
- After touching JSON: parse-check it, e.g. `bun -e 'for (const f of ["registry.json","projects/cli-app.json"]) JSON.parse(await Bun.file(f).text())'`.
