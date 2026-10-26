// Idle compaction for non-TUI modes. OMP arms its idle-compaction timer only
// in the interactive TUI controller; Paseo runs `omp --mode rpc-ui`, so a
// session left idle past the prompt-cache TTL rebuilds its whole context on
// return. This reproduces the TUI timer for every other mode: after a run
// ends with enough context, compact shortly before the cache expires.
//
// Assumes the Anthropic 1h cache tier (subscriber accounts), so only the
// anthropic provider is handled.
import { lookup } from "@oh-my-pi/pi-coding-agent/config/registry";

// OMP's 1h-tier rule: min(0.9 * TTL, TTL - 10s) - 5s margin = 3_235_000 ms.
const FIRE_AFTER_MS = 3_235_000;

type Handle = unknown;

interface Ctx {
	mode: string;
	agent?: { kind?: string };
	model?: { provider?: string };
	getContextUsage(): { tokens: number | null } | undefined;
	isIdle(): boolean;
	hasPendingMessages(): boolean;
	setTimeout(fn: () => void, ms: number): Handle;
	clearTimer(handle: Handle): void;
	compact(options: { suppressContinuation: boolean; onError: (error: unknown) => void }): unknown;
}

interface OmpExtensionApi {
	on(event: string, handler: (event: { message?: { role?: string } }, ctx: Ctx) => void): void;
	pi: { settings: unknown };
	logger: { info(msg: string): void; warn(msg: string): void };
}

export default function (pi: OmpExtensionApi) {
	let lastRequestAt: number | undefined;
	let timer: Handle | undefined;
	let timerCtx: Ctx | undefined;

	const setting = <T>(id: string): T | undefined => lookup(id)?.get(pi.pi.settings) as T | undefined;
	const thresholdTokens = (ctx: Ctx): number | undefined => {
		if (!setting<boolean>("compaction.enabled") || !setting<boolean>("compaction.idleEnabled")) return undefined;
		const threshold = setting<number>("compaction.idleThresholdTokens") ?? 0;
		const tokens = ctx.getContextUsage()?.tokens ?? 0;
		return threshold > 0 && tokens >= threshold ? tokens : undefined;
	};

	const disarm = () => {
		if (timer !== undefined) timerCtx?.clearTimer(timer);
		timer = timerCtx = undefined;
	};

	const fire = (ctx: Ctx) => {
		timer = timerCtx = undefined;
		if (!ctx.isIdle() || ctx.hasPendingMessages()) return;
		const tokens = thresholdTokens(ctx);
		if (tokens === undefined) return;
		const onError = (e: unknown) => pi.logger.warn(`idle compaction failed: ${e}`);
		const pending = ctx.compact({ suppressContinuation: true, onError });
		if (pending instanceof Promise) pending.catch(onError);
		pi.logger.info(`idle compaction started at ${tokens} tokens`);
	};

	const arm = (ctx: Ctx) => {
		disarm();
		if (ctx.mode === "tui" || ctx.agent?.kind !== "main" || ctx.model?.provider !== "anthropic") return;
		if (lastRequestAt === undefined || thresholdTokens(ctx) === undefined) return;
		const delay = Math.max(0, lastRequestAt + FIRE_AFTER_MS - Date.now());
		timer = ctx.setTimeout(() => fire(ctx), delay);
		timerCtx = ctx;
	};

	pi.on("message_start", (event, ctx) => {
		if (event.message?.role !== "assistant" || ctx.agent?.kind !== "main") return;
		lastRequestAt = Date.now();
		disarm();
	});
	for (const name of ["agent_start", "session_compact", "session_switch", "session_branch", "session_tree", "session_shutdown"]) {
		pi.on(name, disarm);
	}
	pi.on("agent_end", (_event, ctx) => arm(ctx));
}
