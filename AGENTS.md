# AGENTS.md

Data-only blueprint registry. No app source, tests, or CI here. `registry.json` is the entrypoint; `projects/*.json` are project blueprints; `machines/main.json` is the machine blueprint; `github-configs/*.json` are repo-settings blueprints. `*/files/` holds payload goldens copied into generated targets (templates, not runnable here).

## Layout

- `projects/<name>.json` — `@name` + `@description` + `files[]` (copied goldens) + `file_structure[]` (existence-only: `src/` + empty `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
- `machines/main.json` — `params` (`USER`, `GIT_NAME`, `GIT_EMAIL`) + `packages.{pacman,bun}` + `files[]` with `~`-targets and optional `mode` + `secrets[]`. Note: `registry.json` maps `main` to `./machines/main/`, but on disk the manifest is `machines/main.json` with payloads in `machines/files/` (no `machines/main/` dir) — confirm conform's resolution before renaming either side.
- `files[]` entries: `source` is repo-root-relative (`projects/files/<group>/<file>`); `target` is destination-relative (`~` expands for machines, cwd for projects). A `source` that doesn't exist breaks scaffolding — confirm every one after adds/renames.
- Only manifest-referenced payloads ship. Unreferenced (dead) today: `projects/files/biome.config.json`, `projects/files/scripts/build.ts`, `machines/files/.wslconfig`, `machines/files/wsl.conf`. Don't resurrect or delete without checking why.

## Conform semantics

- `compare.ignore: ["overrides"]` is set on Oxfmt/Oxlint entries only — downstream keeps its own `overrides`, everything else must match.
- A JSON golden holding `<...>` placeholders is a template: each slot accepts any per-project value, all other fields must match, and a verbatim copy never passes. Templates: all `projects/files/package/*.json` + `projects/files/wrangler.json`. (`wxt.config.ts` holds a literal `<extension-id>` but isn't JSON, so it is not treated as a template.)
- Machine secrets are per-file `secrets: [...]` plus `@@name@@` placeholders in the golden (e.g. `machines/files/npmrc` holds `@@npm_auth_token@@`). Never commit real values.

## Verify here

- No test runner, no `.oxlintrc.json`/`.oxfmtrc.json`, no root `opencode.json`/`conform.json`. `lint` is bare `oxlint`; `format` is `bun fmt` (tabs, width 100, import sorting in `bunfig.toml [fmt]`).
- `bun run verify` does not pass in this repo: the `validate` script invokes `@adistack/conform`, but the installed binary is `adistack-conform` (command-not-found), and `validate` needs a downstream `conform.json` (exits 2 with "No desired state found" here). For local edits run `bun run format && bun run lint` plus a JSON parse-check, e.g. `bun -e 'for (const f of ["registry.json","projects/cli-app.json"]) JSON.parse(await Bun.file(f).text())'`.
- Generated-project `verify` differs from root: most `package/*.json` templates use `bun format && bun check:lint && bun check:types && bun test`; `cli-tanstack` uses `bun scripts/verify.ts`.
