# Roadmap

The staged implementation order from design notes §54. Build the current stage; do not build ahead of it.

Each stage has an **exit condition** that must be demonstrable, and most end in listening rather than in a green test suite (§38).

Status: `[ ]` not started · `[~]` in progress · `[x]` done

---

## Stage 0 — Project setup `[x]`

Repository, Python 3.12 venv, dependencies, test harness, agent documentation.

**Exit:** `pytest` runs; `CLAUDE.md` and this roadmap exist.

## Stage 1 — MIDI acquisition `[x]`

```
e-drum -> Max -> print note, velocity, timestamp
```

Max patch only. Establishes pad-number → instrument-name mapping for the actual hardware. No Python involved.

**Exit:** every pad and zone on the kit prints a stable, correctly named event.

Built as [max/midi-input.maxpat](max/midi-input.maxpat) + [max/pad-map.txt](max/pad-map.txt), and verified against `scratch.mid`: all 11 notes, names, normalised velocities and timestamps match the source exactly, including two coincident notes at one timestamp.

### Remaining once the kit is connected

The patch is done as a mechanism; what is left is hardware-specific and cannot be guessed. Work through this list with the kit in front of you, then record what the hardware actually does in [docs/decisions.md](docs/decisions.md).

1. **Discover the real note numbers.** `pad-map.txt` currently holds General MIDI defaults, which are a guess. Strike every pad and every zone; anything printing on `RAW` with no matching `HIT` is unmapped. Rewrite the file from what the kit actually sends.
2. **Zones are the bulk of the work.** §2.1 wants 20–30 articulation states, not five drums — snare centre/rim/rimshot/cross-stick, hi-hat closed/half/open/pedal/bell, ride bow/bell/edge. Find out which of these the hardware distinguishes at all; that sets a hard ceiling on the vocabulary available to the composition.
3. **Continuous controllers are not handled yet.** The patch has no `ctlin` — it sees notes only. Hi-hat pedal position and any positional sensing arrive as CC (§52) and are currently invisible. Decide whether Stage 1 grows to cover them or they wait until they are actually used.
4. **Cymbal choke is likewise invisible.** `stripnote` discards note-offs by design, and choke usually arrives as a note-off, aftertouch or CC. If choke is wanted as a gesture delimiter or an INTERRUPT trigger (§18), this path has to exist.
5. **Check the velocity range in practice.** §8 treats velocity as energy across 0–1, which assumes the full range is reachable. Play as softly and as hard as you can and see whether soft hits reach low values and hard hits saturate at 127. The module's velocity curve may need changing, or a compensating curve may be needed at the edge.
6. **Check for double-triggering and crosstalk.** One physical strike must produce exactly one event, and hitting one pad must not trigger its neighbour. Both are pad/module tuning problems, and both would silently corrupt every gesture feature computed downstream (§15).
7. **Choose the gesture delimiter and reserve its note number** (§14.1, §53). Decide then whether it is silent or audible — §57.7 leaves this open deliberately, so it is a question for playing, not for deciding here.
8. **Measure end-to-end latency** on the real path, as the baseline the Stage 3 immediate-sound optimisation (§3.3) has to beat.

## Stage 2 — Python bridge `[ ]`

```
e-drum -> Max -> OSC -> Python -> console
```

Semantic OSC addresses (`/hit/snare 0.82`), not note numbers (§4).

**Exit:** hitting a pad prints a `Hit` in the Python console with plausible latency.

> **The composer is writing this stage by hand.** Guide, review, explain and debug on request — do not write the bridge for them. Offer the design tradeoffs and let them choose. This applies to Stage 2 specifically; ask before assuming it extends further.

## Stage 3 — Return path `[ ]`

```
e-drum -> Max -> Python -> generated event -> Max -> sample
```

Also implement the immediate-sound optimisation (§3.3): the physical hit sounds in Max at once; the Python response arrives as elaboration.

**Exit:** one hit produces one machine-generated sound with no audible lag on the struck note.

## Stage 4 — One archetype `[ ]`

Implement only `Fragment` (§7.2, §18). One hit creates a deterministic generated phrase. Phrase carries **relative offsets**; Max schedules it (§3.2).

**Exit:** hitting harder audibly produces a denser fragmentation (§8).

## Stage 5 — Fixed MIDI simulation `[ ]`

Build the tiny mapping fixture (§37) and make live and file input normalise into the same `Hit` type (§36). This is the deterministic test harness everything later depends on — do not defer it.

**Exit:** the same fixture rendered twice produces byte-identical event logs.

## Stage 6 — Gesture segmentation `[ ]`

Explicit delimiter as authoritative, silence threshold as fallback (§14.3).

**Exit:** the gesture fixture segments exactly as intended, verified against the log.

## Stage 7 — Feature extraction `[ ]`

`duration`, `density`, IOI slope, velocity slope, topological distance (§15, §16). Deterministic and continuous — no classification.

**Exit:** features on the gesture fixture match hand-computed expectations.

## Stage 8 — Rhythmic trees `[ ]`

Hierarchical proportional subdivision with exact `Fraction` arithmetic (§17).

**Exit:** a tree fits a human-defined span, and the same tree audibly keeps its identity at two different spans.

## Stage 9 — Formal state `[ ]`

Sections and one or two formal curves, loaded from `scores/*.json` (§19–22, §31–33).

**Exit:** the same hit produces recognisably different responses at minute 1 and minute 8 (§9.2).

## Stage 10 — Additional archetypes `[ ]`

Propagate, Converge, Resonate, Shadow, Interrupt (§18).

**Exit:** blind listening — each archetype is identifiable as itself when it returns.

## Stage 11 — Memory `[ ]`

Literal short-term recall first, then partial and transformed recall (§28–30).

**Exit:** remembered material sounds *related* to its source, not identical to it (§56.7).

## Stage 12 — Conflicting layers `[ ]`

Separate rhythm, density, dynamics, topology, timbre and memory into independent processes that make competing demands, negotiated by layer weights (§25–27, §34).

**Exit:** non-alignment is audible, not merely numerical (§38 system evaluation).

## Stage 13 — Constraints `[ ]`

Hard limits and soft preferences; candidate generation and scoring (§24).

**Exit:** the machine never obscures the next structural human cue.

## Stage 14 — Visual layer `[ ]`

Jitter, added only once the musical system is understandable (§47–51). Visuals operate at gesture/archetype/formal resolution, never one flash per hit (§48).

**Exit:** the human/machine formal trajectory is visible without explanation (§57.17).

---

## Standing test fixtures (§37)

| Fixture | Contents | Tests |
| --- | --- | --- |
| `fixtures/midi/tiny.mid` | 4–5 events: snare p, snare ff, tom mf, cymbal f | pad + velocity mapping, phrase selection, OSC, scheduling |
| `fixtures/midi/gesture.mid` | 10–20 s: accel, decel, cresc, dim, pad trajectory, pause, delimiter | segmentation, feature extraction, memory, gesture response |
| `fixtures/midi/benchmark.mid` | 2 min: sparse/dense, soft/loud, regular/irregular, long silence, several gesture boundaries | permanent regression test for the whole engine |

Keep `benchmark.mid` unchanged forever. Its value is that it does not move.

## The first piece (§53)

A 7–11 minute solo electronic-percussion study. Human resources: kick, snare, 2–3 toms, hi-hat, ride/crash, gesture delimiter. Form: Dependence → Elaboration → Memory → Conflict → Residue.
