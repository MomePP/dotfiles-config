// Blocks denied shell commands, the OMP counterpart of the Claude Code
// PreToolUse hooks. The matching rules live in those hooks' scripts, so both
// agents share one definition: this feeds each script the command and blocks on
// the first deny verdict.
//
// lean-ctx runs with shell_security = "warn", so these scripts are what refuses
// commands sent through ctx_shell.
//
// Only tools that run commands are checked. edit/write are skipped, because a
// file that merely mentions `git config user.email` is not a command.
import { spawnSync } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

const HOOKS = join(homedir(), ".config/claude-code/hooks");
const SCRIPTS = [join(HOOKS, "deny-git-identity-override.sh"), join(HOOKS, "deny-shell-commands.sh")];
const COMMAND_TOOLS = new Set(["bash", "ctx_shell", "shell", "eval"]);

type ToolCallEvent = { toolName?: string; input?: Record<string, unknown> };

interface OmpExtensionApi {
	on(event: "tool_call", handler: (event: ToolCallEvent) => { block: true; reason: string } | undefined): void;
}

function denyReason(script: string, text: string): string | undefined {
	const run = spawnSync(script, [], {
		input: JSON.stringify({ tool_input: { command: text } }),
		encoding: "utf8",
		timeout: 10_000,
	});
	if (!run.stdout?.trim()) return undefined;
	try {
		const verdict = JSON.parse(run.stdout).hookSpecificOutput;
		if (verdict?.permissionDecision === "deny") return verdict.permissionDecisionReason;
	} catch {
		// Unparseable output means the script failed, not a deny.
	}
	return undefined;
}

export default function (pi: OmpExtensionApi) {
	pi.on("tool_call", (event) => {
		if (!COMMAND_TOOLS.has(String(event?.toolName ?? "").replace(/^_/, ""))) return undefined;
		// eval carries code rather than `command`, so check every string field.
		const text = Object.values(event.input ?? {})
			.filter((v): v is string => typeof v === "string")
			.join("\n");
		if (!text) return undefined;

		for (const script of SCRIPTS) {
			const reason = denyReason(script, text);
			if (reason) return { block: true, reason };
		}
		return undefined;
	});
}
