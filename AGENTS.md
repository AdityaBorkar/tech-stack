# AGENTS.md

Data-only registry of machine + project blueprints. No app source, tests, or CI here. `registry.json` is the entrypoint; `projects/*.json` are blueprints; `projects/files/` holds payload files copied into generated projects (templates, not runnable here).

## Layout

- `registry.json` — maps for `machines` + `projects` + `github_configs` (not arrays). Every blueprint must have an entry here. Only `machines/main/` is registered; `machines/wsl/` (`.wslconfig`, `wsl.conf`) exists but is unregistered and not Nix-managed. `github-configs/npm-package.json` holds the shared GitHub repo-settings blueprint.
- `projects/<name>.json` — blueprint: `@name` + `@description` + `files[]` (what gets copied) + `file_structure[]` (`src/` + empty `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
- `projects/files/` — payloads grouped by tool (`bunfig/`, `changeset/`, `github/`, `gitignore/`, `husky/`, `knip/`, `oxfmt/`, `oxlint/`, `package/`, `scripts/`, `tsconfig/`, `zed/`, plus flat files). Base variant = default; per-stack variants are `astro`, `tanstack`, `cli-tanstack`, `webext` (not every tool has every variant — check the dir). Manifests are source of truth — e.g. `biome.json` exists but no manifest references it (dead file, toolchain is oxlint + oxfmt).

## Editing blueprints

- `files[]`: `source` is root-relative (`projects/files/<group>/<variant>`), `target` is the destination path. After adding/renaming a preset file, update every manifest referencing it and confirm each `source` exists — a missing source breaks scaffolding.
- `projects/files/package/*.json` and `wrangler.json` are templates with `<...>` placeholders (`name`, `version`, owner/repo URLs, binary name, dependency versions, worker name/domain) — never copy verbatim; every placeholder must be replaced per project.
- `compare.ignore["overrides"]` is set on oxlint/oxfmt entries only. Any golden holding `<...>` placeholders is a template on its own — each slot accepts any per-project value, every other field must match. Keep `compare` groups disjoint.
- Generated-project `verify` (in every `package/*.json`) is `bun format && bun check:lint && bun check:types && bun test` — note this differs from the root `verify` below.
- Every generated `package.json` runs `build: bun ./scripts/build.ts`, but no manifest `files[]` copies `projects/files/scripts/build.ts` — confirm how it reaches generated projects before touching build.

## Machines notes

- `machines/main/flake.nix` requires `GIT_NAME`/`GIT_EMAIL` env vars and `--impure` (`builtins.getEnv`). See `machines/main/HOW_TO.md` for bootstrap.
- `machines/main/secrets.yaml` is sops-encrypted (age key in `.sops.yaml`); private key lives at `~/.config/sops/age/keys.txt` and must never be committed. Without it credential files render empty — including `~/.npmrc`, which carries the private-npm token (see Verify).

## Verify here

- Root has no test runner and no `.oxlintrc.json`/`.oxfmtrc.json` — `lint` is bare `oxlint` (defaults), `format` is `bun fmt` (config in root `bunfig.toml` `[fmt]`). Note the asymmetry: generated projects format with `oxfmt`, this repo formats with `bun fmt`.
- After `bun install`, run `bun run verify` (= `format && lint && validate`). `validate` (`@adistack/conform validate`) checks `registry.json` + blueprints against the `$schema` URLs; it fails before install.
- `@adistack/conform` is private on npm — install needs the `~/.npmrc` token rendered by `machines/main` secrets. A registry 404 means the token is missing/invalid (re-run `home-manager switch`, check `~/.npmrc` has no `@@...@@` left).
- After touching JSON: parse-check it, e.g. `bun -e 'for (const f of ["registry.json","projects/cli-app.json"]) JSON.parse(await Bun.file(f).text())'`.
