"""Stage 2: the OSC message → Hit conversion.

Only the pure part is tested. `hit_from_osc` is deterministic and needs no
socket; the server loop needs a socket and a live Max, and a test that binds a
UDP port to prove python-osc works is testing python-osc, not this project.

The bridge itself is verified by ear and eye — hit a pad, watch the console
(§38, §56.10). That is the roadmap's exit condition and no test replaces it.
"""

# TASK — write these, then make them pass.
#
# 1. A well-formed message becomes the expected Hit:
#       hit_from_osc("/hit/snare", 0.82, 12734.0)
#           -> Hit(timestamp=12.734, pad="snare", velocity=0.82)
#    Use pytest.approx on the timestamp — 12734.0 / 1000.0 is not exactly
#    12.734 in binary floating point, and asserting equality on it will fail
#    for a reason that has nothing to do with your code.
#
# 2. A multi-word pad name survives intact: "/hit/snare_rim" -> "snare_rim".
#    This is the case a fixed slice into the address gets wrong.
#
# 3. Zero is a real timestamp, not a missing one: elapsed_ms=0.0 is the first
#    hit after a clock reset and must produce timestamp=0.0.
#
# 4. Velocity passes through untouched — no rescaling, no rounding. Max
#    normalised it already; doing it twice is a class of bug that produces
#    quiet-sounding performances and no error message.
#
# 5. A malformed address ("/hit", "/hit/", "/nonsense/snare") does whatever
#    you decided in osc_input.py TASK 2. Whichever you chose, pin it here —
#    the test is where the decision becomes a fact rather than an intention.
