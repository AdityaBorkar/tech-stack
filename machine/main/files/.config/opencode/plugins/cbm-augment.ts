import { Plugin } from "@opencode-ai/plugin";
import { spawn } from "node:child_process";

const BIN = "/home/aditya/.local/bin/codebase-memory-mcp";

function augment(tool: string, args: unknown): Promise<string> {
  return new Promise((resolve) => {
    const child = spawn(BIN, ["hook-augment"], {
      stdio: ["pipe", "pipe", "ignore"],
      env: { ...process.env, CBM_LOG_LEVEL: "error" },
    });
    let out = "";
    child.stdout.on("data", (d: Buffer) => (out += d.toString()));
    child.on("error", () => resolve(""));
    child.on("close", () => resolve(out));
    child.stdin.end(
      JSON.stringify({
        hook_event_name: "PreToolUse",
        tool_name: tool,
        tool_input: args ?? {},
      }),
    );
  });
}

export default Plugin.define({
  id: "codebase-memory",
  async setup(ctx) {
    await ctx.tool.hook("execute.after", async (event) => {
      if (event.tool !== "grep" && event.tool !== "glob") return;
      if (event.status !== "completed") return;

      // Map OpenCode tool IDs to the Claude-style names the helper expects.
      const toolName = event.tool === "grep" ? "Grep" : event.tool === "glob" ? "Glob" : event.tool;
      const extra = await augment(toolName, event.input ?? {});
      if (!extra || !extra.trim()) return;

      let output;
      const result = event.result;
      if (result && typeof result?.output === "string") {
        output = result.output + "\n" + extra;
      } else if (result && typeof result?.content === "string") {
        output = result.content + "\n" + extra;
      } else if (Array.isArray(result?.content)) {
        output = [...result.content, { type: "text", text: extra }];
      } else if (typeof result?.output === "string") {
        output = result.output + "\n" + extra;
      } else if (result?.content === undefined && result?.output === undefined) {
        output = extra;
      }

      event.result = { ...result, output };
    });
  },
});
