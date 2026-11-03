# AGENTS.md

Data-only registry. No README, no root `package.json`, no test/lint/build runner, no CI, no `opencode.json` here. Toolchain configs under `projects/$presets/` are templates for generated projects — not runnable here.

## Layout

- `registry.json` — entrypoint listing `machines[]` + `projects[]`.
- `machines/main/` — home-manager flake (`flake.nix`, `home.nix`, `packages.nix`, `programs.nix`, `bun.nix`, empty `services.nix` stub, `files/` dotfile payloads, sops-encrypted `secrets.yaml`, `.sops.yaml`).
- `machines/wsl/` — `wsl.conf` + `.wslconfig`; Windows/WSL-side, not Nix-managed.
- `projects/*/manifest.json` — blueprints: `description` + `files[]` + `file_structure[]`. Counts (`files`): `cli-app` 11, `cli-tanstack-webapp` 14, `tanstack-webapp` 13, `tanstack-website` 13 (same targets as `tanstack-webapp`), `astro-website` 18 (Astro + Cloudflare + QA configs). Each also declares `file_structure[]` (e.g. `src/` dir plus `AGENTS.md`/`README.md` files).
- `projects/$presets/` — flat payload files copied to new projects; manifests are source of truth for what gets copied (e.g. `biome.json` is currently unreferenced — toolchain is oxlint + oxfmt). Literal `$` in dirname: quote in shell (`"projects/\$presets/..."`). `package.json` is a template with `<placeholders>` plus a `_template` note.

## Editing project presets

- `files[]` entries use `source` relative to the manifest dir (`../$presets/<file>`) and `target` as the destination path in the generated project. `file_structure[]` entries use `name` + `target` + `kind` (`file`|`dir`) for existence-only paths (currently `src/` + `AGENTS.md` + `README.md`).
- Top-level `js` holds the toolchain: `pm` (package-manager binary for hints, currently `bun`) plus `dependencies[]` / `devDependencies[]` / `peerDependencies[]` the generated `package.json` must install. `files[]` entries may declare `compare`: `ignore[]` (excluded keys, local values preserved — linter `overrides`), `strip[]` (removed before comparing), `pinned[]` (must-match keys, objects merge per key), `versioned[]` (shared versions must match).
