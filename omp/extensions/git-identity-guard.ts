// Blocks commands that rewrite the git author identity, the OMP counterpart of
// the Claude Code PreToolUse hook. The matching rules live in that hook's script,
// so both agents share one definition: this feeds it the command and blocks on
// a deny verdict.
//
// Only tools that run commands are checked. edit/write are skipped, because a
// file that merely mentions `git config user.email` is not a command.
import { spawnSync } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

const SCRIPT = join(homedir(), ".config/claude-code/hooks/deny-git-identity-override.sh");
const COMMAND_TOOLS = new Set(["bash", "ctx_shell", "shell", "eval"]);

type ToolCallEvent = { toolName?: string; input?: Record<string, unknown> };

interface OmpExtensionApi {
	on(event: "tool_call", handler: (event: ToolCallEvent) => { block: true; reason: string } | undefined): void;
}

export default function (pi: OmpExtensionApi) {
	pi.on("tool_call", (event) => {
		if (!COMMAND_TOOLS.has(String(event?.toolName ?? "").replace(/^_/, ""))) return undefined;
		// eval carries code rather than `command`, so check every string field.
		const text = Object.values(event.input ?? {})
			.filter((v): v is string => typeof v === "string")
			.join("\n");
		if (!text) return undefined;

		const run = spawnSync(SCRIPT, [], {
			input: JSON.stringify({ tool_input: { command: text } }),
			encoding: "utf8",
			timeout: 10_000,
		});
		if (!run.stdout?.trim()) return undefined;
		try {
			const verdict = JSON.parse(run.stdout).hookSpecificOutput;
			if (verdict?.permissionDecision === "deny") {
				return { block: true, reason: verdict.permissionDecisionReason };
			}
		} catch {
			// Unparseable output means the script failed, not a deny.
		}
		return undefined;
	});
}
