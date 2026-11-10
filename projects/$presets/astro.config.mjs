// @ts-check

import cloudflare from "@astrojs/cloudflare";
import mdx from "@astrojs/mdx";
import react from "@astrojs/react";
import tailwindcss from "@tailwindcss/vite";
import basicSsl from "@vitejs/plugin-basic-ssl";
import { astroGrab } from "astro-grab";
import { defineConfig } from "astro/config";
import { visualizer } from "rollup-plugin-visualizer";

// import sitemap from "@astrojs/sitemap";
// import checks from "@nuasite/checks";
// import astroBrokenLinksChecker from "astro-broken-links-checker";
// import og from "astro-og";
// import robotsTxt from "astro-robots-txt";

// Replace with your production URL.
const SITE_URL = "https://example.com";

export default defineConfig({
  adapter: cloudflare({
    imageService: "compile",
  }),
  compressHTML: true,
  integrations: [
    react(),
    mdx(),
    // og(),
    // sitemap(),
    // robotsTxt({
    // 	policy: [{ allow: ["/"], disallow: ["/api/"], userAgent: "*" }],
    // 	sitemap: `${SITE_URL}/sitemap-index.xml`,
    // }),
    // checks(),
    // astroBrokenLinksChecker({
    // 	cacheExternalLinks: true,
    // 	checkExternalLinks: true,
    // 	throwError: true,
    // }),
    astroGrab({
      holdDuration: 300,
    }),
  ],
  outDir: ".output",
  output: "server",
  prefetch: {
    defaultStrategy: "hover",
    prefetchAll: false,
  },
  redirects: {
    // "/portfolio": "/work",
  },
  site: SITE_URL,
  vite: {
    plugins: [
      tailwindcss(),
      basicSsl(),
      visualizer({
        emitFile: true,
        filename: "stats.html",
      }),
    ],
    ssr: {
      external: [
        "node:fs",
        "node:path",
        "fs",
        "node:crypto",
        "child_process",
        "node:os",
        "node:events",
        "node:stream",
        "node:util",
      ],
    },
  },
});
