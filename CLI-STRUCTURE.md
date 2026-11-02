# Bun CLI app structure (cli-app)

Reference layout cloned from adistack-conform. Adapt file names to your CLI; keep the shape.

```text
src/
  index.ts      # Commander entrypoint (subcommands live here or under src/commands/)
  config.ts     # config load / discover
  checks.ts     # check + fix types and apply
  techstack.ts  # registry / blueprint / preset engine (if conform-like)
  diff.ts       # diff rendering
  output.ts     # result printing
  schemas/      # Zod v4 source of truth (only if JSON configs are enforced)
scripts/
  build.ts                 # regen schemas, then `bun build --compile` to `.output/<bin>`
  generate-json-schema.ts  # Zod -> configuration_schema/*.json (generated, never hand-edit)
configuration_schema/      # generated JSON Schemas, overwritten by build
tests/                     # empty until a runner is adopted (no test runner by default)
.output/                   # compiled binary (gitignored)
```

Conventions (enforced by the other cli-app presets):

- `bun run <script>`, never `npm`/`npx`. `verify` = format + lint + types + build.
- Path alias `#/*` -> `./src/*` (`package.json` `imports` + tsconfig `paths`). No `@/*`.
- `verbatimModuleSyntax` on; `noUnusedLocals`/`noUnusedParameters` on.
- oxfmt: tabs, `printWidth` 100, sorted imports, sorted `package.json` scripts.
- Pre-commit hook runs `bun fmt --staged`; commit messages follow the commitlint preset types.
- Document the stack, commands, layout, and CLI surface in `AGENTS.md` (per-repo, not conformed).
