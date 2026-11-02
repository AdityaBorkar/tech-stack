---
description: Reanalyze repo to recommend relevant NPM packages above 10k weekly downloads that abstract functionality
---

Recommend NPM packages that are relevant and highly helpful to abstract functionalities in this repo.

Scope: $ARGUMENTS

If $ARGUMENTS is empty, analyze the entire repo. If $ARGUMENTS names a path, package, workspace, or focus area (e.g. `auth`, `validation`, `date handling`, `frontend/utils`), scope the deep-dive to that area but still briefly audit the repo-wide baseline.

## Explicit non-goals (out of scope — do not do these)

- Do NOT check for updates, upgrades, version bumps, or outdated status of the current list of packages in the repo.
- Do NOT recommend replacing, swapping, or migrating from one already-installed package to another.
- Do NOT recommend major-version migrations, codemods, or breaking-change upgrades.
- Inventory existing dependencies ONLY to avoid recommending a duplicate of something already covered. That inventory is not an upgrade audit and must not appear as upgrade advice in the report.
- If a capability is already covered by an existing direct dependency, mark it as covered and move on. Do not compare the existing package against alternatives.

## Neutrality rules (no package bias)

- This prompt names zero recommendable packages. Do not treat any well-known library as a default answer.
- Discover candidates from the registry per abstraction area at run time. For each area, find and compare at least 2–3 real candidates before picking one to recommend.
- Selection must be justified by observed repo evidence + verified weekly downloads + maintenance signals + runtime / platform fit + type / module-format fit. Never select on popularity, familiarity, or training-data priors alone.
- When two candidates solve the same observed problem, state the trade-off explicitly and pick the better fit for this repo. Higher downloads alone is not a sufficient tiebreaker if bundle size, module format, type support, or platform compatibility clearly favors the other.
- Do not invent, guess, or hallucinate package names, download counts, or API examples. Every recommended package name, version hint, download count, and usage snippet must be verified against the registry / docs at run time.

## Phase 1 — In-depth repo discovery (do this first, evidence-based)

Do a complete, read-only analysis. Do not install anything or edit code. Use file reads, glob, and search — do not guess the stack.

1. Detect stack, workspace layout, and package manager:
   - Every `package.json` in the repo (root + each workspace / app / package), including `dependencies`, `devDependencies`, `peerDependencies`, `optionalDependencies`, `scripts`, `engines`, `packageManager` field.
   - Lockfile per manager (`package-lock.json`, `pnpm-lock.yaml` / `pnpm-workspace.yaml`, `yarn.lock` / `.yarnrc.yml`, `bun.lock`), Node / Bun / Deno version, monorepo vs single package (npm / pnpm / yarn / bun workspaces, plus Turborepo / Nx / Lerna / changesets where present).
   - Language(s) and module setup: TypeScript / JavaScript version, `tsconfig` strictness / `module` / `moduleResolution`, ESM vs CJS vs dual, JSX transform, lint / format config.
   - App framework(s) per workspace — detect all that apply, do not assume a single stack:
     - Web UI: React, Solid, Vue, Svelte, Angular, plus meta-frameworks / bundlers (Next.js, Remix / React Router, Astro, Vite, SolidStart, Nuxt, SvelteKit, Qwik, plain Vite / webpack / rspack / esbuild setups).
     - Mobile: React Native (bare vs Expo — check `expo` config, `app.json` / `app.config`, Metro config, Hermes vs JSC, Expo Go constraints, native-module / config-plugin needs).
     - Desktop: Electron (identify `main` vs `preload` vs `renderer` entry points, `contextIsolation` / `sandbox` / Node-integration settings, IPC patterns), other wrappers where present.
     - Backend / API: Express / Fastify / Hono / Nest / Koa / Node http / server actions / loaders / edge functions.
     - CSS / styling approach, test runner / e2e setup, build tool per workspace.
2. Build a runtime-constraint map per workspace:
   - Browser DOM vs Node vs edge / serverless vs React Native (no DOM, limited stdlib, native bridges) vs Electron main (Node) vs Electron renderer (browser + IPC, no direct Node with context isolation) vs Electron preload (limited bridge surface) vs SSR / SSG (no `window` at import time).
   - Bundle-sensitive (client, mobile, renderer, edge) vs not (server, scripts, tooling). Note Metro vs web-bundler differences and any Node-core-import restrictions.
   - Record this map; every later recommendation must state which runtime(s) it applies to and why it is safe there.
3. Inventory existing dependencies (dedupe guard only, not an upgrade audit):
   - List all direct deps / devDeps per workspace and what each is used for (grep imports to confirm actually used vs dead).
   - Use this only to skip areas already covered. Do not comment on whether a version is old, new, or needs upgrading. Do not output version-bump advice.
4. Find abstraction opportunities (at least 5–10 representative source files, spread across workspaces if monorepo):
   - Entry points, `src/utils/*`, `src/lib/*`, `src/helpers/*`, `hooks/*`, components, store / state files, API routes / server actions / loaders, validation schemas, date/time handling, string/case transforms, array/collection ops, async/retry/debounce/throttle, caching, logging, config/env parsing, crypto/ids, file handling, CLI arg parsing, IPC / deep-link / notification / storage / permission helpers (mobile / desktop), testing mocks.
   - Look for: hand-rolled debounce / throttle / retry / sleep / groupBy / chunk / deepClone / deepEqual / pick / omit / capitalize / slug generation, custom date formatting / diffing / timezone handling, custom validation regexes, custom fetch wrappers without retry / timeout / abort, custom env parsing without schema, custom logger around `console.log`, custom event emitter, custom least-recently-used cache, copy-pasted snippets across 2+ files, platform-branching helpers that could be abstracted safely.
5. Record baseline as a table: Abstraction area | Hand-rolled or fragmented implementation (with `file_path:line` evidence) | Workspace + runtime(s) affected | Current dep if any (name + version, covered yes/no — no upgrade commentary) | Abstraction payoff (dedupe / correctness / types / maintenance).

## Phase 2 — Neutral recommendation discovery (only for observed gaps)

Recommend concrete, installable NPM packages — not vague advice. Only open a category if you observed hand-rolled or fragmented code for it in this repo. Do not force-fill categories.

Evaluate capability areas neutrally (non-exhaustive, derive from what you actually find):

1. Collection / object / array helpers and general utilities.
2. Schema validation / parsing / type-safe boundaries.
3. Date / time / timezone handling.
4. Data fetching, async control flow (retry / timeout / abort / concurrency / debounce / throttle / caching of async work).
5. String / case / slug / ID generation.
6. Client / cross-platform state and immutable-update / data-structure helpers.
7. Config / env / CLI / process / IPC helpers (Node / tooling / Electron-main only where applicable).
8. Logging / observability / error-reporting / styling of CLI output.
9. Testing / mocking / fake-data / property-based helpers (dev-only).
10. Framework / platform helpers specific to the detected stacks (e.g. UI-framework hook collections, server-framework middleware, data-table / data-fetching helpers, mobile storage / permission / notification helpers, desktop shell helpers) — only if the repo shows the corresponding pattern and the candidate is compatible with that runtime.

Discovery protocol per area:

- Search the registry for the capability; shortlist 2–3 real, installable candidates that plausibly fit the observed code and the runtime map.
- Compare on: verified weekly downloads, last-publish freshness, issue / maintenance health, bundled TypeScript types, ESM + CJS (or correct format for this repo: ESM-first for web / Metro-compatible for mobile / correct Electron main-vs-renderer split), tree-shakeability / import granularity, bundle cost for client-sensitive runtimes, platform compatibility (DOM-free / SSR-safe / edge-safe / Expo Go-compatible / prebuild-free where required / Electron main-vs-renderer correct), and API fit to the cited files.
- Recommend at most one winner per area. List losers with one-line reasons under Do-not-add.
- Prefer small, typed, tree-shakeable, actively maintained packages. Prefer a single multi-purpose lib over many micro-deps when bundle / maintenance cost favors it, and vice versa when tree-shaking or platform constraints favor micro-deps. State the reasoning per pick.
- Skip any area already covered by an existing dependency. Never recommend a duplicate. Flag deprecated / unmaintained / security-flagged candidates explicitly under Do-not-add.

## Phase 3 — Download threshold enforcement (mandatory)

Only recommend packages above 10k weekly downloads.

1. For every candidate package, verify weekly downloads via the NPM public API before recommending:
   - `https://api.npmjs.org/downloads/point/last-week/<package-name>` (returns `{"downloads": <n>}`) — use webfetch or equivalent.
   - Fallback cross-check: `https://www.npmjs.com/package/<package-name>` shows weekly downloads in UI.
   - For scoped packages, URL-encode the slash if needed by the tool, or use the UI page.
2. Rules:
   - If `downloads >= 10,000` → eligible. Include the exact number + date checked in the report.
   - If `downloads < 10,000` → move to "Do-not-add (below threshold)" with the number cited. Do not put it in the main recommendations table.
   - If downloads cannot be verified (offline / API fails), mark as `unverified` and put in P2 at best, with explicit warning. Never claim a number you did not read.
   - When two packages solve the same problem, prefer the better-maintained, better-fitting one per the Phase 2 comparison — state the trade-off. Do not pick on downloads alone.
3. Also check maintenance signals and note them: last publish date, open-issue trend, TypeScript types included (`types` field / `index.d.ts`), ESM + CJS dual support (or the format this repo needs), and platform-compatibility evidence (SSR / edge / React Native / Expo / Electron main-vs-renderer as applicable).

## Phase 4 — Required report format

Output Markdown with exactly these sections:

### 1. Executive summary

- 5–8 bullets: stack(s) + workspaces detected, runtime map summary, dependency maturity (0–5, no upgrade advice), top 3 hand-rolled areas found, top 5 highest-ROI package adds (all >10k/week).

### 2. Current state

- Table from Phase 1 plus 3–5 concrete hand-rolled examples with `file_path:line` references, affected workspace + runtime, and what kind of library capability would abstract them (no package names in this section — describe the capability only).

### 3. Recommendations (prioritized table)

Columns: `# | NPM package (with version hint) | Weekly downloads (verified number + date checked) | Category | What it replaces / abstracts (cite `file_path:line`) | Workspace(s) + runtime fit | Priority P0-now / P1-next / P2-later | Install (use detected package manager, scoped per workspace if monorepo) | Minimal usage snippet tailored to this repo | Effort S/M/L | Risk if skipped`

- P0 = removes duplicated / bug-prone hand-rolled code, fixes correctness / security, or unlocks type-safety.
- P1 = reduces maintenance, improves DX / consistency, widely idiomatic for the detected stacks.
- P2 = nice-to-have / situational.
- Every row must have a tailored install command matching the detected manager (`npm i`, `pnpm add`, `yarn add`, `bun add`, with `-D` where dev-only, plus `--filter` / workspace flag where the repo is a monorepo) and a copy-paste usage snippet that maps to the repo's actual files. Never emit generic advice without file evidence.
- No upgrade / migration rows: every row must abstract hand-rolled or fragmented code, not swap an existing dependency.

### 4. Detailed notes per P0/P1 item

For each: why this package won vs the 2+ alternatives considered, bundle / maintenance cost, TS / module-format / runtime compatibility with the affected workspace(s) (explicitly cover SSR / edge / React Native / Expo / Electron main-vs-renderer where applicable), what to import (named imports for tree-shaking where supported), what NOT to use from it, adoption sketch for the hand-rolled code (which files to touch first), expected test / typecheck load.

### 5. Rollout plan

- Phase A (day 1, P0, 1–2 packages, single module / single workspace pilot), Phase B (P1 across shared utils / affected workspaces), Phase C (P2 + dedupe + remove dead hand-rolled code). Include exact install sequence per workspace, test / typecheck commands, and bundle check if a client / mobile / renderer / edge runtime is affected.

### 6. Do-not-add list

- Packages and capabilities considered but rejected, with one-line reason each: already covered by existing dep (name it, no upgrade commentary), below 10k weekly downloads (cite number), deprecated / unmaintained, too heavy / noisy for the affected runtime, wrong runtime (e.g. Node-only in edge / browser / mobile / renderer, DOM-dependent in SSR / React Native, requires native prebuild incompatible with Expo Go where applicable), or loser vs the picked winner.

### 7. Verification

- Commands / API URLs checked to verify threshold and fit (registry download-API URLs with dates, `npm view <pkg> version time.modified` or equivalent per manager, typecheck / test commands run in discovery). Note any platform-fit caveat per recommendation. Do not list upgrade / outdated checks — they are out of scope.

## Rules

- Evidence before opinion: every P0/P1 recommendation must cite at least one file or pattern observed in this repo, a verified download count, and a runtime-fit statement.
- No code or config edits — report only.
- No updates / upgrades / migrations advice for existing packages — new abstractions for hand-rolled code only.
- Keep it actionable for future development, not just current cleanup: call out packages that prevent the bug classes this codebase is prone to (validation gaps, date bugs, async race conditions, copy-pasted utils, platform-branching bugs), scoped to the detected runtimes.
- Keep it concise but complete: no filler, no invented file paths, no guessed download numbers, no hallucinated package APIs. If a version or count matters, read it from `package.json` or the NPM API first.
- Stack-agnostic: apply the same discovery protocol whether the repo is React, Solid, React Native / Expo, Electron, monorepo, single-package, Node backend, edge, or a mix. If the repo is not JS/TS (no `package.json`), still produce the report but pivot to the actual languages found, explain why NPM packages do not directly apply, and only suggest JS tooling if a JS/TS sub-package exists.
