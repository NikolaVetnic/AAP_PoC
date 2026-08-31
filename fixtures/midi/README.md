# MIDI fixtures

Fixed MIDI performances used as deterministic engine input (design notes §36–37).

Without them, two variables change at once — the performance *and* the algorithm. With them, only the composition engine changes between renders, which is what makes A/B comparison mean anything.

| File | Length | Contents |
| --- | --- | --- |
| `tiny.mid` | 4–5 events | snare p, snare ff, tom mf, cymbal f |
| `gesture.mid` | 10–20 s | acceleration, deceleration, crescendo, diminuendo, pad trajectory, pause, delimiter |
| `benchmark.mid` | 2 min | sparse/dense, soft/loud, regular/irregular, accelerating/decelerating, repeated pad, changing pads, long silence, several explicit gesture boundaries |

**`benchmark.mid` is permanent.** It is the regression test for the composition engine, and its value comes entirely from not changing. Add new fixtures instead of editing it.

## Scratch

`scratch.mid` is the exception to all of that: a throwaway used while bringing the pipeline up. Change it freely, and never cite it as evidence in [docs/decisions.md](../../docs/decisions.md) or treat a render made from it as a baseline — a comparison is only meaningful against a fixture that has not moved.

Each fixture is exported from a REAPER project of the same stem, `reaper/<stem>.RPP`. The project is the source you edit; the `.mid` here is what the engine reads. Re-export to the same filename rather than adding a suffix.
