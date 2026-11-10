import tailwindcss from "@tailwindcss/vite";
import { devtools } from "@tanstack/devtools-vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import { nitro } from "nitro/vite";
import { defineConfig } from "vite";
import mkcert from "vite-plugin-mkcert";

export default defineConfig({
  build: {
    outDir: ".output",
    rolldownOptions: {
      onLog(level, log, defaultHandler) {
        if (
          log.code === "MODULE_LEVEL_DIRECTIVE" &&
          log.message?.includes('"use client"')
        ) {
          return;
        }
        defaultHandler(level, log);
      },
    },
  },
  plugins: [
    devtools(),
    tailwindcss(),
    tanstackStart(),
    viteReact(),
    mkcert(),
    nitro({ preset: "bun" }),
  ],
  resolve: {
    tsconfigPaths: true,
  },
});
