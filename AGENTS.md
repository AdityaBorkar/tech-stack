# Conformance blueprints

The language for declaring desired state in this repo comes from `GLOSSARY.md` (synced
from `~/repo/adistack-conform/GLOSSARY.md`). Use its terms — registry, blueprint,
manifest, source, upstream, target, compare rule, template, file structure, secrets
template, allowlist — and the listed _Avoid_ words never appear in manifests.

## Scope

Data-only blueprint registry. No app source, tests, or CI. `registry.json` is the
entrypoint (7 project blueprints, machine `main`, github-config `npm-package`).
`projects/*.json`, `machines/main.json`, `github-configs/*.json` are manifests;
`*/files/` holds payload goldens copied into generated targets (templates, not runnable
here). No `README`, no `opencode.json` at root. Manifest field shapes are enforced by
`$schema` under `node_modules/@adistack/conform/config/` — trust those schemas over
prose when in doubt.

## Verify

- `bun run verify` (`biome check --fix && conform validate`), run from repo root
  (`validate` reads `./registry.json` in the cwd).
- Currently red by design: `machines/main.json` declares `packages.apt`, which the
  pinned `@adistack/conform@0.2.0` schema rejects (it allows only `bun`+`pacman`).
  `apt` support exists in `~/repo/adistack-conform/src/schemas/` but is unreleased —
  do not "fix" by deleting `apt`; bump the pin when a new conform publishes.
- Biome: formatter tab-indent; linter off for `**/*.ts`. Keep JSON edits tab-indented.

## Layout

- Project manifests: `files[]` (`source` repo-root-relative → `target`
  destination-relative) + `file_structure[]` (existence-only: `src/` + empty
  `AGENTS.md`/`README.md`; `web-extension` also creates `entrypoints/` + `public/`).
  After any add/rename, confirm every `files[].source` exists on disk — a missing
  `source` breaks scaffolding, and unreferenced goldens never ship.
- `tanstack-webapp.json` and `tanstack-website.json` differ only in
  `$name`/`$description` and share `projects/files/package/tanstack.json` — keep them
  in sync.
- Machine manifest: `allowlist.pacman` + `packages.{apt,bun,pacman}` + `files[]` with
  `~` targets; `mode` is `0600` on secret files only, omitted elsewhere. Secrets are
  per-file `secrets: [...]` plus `$$NAME$$` placeholders in the golden (e.g.
  `machines/files/npmrc` uses `$$NPM_AUTH_TOKEN$$`) — never commit real values.
- `github-configs/npm-package.json`: `default_branch: main`, squash-only
  (`merge_commit`/`rebase_merge` false), `delete_head_branches`, linear history +
  `dismiss_stale`, `require_code_owner`, `required_approvals: 0`, no
  conversation-resolution requirement.

## Conform semantics

- `compare.ignore: ["overrides"]` is set on Oxfmt/Oxlint entries only, in every project
  manifest — downstream keeps its own `overrides`, everything else must match exactly.
- Two placeholder systems, do not mix: `<...>` template slots in all
  `projects/files/package/*.json` plus `wrangler.json` `name`/route `pattern`
  (per-project values); `$$VAR$$` secret placeholders in machine goldens (rendered
  from the machine's secrets). `wxt.config.ts` holds a literal `"<extension-id>"` but
  isn't JSON, so it is not a template slot.

## Known gaps, don't paper over

- No manifest ships `projects/files/scripts/build.ts`, yet every package template's
  `build` runs it; it calls `tsc -p tsconfig.build.json` (missing — `tsconfig/` has
  only astro/base/cli-tanstack/webext). `cli`'s `verify` runs `scripts/verify.ts`
  (missing entirely).
- Entirely unreferenced, never ship: `projects/files/biome.config.json`,
  `machines/files/.wslconfig`, `machines/files/wsl.conf`.
