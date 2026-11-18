# AGENTS.md

Data-only blueprint registry. No app source, tests, or CI. `registry.json` is the entrypoint (7 project blueprints, machine `main`, github-config `npm-package`). `projects/*.json`, `machines/main.json`, `github-configs/*.json` are manifests; `*/files/` holds payload goldens copied into generated targets (templates, not runnable here). No `README`, no `opencode.json` at root.

## Verify

- `bun run verify` (= `biome check --fix && conform validate`) — both pass clean; run after any manifest or golden edit.
- Biome: formatter tab-indent; linter off for `**/*.ts`. Keep JSON edits tab-indented.
- After any add/rename, confirm every manifest `files[].source` exists on disk — a missing `source` breaks scaffolding, and unreferenced goldens never ship. Quick check: resolve each `files[].source` repo-root-relative.

## Layout

- Project manifests: `files[]` (`source` repo-root-relative → `target` destination-relative) + `file_structure[]` (existence-only: `src/` + empty `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
- `tanstack-webapp.json` and `tanstack-website.json` differ only in `$name`/`$description` and share `projects/files/package/tanstack.json` — keep them in sync.
- Machine manifest: `allowlist.pacman` + `packages.{apt,bun,pacman}` + `files[]` with `~` targets; `mode` is `0600` on secret files only, omitted otherwise. Secrets are per-file `secrets: [...]` plus `@@name@@` placeholders in the golden (e.g. `machines/files/npmrc` uses `@@npm_auth_token@@`); `machines/secrets.yaml` is empty — never commit real values. `packages.apt` omits pacman entries with no apt equivalent (`aws-cli-v2`, `bun`, `fastfetch`, `zed`, `zsh-completions`).
- `github-configs/npm-package.json`: `default_branch: main`, squash-only (`merge_commit`/`rebase_merge` false), `delete_head_branches`, linear history + `dismiss_stale`, `require_code_owner`, `required_approvals: 0`, no conversation-resolution requirement.

## Conform semantics

- `compare.ignore: ["overrides"]` is set on Oxfmt/Oxlint entries only, in every project manifest — downstream keeps its own `overrides`, everything else must match exactly.
- `<...>` placeholders are per-project template slots in all `projects/files/package/*.json` plus `wrangler.json` `name`/route `pattern`. (`wxt.config.ts` holds a literal `"<extension-id>"` but isn't JSON, so it is not a template slot.)

## Known gaps, don't paper over

- No manifest ships `projects/files/scripts/build.ts`, yet every package template's `build` runs `scripts/build.ts`, which calls `tsc -p tsconfig.build.json` (missing; `tsconfig/` has only astro/base/cli-tanstack/webext). `cli`'s `verify` runs `scripts/verify.ts` (missing entirely).
- Entirely unreferenced, never ship: `projects/files/biome.config.json`, `machines/files/.wslconfig`, `machines/files/wsl.conf`.
