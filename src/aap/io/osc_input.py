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

# --- Transport ------------------------------------------------------------
#
# TASK 1 — constants.
#
#   HOST = "127.0.0.1", and a port for Max → Python. 7400 is a conventional
#   choice; anything above 1024 works. Stage 3 adds a second port for the
#   return path — keep them distinct and obvious (7400 in, 7500 out) so a
#   misrouted message is diagnosable rather than mysterious.
#
#   Put them here as module constants for now. When Stage 3 needs the pair,
#   that is the moment to decide whether they belong in a config file.


# --- The pure part --------------------------------------------------------
#
# TASK 2 — a function that turns one OSC message into one Hit, and touches no
# socket:
#
#       def hit_from_osc(address: str, velocity: float, elapsed_ms: float) -> Hit
#
#   Everything interesting happens here — splitting the pad name off the
#   address, converting milliseconds to seconds, range-checking — and none of
#   it needs a network. Keeping it separate from the server is what makes
#   Stage 2 testable at all (see tests/test_osc_input.py).
#
#   Points to get right:
#
#   - Deriving the pad: the address is "/hit/snare". Prefer
#     `address.rsplit("/", 1)[-1]` or a strict check that it starts with
#     "/hit/", rather than a fixed slice — you will add other namespaces later
#     (a delimiter, §14.1; controllers, §52) and a fixed slice will silently
#     mis-parse them.
#   - An address of "/hit/" or "/hit" is malformed. Decide what happens.
#   - elapsed_ms / 1000.0 — the only unit conversion in the file, and it lives
#     at the boundary by design.


# --- The plumbing ---------------------------------------------------------
#
# TASK 3 — the dispatcher.
#
#   python-osc routes by address pattern:
#
#       from pythonosc.dispatcher import Dispatcher
#       disp = Dispatcher()
#       disp.map("/hit/*", on_hit)
#       disp.set_default_handler(on_unmapped)
#
#   The handler signature is `handler(address, *args)` — the address arrives
#   as the first argument, which is exactly why the pad can live in it.
#
#   `set_default_handler` is worth wiring even though nothing needs it yet.
#   It reproduces the discovery asymmetry Stage 1 already has: in the patch, an
#   unmapped note prints on RAW but not on HIT. Here, an address you did not
#   expect prints as unmapped instead of vanishing into a silent UDP void.
#   Debugging a bridge that drops messages without saying so is miserable.

# TASK 4 — the server, and a note on threads.
#
#       from pythonosc.osc_server import BlockingOSCUDPServer
#       server = BlockingOSCUDPServer((HOST, PORT_IN), disp)
#       server.serve_forever()
#
#   Blocking is right for Stage 2: the process does nothing but listen, and a
#   single thread means no ordering questions to reason about. Stage 3 sends
#   replies from inside the handler, which a blocking server still does fine —
#   sending is not blocking. Reach for ThreadingOSCUDPServer only when
#   something genuinely has to run *while* a handler is still working, and not
#   before; concurrency you did not need is bugs you did not need.
#
#   Handle KeyboardInterrupt so Ctrl-C exits cleanly rather than dumping a
#   traceback over your console output.

# TASK 5 — main(), and running it.
#
#   Give the module a `main()` and the usual `if __name__ == "__main__":`
#   guard, so it runs as:
#
#       python -m aap.io.osc_input
#
#   Print the host and port on startup. Half of all OSC debugging is finding
#   out that the two ends disagreed about the port, and a process that starts
#   silently tells you nothing about which one is wrong.

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
