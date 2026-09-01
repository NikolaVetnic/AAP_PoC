"""Live OSC input: Max → Python. The listening half of the Stage 2 bridge.

Max sends one message per strike, with the pad name in the *address* and the
measurements as arguments (§4):

    /hit/snare 0.82 12734.0
    ^^^^ ^^^^^ ^^^^ ^^^^^^^
    |    |     |    ms since the Max clock was reset
    |    |     velocity, already normalised 0.–1. in the patch
    |    semantic pad name from pad-map.txt — never a note number
    the namespace

Addresses carry meaning. That is not decoration: it means the note number and
the 0–127 velocity range die inside midi-input.maxpat and nothing in Python
ever learns they existed (§4, CLAUDE.md).

Design notes §4, §36. Roadmap Stage 2.
"""

import sys
import time

from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer

from aap.core.hit import Hit

# --- Transport ------------------------------------------------------------

HOST = "127.0.0.1"
PORT_IN = 7400
PORT_OUT = 7500


# --- The pure part --------------------------------------------------------


def hit_from_osc(address: str, velocity: float, elapsed_ms: float) -> Hit:
    """Convert one OSC message into one Hit.

    The address is "/hit/snare", the velocity is already normalised 0.–1., and
    elapsed_ms is the time since the Max clock was reset. Return a Hit with
    the pad name, velocity, and timestamp in seconds.
    """
    if not address.startswith("/hit/"):
        raise ValueError(f"unexpected OSC address: {address!r}")
    pad = address.rsplit("/", 1)[-1]
    if not pad:
        raise ValueError(f"missing pad name in OSC address: {address!r}")
    timestamp = elapsed_ms / 1000.0

    return Hit(pad=pad, velocity=velocity, timestamp=timestamp)


# --- The plumbing ---------------------------------------------------------


def build_dispatcher() -> Dispatcher:
    """Wire the OSC address space to its handlers.

    Built by a function rather than at import time: the handlers close over the
    latency baseline, and importing this module has to stay free of side effects
    so the pure half stays testable without a socket.
    """
    baseline: float | None = None

    def on_hit(address: str, velocity: float, elapsed_ms: float) -> None:
        """Build the Hit, report it, and measure what the transport cost.

        Nothing consumes the Hit yet; Stage 2 ends at the print. The figure
        printed is this offset against the first one seen, because the Max and
        Python clocks have unrelated origins — only the spread is a
        measurement, and the first line is the reference, not a perfect reading
        (roadmap Stage 2 exit).
        """
        nonlocal baseline
        arrival = time.perf_counter()
        hit = hit_from_osc(address, velocity, elapsed_ms)
        offset = arrival - hit.timestamp

        if baseline is None:
            baseline = offset

        print(f"hit {hit.pad:14s} vel {hit.velocity:4.2f} {(offset - baseline) * 1000:+5.1f} ms")

    def on_unmapped(address: str, *args) -> None:
        """Report an address nothing is mapped to, rather than dropping it.

        The counterpart to the patch printing an unmapped note on RAW but not on
        HIT: a message you did not expect should be visible, not swallowed by a
        silent UDP void (§4).
        """
        print(f"unmapped OSC message: {address} {args}", file=sys.stderr)

    disp = Dispatcher()

    disp.map("/hit/*", on_hit)
    disp.set_default_handler(on_unmapped)

    return disp


def main() -> None:
    """Run the OSC input server.

    The dispatcher is built here so it can close over the latency baseline.
    """
    server = BlockingOSCUDPServer((HOST, PORT_IN), build_dispatcher())
    print(f"listening for OSC on {server.server_address} (Ctrl-C to exit)")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nexiting on Ctrl-C")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()


# --- Measuring the exit condition ----------------------------------------
#
# TASK 6 — "plausible latency" (roadmap Stage 2 exit).
#
#   You cannot measure latency by subtracting Max's timestamp from Python's
#   clock: the two have unrelated origins, so the difference is dominated by a
#   meaningless constant offset. What *is* meaningful is how much that
#   difference moves.
#
#   So: record `time.perf_counter()` on arrival, compute
#   `arrival - hit.timestamp`, and watch the spread across a few dozen hits.
#   A stable offset means the transport is adding a constant delay and nothing
#   worse. A spread of several milliseconds that grows with playing density
#   means something is queueing, and Stage 3 will feel it.
#
#   Keep this as a debug print for now. It is a measurement you take once and
#   record in docs/decisions.md, not a permanent feature.
