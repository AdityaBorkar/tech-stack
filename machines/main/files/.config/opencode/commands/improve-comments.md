---
description: Remove unnecessary comments, rewrite survivors in caveman + ASD-STE100 style, consolidate TODOs into TODO.md
---

Clean up comments across the repo. Delete noise, keep only what code cannot say, rewrite survivors in combined caveman + ASD-STE100 style, and centralize TODO/BUG comments into TODO.md.

Scope: $ARGUMENTS

If $ARGUMENTS is empty, process the entire repo. If $ARGUMENTS names a path, directory, or focus area (e.g. `src/auth`, `utils`, `api routes`), scope the edits to that area but still briefly scan repo-wide for TODO/BUG comments to consolidate.

## Phase 1 — Discovery (do this first, evidence-based)

1. Inventory comment styles in use: `//`, `#`, `/* */`, `<!-- -->`, `"""`, `///`, JSDoc/TSDoc, docstrings, XML docs — per language found. Detect stack via `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc. to know which comment syntaxes and doc-comment conventions apply.
2. Find all comments using grep/glob — do not guess:
   - Obvious-noise candidates: what-code-says, narrated steps, renamed-value explanations, dead commented-out code, boilerplate headers (`Created by`, `Author:`, license copy-paste with no legal force), empty placeholders, commit-history in comments, guessed TODOs with no action.
   - Keeper candidates: functionality code cannot explain, rare cases, edge cases, hidden invariants, ordering/concurrency/performance traps, external bug workarounds, business/legal/safety mandates, non-obvious consequences.
   - Task comments: `TODO`, `FIXME`, `BUG`, `HACK`, `XXX`, `TEMP`, `WORKAROUND` (any case) — record `file_path:line` + full text + surrounding 3 lines.
3. Exclude from edits: `node_modules/`, `dist/`, `build/`, lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lock`), generated code, vendored code, minified files, `.git/`. You may still read them to avoid false positives, but never edit them.
4. Record baseline as a table: File | Total comments | Noise (count) | Keeper candidates (count) | Task comments (count). Sample at least 5–10 representative source files with `file_path:line` evidence.

## Phase 2 — The keep test (apply to every comment)

A comment survives ONLY if it passes one of these — otherwise delete it:

1. **Code cannot say it:** hidden constraint, invariant, or contract the code obeys but cannot show (units, ranges, ownership, valid states).
2. **Rare case / edge case:** input, timing, retry, race, ordering, or platform quirk that looks wrong but is intentional. Must name the trigger.
3. **Outside force:** external bug, API quirk, spec section, ticket link, legal/safety rule that mandates this shape. Must cite source (URL, issue #, spec §).
4. **Sharp warning:** non-obvious consequence if touched — data loss, double-charge, deadlock, perf cliff, security hole.

Delete unconditionally:

- Comment restates code (`// increment i`, `# return user`, `// loop through items`).
- Comment names what a rename/extraction/type/guard could say instead — prefer self-explanatory code, then delete the comment. Small renames to absorb meaning are allowed; no logic refactors.
- Commented-out code — delete it, history lives in git. No exceptions.
- Boilerplate file headers, ASCII art dividers, `// ===== Section =====` noise, commented license blocks with no legal requirement.
- Dead `TODO: fix this` with no actionable what/why — either make it actionable for TODO.md or delete it.
- Doc comments that restate the signature (`@param name the name`). Keep doc comments ONLY if they add contract/invariant/edge-case info code cannot show.

Completion check: the changed code must read correctly with every comment deleted. Each surviving comment must answer a _why_ no rename, extraction, type, or guard could carry.

## Phase 3 — Caveman + ASD-STE100 rewrite (all survivors)

Rewrite every surviving comment in a COMBINED style: caveman words inside STE100 sentences. Neither alone is enough — caveman without STE turns ambiguous (`Me do thing fast`), STE without caveman turns corporate (`Facilitate optimization of the iteration process`). Together they give short comments a machine cannot misread.

Division of labor — do not mix these up:

| Layer                             | Controls                    | What it does here                                                                                                             |
| --------------------------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Caveman (voice)**               | Word choice, tone           | Small blunt words. `Me` / `You` actors. Verb first. No filler. Says why + danger.                                             |
| **ASD-STE100 Strict (structure)** | Grammar, shape, consistency | Active voice. One idea per sentence. Short sentences. One word = one meaning. No phrasal verbs. No semicolons. Simple tenses. |

Use STE100 in **Strict mode** for all surviving comments. A misread edge-case or warning comment has a real cost (double-pay, data loss, deadlock), same as a misread maintenance instruction. No STE-flavored leniency except keeping exact code identifiers and domain terms (see Rule 8).

### Combined rules (apply all 10 to every rewritten comment)

1. **Active voice with explicit actor.** STE structure + caveman pronouns. `Me`, `You`, or the code noun does the verb. Never passive.
   - Bad: `Empty rows are skipped.` (who skips?)
   - Good: `Me skip empty rows.`
2. **One idea per sentence. Split the rest.** One instruction or fact per sentence. No `and then`, no `;`, no em-dash splices. Max 2 sentences per comment (+1 line only for a link/ID).
   - Bad: `Auth must run before rate-limit or context breaks and retries fail.`
   - Good: `Auth run first. You swap, things break.`
3. **Short sentences — stricter than STE.** Each sentence ≤12 words (STE allows 20 for procedures, 25 for descriptions — staying under 12 keeps you auto-compliant). One line per sentence. If you need a third sentence, the comment is too long — cut it.
4. **One word, one meaning per repo.** Pick one verb per action and reuse it everywhere in this run. Do not rotate synonyms: `check` OR `verify` (not both), `keep` OR `hold`, `skip` OR `ignore`, `remove` OR `delete`. Same for nouns: `users` OR `customers`, never both for one thing. Fix synonym rotation when you see it.
5. **No phrasal verbs.** Use one plain verb (STE Rule 9.3). Two-word verbs hide meaning.
   - `take off` → `remove`, `spin up` → `start`, `filter out` → `remove`, `kick off` → `start`, `dive into` → `read`, `set up` → `set`.
6. **Verb, not noun. No nominalization.** `analyze` not `perform analysis`, `retry` not `do retry logic`, `helps` not `provides assistance to`. If a noun hides who acts, restore the verb.
7. **Simple tenses. Keep every hedge.** Use imperative / simple present / simple past only. Preserve `may`, `sometimes`, `can`, `will` exactly — a hedge is content, not filler. Never promote `sometimes knock twice` to `knock twice`. Never invent certainty the old comment did not state.
8. **Keep code words verbatim. Caveman around them, never instead of them.** STE allows a project glossary — identifiers, params, error names, and domain nouns (`mutex`, `webhook`, `idempotency key`, `PROJ-123`) stay exact. Do not caveman-ify them into ambiguity. `Me release mutex first.` beats `Me let go of lock-stick.`
9. **No noun stacks over 3 words. No ellipsis.** Break `high pressure fuel pump inlet valve assembly`-style stacks into a short clause. Keep subject + verb + article explicit even if longer: `Me skip them.` not `Skip when empty.` Name the actor every time.
10. **No filler, no marketing, no stacked hedges.** Delete: `basically, please note, in order to, it is important to note that, seamless, robust, powerful, blazing-fast`. One hedge max per sentence. State the claim or delete it.

Banned-word swap list (minimum — extend with your own finds): `utilize→use`, `leverage→use`, `facilitate→help`, `implement→make`, `functionality→work`, `optimize→go fast`, `synchronize→wait turn`, `aforementioned→that`, `comprehensive→full`.

### Worked examples (imitate the last column only)

```text
// Before: This function iterates over the user array to filter out inactive users for performance optimization purposes.
// Caveman-only (still bad): Me go fast through users. Sleepy ones go bye-bye. (which users? what does go fast mean? phrasal verb)
// After (caveman + STE): // Me keep only awake users. Sleepy users go away.
// Why: active voice, 5 words per sentence, one idea each, plain verb `keep`, no nominalization.

// Before: Edge case — Stripe webhook can fire twice, handler must be idempotent to avoid double-charging.
// Caveman-only (still bad): Stripe knock twice sometimes and you get double trouble if you mess up handling and stuff.
//   (run-on, hedge buried, two ideas in one sentence, vague `handling and stuff`)
// After (caveman + STE): // Stripe sometimes knock twice. Do work once. No double-pay.
// Why: hedge `sometimes` kept, one idea per sentence, 3–4 words each, consistent verb `do`, danger stated.

// Before: WARNING — do not reorder these middleware; auth must run before rate-limit or context is undefined.
// After (caveman + STE): // Auth run first. You swap, things break.
// Why: no semicolon, active, explicit actor, 3–4 words per sentence.

// Before: Workaround for Node 18 bug where fetch aborts on large streams, see https://github.com/nodejs/node/issues/XXXXX
// After (caveman + STE): // Node 18 bite big downloads. Me use this trick.
//                        // See: https://github.com/nodejs/node/issues/XXXXX
// Why: link on its own line, technical nouns (`Node 18`, `downloads`) kept exact, simple present tense.

// Before: Temporary hack to handle empty CSV rows until upstream fixes the exporter (ticket PROJ-123)
// After (caveman + STE): # Upstream send empty rows. Me skip them. Fix in PROJ-123.
// Why: `PROJ-123` kept verbatim, `send`/`skip` plain verbs, one idea per sentence.
```

### Self-check each rewrite before you write it

Ask all six — any `yes` means rewrite again:

1. Passive? (`is skipped`, `is done by`) → restore `Me`/`You`/noun actor.
2. Two ideas in one sentence, or a `;` / `—` splice? → split at the period.
3. Any sentence over 12 words, or comment over 2 sentences (+link)? → cut words, not hedges.
4. Phrasal verb, nominalization, or marketing adjective present? → swap to plain verb.
5. Same action/thing named two ways in this file? → pick one, reuse it.
6. Hedge dropped or added vs the original? → restore exact confidence level.

Language-specific placement: inline `//` / `#` beside the weird line; block-level why at head of function/module it constrains. Keep doc-comment tags (`@param`, `Args:`, etc.) only where they carry keeper info; rewrite their descriptions under the same 10 rules.

## Phase 4 — TODO.md consolidation (mandatory)

1. Collect every `TODO` / `FIXME` / `BUG` / `HACK` / `XXX` / `TEMP` comment found in Phase 1, repo-wide even when $ARGUMENTS scopes edits to one area.
2. Create or update `TODO.md` at repo root (or merge into existing `TODO.md` — never create a duplicate like `TODO2.md` / `TODOS.md`). Format:

```md
# TODO

> Auto-collected from code comments on <YYYY-MM-DD>. Source of truth — scattered TODO comments in code were removed after collecting.

## Bugs

- [ ] <short caveman title> — `path/to/file.ext:123` — <one-line why it bite> (was: `<original comment text>`)

## TODOs

- [ ] ...

## Hacks / Workarounds

- [ ] ...
```

3. Rules for entries:
   - One entry per unique task. Dedupe copy-pasted duplicates, keep all `file_path:line` refs in one entry.
   - Rewrite titles in caveman + STE100 style (same 10 rules as Phase 3: active voice, one idea per sentence, plain verbs, hedges kept). Preserve original text in `(was: ...)` so context is not lost.
   - Drop entries that are already done, nonsensical, or have no actionable what — note dropped ones in the final report, do not put them in TODO.md.
   - Group under `## Bugs`, `## TODOs`, `## Hacks / Workarounds`. Skip empty groups.
4. After collecting, DELETE the scattered task comments from source files so TODO.md is the single source of truth. Leave a one-line pointer in code ONLY if the fix location needs it (caveman + reference, e.g. `// Fix tracked in TODO.md > Bugs > double-pay`), and only when removal would strand the reader. Default is full removal.

## Phase 5 — Execute and report

1. Edit files: delete noise comments, rewrite survivors in caveman + STE100, remove scattered task comments, write/merge `TODO.md`. Change comments ONLY — never change logic, strings, tests, or formatting beyond the comment lines. Tiny renames to absorb comment meaning are allowed; anything bigger is out of scope.
2. Verify no logic changed:
   - `git diff --stat` and `git diff -U2` — diff must show only comment lines removed/rewritten plus `TODO.md`. If any non-comment line changed, revert it.
   - Run the repo's fast check if present (`tsc --noEmit`, `npm test`, `pytest -q`, `go vet ./...`, etc.) — report pass/fail. Do not install anything.
3. Output Markdown with exactly these sections:

### 1. Summary

- Files touched, comments deleted / rewritten / kept, task comments collected into TODO.md, dropped-as-done count.

### 2. Changes (table)

Columns: `File:line | Before (first 80 chars) | Action deleted / rewritten / moved-to-TODO | After (full new text or —)`

### 3. Keepers (with why)

- Each surviving non-trivial comment: `file_path:line`, full new text, which keep-test rule it passed (1–4), the why no code change could carry it, and STE self-check result (longest sentence word count, passive/phrasal-verb/noun-stack clean yes/no).

### 4. TODO.md

- Path written/merged, counts per group, dropped entries with one-line reason each, pointer-comments left in code (if any) with justification.

### 5. Verification

- `git diff --stat` output, check command run + result, confirmation that no logic lines changed.

## Rules

- Evidence before opinion: every bulk deletion claim must cite `file_path:line` samples seen, not guessed conventions.
- Comments explain only what code cannot: functionality code cannot explain, rare cases, edge cases. Everything else goes.
- Caveman words, STE100 sentences, always: short blunt simple words in active voice, one idea per sentence, ≤12 words per sentence, one word one meaning, no phrasal verbs, no semicolons, hedges preserved. No corporate filler, no restating code.
- TODO.md is the only home for task comments — no scattered TODO/BUG left behind unless a pointer is justified in the report.
- No logic edits, no formatting drives, no new dependencies. Comments + TODO.md only.
