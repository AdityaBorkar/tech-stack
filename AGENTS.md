# AGENTS.md

Data-only blueprint registry. No app source, tests, or CI here. `registry.json` is the entrypoint (7 project blueprints, machine `main`, github-config `npm-package`). `projects/*.json` are project manifests; `machines/main.json` is the machine manifest; `github-configs/*.json` are repo-settings blueprints. `*/files/` holds payload goldens copied into generated targets (templates, not runnable here).

## Layout

- Project manifests: `files[]` (copied goldens; `source` is repo-root-relative, `target` is destination-relative, cwd for projects) + `file_structure[]` (existence-only: `src/` + empty `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
- `tanstack-webapp.json` and `tanstack-website.json` differ only in `@name`/`@description` and share `projects/files/package/tanstack.json` — keep them in sync.
- Machine manifest: `params` (`USER`, `GIT_NAME`, `GIT_EMAIL`) + `packages.{pacman,bun}` + `files[]` with `~` targets and optional `mode`. Secrets are per-file `secrets: [...]` plus `@@name@@` placeholders in the golden (e.g. `machines/files/npmrc` holds `@@npm_auth_token@@`); credential files use `mode: "0600"`. Never commit real values.
- `github-configs/npm-package.json`: trunk-based defaults — `defaultBranch: stable`, squash and merge-commit both enabled, required checks `["lint", "format", "types", "conform"]`, 1 approval with code-owner and conversation-resolution required.

## Conform semantics

- `compare.ignore: ["overrides"]` is set on Oxfmt/Oxlint entries only — downstream keeps its own `overrides`, everything else must match.
- `<...>` placeholders in JSON goldens are per-project template slots (all `projects/files/package/*.json` plus `wrangler.json` `name`/`route.pattern`); all other fields must match exactly. (`wxt.config.ts` holds a literal `<extension-id>` but isn't JSON, so it is not treated as a template.)
- Registry path quirk: `registry.json` maps `main` to `./machines/main/`, but on disk the manifest is `machines/main.json` (no `machines/main/` dir) — and the installed conform 0.1.0 schema describes machine entries as `{name, path}` objects while the registry uses plain strings. Don't rename or "fix" either side until conform's resolution is confirmed.

## Verify here

- `bun run verify` is broken here: the second half calls `@adistack/conform` (package name, not a bin → exit 127). The installed bin `adistack-conform validate` reports "No desired state found" (needs a downstream `conform.json`), so it cannot validate this repo. There is no test runner, CI, `conform.json`, or root oxlint/oxfmt configs (those live in downstream templates); the root check is biome.
- What works at root: `./node_modules/.bin/biome check .` (passes; linter off for `**/*.ts`, formatter repo-wide). Keep JSON edits tab-indented and re-run it.
- After any add/rename, confirm every manifest `files[].source` exists on disk — a missing `source` breaks scaffolding, and unreferenced goldens never ship. (All referenced sources exist today.)
- Known gaps, don't paper over: no manifest ships anything under `projects/files/scripts/` — yet every package template's `build` script references `scripts/build.ts` (exists on disk, unshipped), and `cli`'s `verify` references `scripts/verify.ts` plus `build.ts` references `tsconfig.build.json`, neither of which exists at all. Entirely unreferenced on disk: `projects/files/biome.config.json`, `machines/files/.wslconfig`, `machines/files/wsl.conf`. Don't resurrect or delete without checking why.
