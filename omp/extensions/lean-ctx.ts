// Loads pi-lean-ctx (installed with `omp plugin install pi-lean-ctx`) in OMP.
// The package only declares a `pi` manifest, which OMP's plugin loader skips,
// so this file is the entry point. Replace mode hides OMP's native
// read/bash/grep/find/ls and leaves the ctx_* tools.
// Its config is read at import time, so the env is set before the dynamic import.
// Without a pinned root, ctx_compose/ctx_search reject the session's own repo
// as "outside the request authority".
import { homedir } from "node:os";
import { join } from "node:path";

export default async function (pi: unknown) {
	process.env.LEAN_CTX_PI_MODE ??= "replace";
	process.env.LEAN_CTX_PROJECT_ROOT ??= process.cwd();
	const entry = join(homedir(), ".omp/plugins/node_modules/pi-lean-ctx/extensions/index.ts");
	const { default: leanCtx } = await import(entry);
	return leanCtx(pi);
}
