const V2_EVENTS = {
  "session.execution.started": "session.status.busy",
  "session.execution.succeeded": "session.status.idle",
  "session.execution.failed": "session.status.idle",
  "session.execution.interrupted": "session.status.idle",
  "permission.asked": "permission.asked",
  "permission.replied": "permission.replied",
};

let pendingHook = Promise.resolve();

function runPaseoHook(event) {
  if (!process.env.PASEO_TERMINAL_ID) return;
  pendingHook = pendingHook.then(async () => {
    try {
      const child = Bun.spawn(["paseo", "hooks", "opencode", event], {
        stdin: "ignore",
        stdout: "ignore",
        stderr: "ignore",
      });
      await child.exited;
    } catch {}
  });
  return pendingHook;
}

export default {
  id: "paseo-terminal-activity",
  setup(ctx) {
    const controller = new AbortController();
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        const paseoEvent = V2_EVENTS[event.type];
        if (paseoEvent) await runPaseoHook(paseoEvent);
      }
    })().catch(() => {});
    return () => controller.abort();
  },
};
