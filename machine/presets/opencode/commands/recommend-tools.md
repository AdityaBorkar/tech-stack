---
description: In-depth repo analysis to recommend ESLint, Oxlint, shadcn and code-quality tools
---

Write a report on linters and code-quality tools that should be added to this repo to improve code quality and future development.

Scope: $ARGUMENTS

If $ARGUMENTS is empty, analyze the entire repo. If $ARGUMENTS names a path, package, or focus area (e.g. `frontend`, `tailwind`, `security`), scope the deep-dive to that area but still briefly audit the repo-wide baseline.

## Phase 1 — In-depth repo discovery (do this first, evidence-based)

Do a complete, read-only analysis. Do not install anything or edit configs. Use file reads, glob, and search — do not guess the stack.

1. Detect stack and package manager:
   - `package.json` (deps, devDeps, scripts), lockfile (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lock`), Node version, monorepo vs single package (workspaces, Turborepo, Nx, Lerna).
   - Language(s): TypeScript / JavaScript version, ESM vs CJS, JSX/TSX, React / Next.js / Remix / Vite / Node / Edge, CSS approach.
   - Tailwind version and shadcn setup: `components.json`, `tailwind.config.*`, `app/globals.css` or `src/index.css`, `components/ui/*`, CVA / `cn()` util, Radix usage.
2. Audit current quality toolchain:
   - ESLint: `eslint.config.*`, `.eslintrc*`, plugins and extends already enabled, ignored paths.
   - Oxlint: `.oxlintrc.json`, `oxlint` CLI in scripts, VS Code settings.
   - Alternatives in use: Biome, Prettier, `tsconfig.json` strictness (`strict`, `noUncheckedIndexedAccess`, `noUnusedLocals`, `exactOptionalPropertyTypes`), `editorconfig`, `lint-staged`, Husky, `commitlint`, `ls-lint`, GitHub Actions / CI lint jobs.
   - Formatting, import sorting, and test linters already present.
3. Sample real code for lint gaps (at least):
   - Entry points, 3–5 representative source files, UI components, API routes / server actions, utils, tests, and config files.
   - Look for: `any` / unsafe assertions, missing exhaustive deps, floating promises, `console.log` leftovers, direct `<img>` vs `next/image`, raw `<a>` vs `next/link`, inline Tailwind class disorder, `cn()` misuse, hardcoded colors/spacing instead of tokens, a11y issues (missing labels, alt, keyboard handlers), insecure patterns (`eval`, `dangerouslySetInnerHTML`, weak crypto, exposed secrets), barrel-file bloat, circular imports, dead exports, inconsistent file naming.
4. Record baseline as a table: Tool | Configured? (yes/partial/no + config path) | Gaps observed (with file:line evidence).

Do not recommend a tool that duplicates an already-configured equivalent unless you show why the existing setup is insufficient.

## Phase 2 — Recommendation categories (cover all that apply)

Recommend concrete, installable items — not vague advice. For each category, state keep / add / skip with reasoning:

1. **JS/TS core:** `typescript-eslint`, `eslint-plugin-oxlint` interop or migration to `oxlint`, `@typescript-eslint` strict/type-checked rules vs `oxlint` equivalents, `eslint-plugin-sonarjs` / `oxlint` complexity rules, `eslint-plugin-unicorn`, `eslint-plugin-perfectionist` (sorting) or `simple-import-sort` / `sort-imports`.
2. **Oxlint-native:** which `oxlint` categories/plugins to enable (`correctness`, `suspicious`, `pedantic`, `perf`, `style`, `restriction`), `oxlint-plugin-eslint` compat, when to keep ESLint only for rules Oxlint cannot cover.
3. **React / Next.js:** `eslint-plugin-react`, `eslint-plugin-react-hooks` (exhaustive-deps), `eslint-plugin-react-compiler`, `eslint-plugin-react-refresh`, `@next/eslint-plugin-next` / `next/core-web-vitals`, JSX a11y (`eslint-plugin-jsx-a11y`).
4. **Tailwind + shadcn:** `eslint-plugin-tailwindcss` (class order, no-contradicting-classname, no-custom-classname), shadcn lint/conventions (component naming, `client` directive placement, `cn()` / CVA discipline, Radix props, token usage over arbitrary values), CSS lint (`stylelint` only if plain CSS exists — skip if Tailwind-only).
5. **Imports / architecture:** `eslint-plugin-import` / `import-x` (no-cycle, no-self-import, no-duplicates, consistent-type-imports), `eslint-plugin-boundaries` or `no-restricted-imports` for layering, `knip` (dead exports/files), `depcheck` / `madge`, `eslint-plugin-barrel-files` where relevant.
6. **Security / correctness:** `eslint-plugin-security`, `eslint-plugin-no-secrets` / `gitleaks` / `secretlint`, `eslint-plugin-no-unsanitized`, Node security rules, `zod` / validation lint where API boundaries exist.
7. **Tests / async:** `eslint-plugin-vitest` or `eslint-plugin-jest`, `eslint-plugin-playwright` / `cypress`, `eslint-plugin-testing-library`, `eslint-plugin-promise`, `@typescript-eslint/no-floating-promises` / `no-misused-promises`.
8. **Formatting / hooks / CI:** Prettier vs dprint vs ESLint-stylistic vs Oxlint-format decision, `husky` + `lint-staged`, `commitlint` + `cz`, `ls-lint`, `editorconfig-checker`, `markdownlint`, `jsonc` / `yaml` lint, Dockerfile / shell (`hadolint`, `shellcheck`) only if those files exist.

Prefer fast, low-maintenance, actively maintained tools. Prefer `oxlint` where it covers an ESLint rule with less config and faster CI. Flag high-noise or deprecated plugins explicitly under "Do not add".

## Phase 3 — Required report format

Output Markdown with exactly these sections:

### 1. Executive summary

- 5–8 bullets: stack detected, current lint maturity (0–5), top 3 risks found, top 5 highest-ROI adds.

### 2. Current state

- Table from Phase 1 plus 3–5 concrete gap examples with `file_path:line` references.

### 3. Recommendations (prioritized table)

Columns: `# | Tool / Plugin / Rule-set | Category | Why this repo needs it (cite evidence) | Priority P0-now / P1-next / P2-later | Install (use detected package manager) | Minimal config snippet | Effort S/M/L | Risk if skipped`

- P0 = correctness/security/type-safety or fixes observed bugs.
- P1 = consistency/maintainability/a11y/test quality.
- P2 = nice-to-have / polish.
- Every row must have a tailored install command and a copy-paste config snippet matching the repo's actual setup (flat `eslint.config.js` vs legacy, `.oxlintrc.json`, `package.json` scripts). Never emit generic `npm install <pkg>` without version-aware, manager-aware commands.

### 4. Detailed notes per P0/P1 item

For each: what to enable (exact plugin + 5–15 key rules with `warn` vs `error` recommendation), what to leave off and why, interaction with existing config, expected false-positive load, autofix availability (`--fix` safe or not).

### 5. Rollout plan

- Phase A (day 1, P0, `warn`-only), Phase B (P1 promotion to `error` + pre-commit hooks), Phase C (P2 + CI gates). Include exact script additions (`lint`, `lint:fix`, `typecheck`, `knip`, `format:check`), `lint-staged` block, and CI job snippet if `.github/workflows` exists, else a generic one marked as new file.

### 6. Do-not-add list

- Tools considered but rejected for this repo, with one-line reason each (e.g. already covered, deprecated, too noisy, wrong stack).

### 7. Verification

- Commands to run after adoption and expected outcome (e.g. `oxlint`, `eslint .`, `tsc --noEmit`, `knip`, `prettier --check .`). Note any rule that will initially fail and needs a baseline / TODO pass.

## Rules

- Evidence before opinion: every P0/P1 recommendation must cite at least one file or config gap observed in this repo.
- No code or config edits — report only.
- Keep the report actionable for future development, not just current cleanup: call out rules that prevent the bug classes this codebase is prone to.
- Keep it concise but complete: no filler, no invented file paths, no guessed versions. If a version matters, read it from `package.json` first.
- If the repo is not JS/TS (no `package.json`), still produce the report but pivot categories to the actual languages found and explain why JS-specific tools do not apply.
