# AGENTS.md

Data-only blueprint registry. No app source, tests, CI, or `conform.json` here. `registry.json` is the entrypoint (7 project blueprints, machine `main`, github-config `npm-package`). `projects/*.json`, `machines/main.json`, `github-configs/*.json` are manifests; `*/files/` holds payload goldens copied into generated targets (templates, not runnable here).

## Layout

- Project manifests: `files[]` (copied goldens; `source` is repo-root-relative, `target` is destination-relative) + `file_structure[]` (existence-only: `src/` + empty `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
- `tanstack-webapp.json` and `tanstack-website.json` differ only in `$name`/`$description` and share `projects/files/package/tanstack.json` — keep them in sync.
- Machine manifest: `allowlist.pacman` + `packages.{pacman,bun}` + `files[]` with `~` targets and optional `mode` (`0600`/`0644` only). Secrets are per-file `secrets: [...]` plus `@@name@@` placeholders in the golden (e.g. `machines/files/npmrc`); never commit real values.
- `github-configs/npm-package.json`: `default_branch: main`, squash-only (`merge_commit`/`rebase_merge` false), `delete_head_branches`, linear history + `dismiss_stale`, `require_code_owner`, `required_approvals: 0`, no conversation-resolution requirement.

## Conform semantics

- `compare.ignore: ["overrides"]` is set on Oxfmt/Oxlint entries only — downstream keeps its own `overrides`, everything else must match exactly.
- `<...>` placeholders are per-project template slots in all `projects/files/package/*.json` plus `wrangler.json` `name`/`route.pattern`. (`wxt.config.ts` holds a literal `<extension-id>` but isn't JSON, so it is not a template slot.)
- Registry bug: `registry.json` maps `main` to `./machines/main/`, but on disk the manifest is `machines/main.json`. `conform validate` (0.2.0) rejects the directory form — fix the entry to `./machines/main.json`.

## Verify here

- `bun run verify` is broken: the second half calls `@adistack/conform` (package name, not a bin → exit 127). Run instead: `./node_modules/.bin/biome check .` (passes; linter off for `**/*.ts`, formatter tab-indent) and `./node_modules/.bin/conform validate`.
- Keep JSON edits tab-indented and re-run biome. After any add/rename, confirm every manifest `files[].source` exists on disk — a missing `source` breaks scaffolding, and unreferenced goldens never ship.
- Known gaps, don't paper over: no manifest ships anything under `projects/files/scripts/` — yet every package template's `build` runs `scripts/build.ts` (exists on disk, unshipped), `cli`'s `verify` runs `scripts/verify.ts` (missing), and `build.ts` calls `tsc -p tsconfig.build.json` (missing; `tsconfig/` has only astro/base/cli-tanstack/webext). Entirely unreferenced: `projects/files/biome.config.json`, `machines/files/.wslconfig`, `machines/files/wsl.conf`.
