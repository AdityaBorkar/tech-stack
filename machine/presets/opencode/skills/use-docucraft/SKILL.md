---
name: use-docucraft
description: Prepare self-contained HTML reports with typed single-responsibility components and TailwindCSS. Use whenever an HTML report has to be prepared, a report page is requested, or report HTML needs layout, styling, or print output.
---

# Report Design

Single-file HTML reports built from small typed components. TailwindCSS via CDN. No build step. Runs with `bun`.

## When to use

Invoke this skill when the user asks for an HTML report, a report page, a dashboard export, a styled summary document, or print-ready output. Also use when editing report HTML structure or styling.

## Hard rules

1. **Single responsibility.** One component does one UI job: `Page`, `Section`, `Card`, `Stat`, `Badge`, `Table`, `Bar`, `Callout`. Never a `ReportWithEverything` component. If a component needs `and` to describe, split it.
2. **Pure props, explicit contracts.** Data flows down via props only. Every prop is typed (`Props` type per component, required vs optional explicit). No globals, no hidden formatting inside data props. Components never fetch.
3. **Composition via children, not HTML strings.** Containers take `children: ReactNode`. Never pass large formatted HTML through a string prop like `contentHtml` or `bodyText`. Bad: `<Card bodyHtml="<b>hi</b>" />`. Good: `<Card title="Hi"><p>hi</p></Card>`.

Additional output rules:

- One self-contained `.html` file. Tailwind via CDN script tag only. No local CSS build, no external stylesheet you generate.
- Reuse `components/ui.tsx` when it fits. Extend it with new single-purpose components rather than one-off inline styles.
- Escape all dynamic text. Use JSX text nodes, never `dangerouslySetInnerHTML` for report data.

## Workflow

1. Clarify report inputs: title, sections, tables/metrics, audience (screen vs print). If missing, assume screen-first with print CSS.
2. Read `references/components.md` for component contracts and `references/tailwind.md` for the Tailwind pattern. Skim `components/ui.tsx` for what already exists.
3. Compose the report from existing components. Add a new component only for a genuinely new UI job, following the same Props + children contract.
4. Copy the closest file in `examples/` as the starting point. Keep its render-to-file boilerplate intact.
5. Render and verify: `bun <report-file> --out <output.html>`, then read back the HTML head and byte size. Open or fetch it if a browser tool is available.
6. Report the output path and what was verified. Do not paste the full HTML into chat.

## Component contract

```tsx
import type { ReactNode } from "react";

export type CardProps = { title?: string; children: ReactNode };
export function Card({ title, children }: CardProps) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      {title ? <h3 className="mb-3 font-semibold">{title}</h3> : null}
      {children}
    </div>
  );
}
```

- One `Props` type per component, exported, fields typed and minimal.
- `children: ReactNode` on every container (`Page`, `Section`, `Card`, `Callout`). Leaf components (`Stat`, `Badge`, `Bar`) take scalar props only.
- Full pattern catalog with good/bad pairs: `references/components.md`.

## Tailwind pattern

```html
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
```

- Utility classes only, in JSX `className`. No `<style>` blocks except `@media print` tweaks and page margins.
- Palette: `slate` text/borders, white cards on `bg-slate-100`, one accent per report. Status uses `Badge` tones only.
- Full tokens and print rules: `references/tailwind.md`.

## Run with bun

Examples need no `package.json` and no `npm install`. Bun auto-installs bare imports on first run (global cache). URL imports also work for simple modules.

```sh
# minimal example -> writes ./report.html
bun skills/report-design/examples/minimal-report.tsx --out ./report.html

# richer dashboard example
bun skills/report-design/examples/dashboard-report.tsx --out ./dashboard.html
```

- Imports in examples/components use bare specifiers (`react`, `react-dom/server`) so `bun` resolves them without setup. This is the preferred form.
- URL-import form (`https://esm.sh/react@18.3.1`) also runs under `bun` for single-module cases. Prefer bare imports for `react-dom/server`, where esm.sh subpath resolution is unreliable under Bun.
- Render boilerplate every report file keeps: `renderToStaticMarkup(<Report />)`, `<!DOCTYPE html>` prefix, `Bun.write(out, html)`. Keep it.

## File map

- `components/ui.tsx` — Tailwind reusable library (`Page`, `Section`, `Card`, `Stat`, `Badge`, `Table`, `Bar`, `Callout`). Import from here for Tailwind reports.
- `components/index.tsx` — ScreenTune warm-paper library barrel (one file per component: `Page`, `SiteHeader`, `Hero`, `Card`, `Badge`, `FileReference`, `CodeBlock`, `DataTable`, …). Import from here for `report/design/*.css` reports.
- `references/components.md` — contracts, composition rules, good/bad examples.
- `references/tailwind.md` — CDN snippet, palette, layout, print.
- `examples/minimal-report.tsx` — smallest runnable report. Start here.
- `examples/dashboard-report.tsx` — multi-section report with stats, table, bars, callout.
