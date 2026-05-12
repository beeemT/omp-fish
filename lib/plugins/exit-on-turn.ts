import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

let didShutdown = false;

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async (_event, ctx) => {
		if (process.env.OMP_EXIT_ON_COMPLETE !== "1" || didShutdown) return;
		didShutdown = true;

		// ctx.shutdown() is the documented graceful API, but it is currently a no-op
		// in interactive mode (see https://github.com/can1357/oh-my-pi/issues/1020).
		// Native-free fallback for omp 14.9.3, where ctx.shutdown() is a no-op
		// in interactive mode. Do not import @oh-my-pi/pi-utils here: its package
		// barrel loads pi-natives on demand under Bun and can segfault during exit.
		// omp already registers postmortem cleanup signal handlers; emitting SIGTERM
		// runs them without loading another native module from the extension.
		ctx.shutdown();
		setTimeout(() => {
			if (!process.emit("SIGTERM")) {
				process.exit(0);
			}
		}, 250);
	});
}
