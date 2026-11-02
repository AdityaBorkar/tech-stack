import { Plugin } from "@opencode-ai/plugin";
import { execFile } from "node:child_process";

const REWRITE_TIMEOUT_MS = 10_000;

function rewriteCommand(command: string): Promise<string> {
  return new Promise((resolve) => {
    execFile("rtk", ["rewrite", command], { timeout: REWRITE_TIMEOUT_MS }, (_error, stdout) => {
      const rewritten = String(stdout ?? "").trim();
      if (rewritten && rewritten !== command) resolve(rewritten);
      else resolve(command);
    });
  });
}

export default Plugin.define({
  id: "rtk",
  async setup(ctx) {
    // Rewrite shell tool calls (V2 tool id is "shell"; accept legacy "bash").
    await ctx.tool.hook("execute.before", async (event) => {
      if (event.tool !== "shell" && event.tool !== "bash") return;
      const input = event.input as Record<string, unknown> | null | undefined;
      if (!input || typeof input !== "object") return;

      const key = typeof input.command === "string" ? "command" : undefined;
      if (!key) return;
      const command = input[key];
      if (typeof command !== "string" || !command) return;
      if (command.startsWith("rtk ")) return; // already rewritten

      try {
        input[key] = await rewriteCommand(command);
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    });

    // Rewrite raw shell executions that bypass the tool layer.
    await ctx.shell.hook("create.before", async (event) => {
      if (!event.command || event.command.startsWith("rtk ")) return;
      try {
        event.command = await rewriteCommand(event.command);
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    });
  },
});
