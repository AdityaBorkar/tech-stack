import { rm } from "node:fs/promises";

const OUTPUT_DIR = ".output";

await rm(OUTPUT_DIR, { force: true, recursive: true });

const result = await Bun.build({
  define: {
    "process.env.NODE_ENV": '"production"',
  },
  drop: ["console", "debugger"],
  entrypoints: ["./src/index.ts"],
  format: "esm",
  minChunkSize: 16384,
  minify: true,
  outdir: OUTPUT_DIR,
  packages: "external",
  sourcemap: "external",
  splitting: true,
  target: "browser",
  throw: false,
});

if (result.success) {
  for (const output of result.outputs) {
    console.log(`${output.path} (${output.size} bytes)`);
  }
} else {
  for (const log of result.logs) {
    console.error(log.message);
  }
  process.exitCode = 1;
}

const types = Bun.spawnSync(["bun", "tsc", "-p", "tsconfig.build.json"], {
  stdio: ["ignore", "inherit", "inherit"],
});

if (types.exitCode !== 0) {
  process.exitCode = 1;
}
