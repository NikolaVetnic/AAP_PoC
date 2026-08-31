# CLAUDE.md

Operating instructions for agents working in this repository.

## What this is

A proof-of-concept for **algorithmically augmented percussion**: a simple live electronic-drum performance supplies structural, temporal and energetic information; a precomposed Python system interprets it according to the current formal state, memory and several partially independent parametric processes; Max/MSP renders the result as audio and (later) visuals.

The full design rationale is [docs/design-notes.md](docs/design-notes.md). **Read the relevant section before implementing anything.** Section numbers are stable — cite them in commit messages and code comments (e.g. `see design notes §17`).

This is an art project. It is a proof of concept for *future compositions written in the same vein*, so the system matters more than this one piece. Prefer general mechanisms parameterised by score data over anything hardcoded to a single piece.

## The one architectural boundary that must not blur

```
Python answers  ->  WHAT should happen
Max answers     ->  HOW and exactly WHEN it should sound
```

- Anything genuinely time-critical stays in Max. Python must never `sleep` between events and dribble them out one at a time.
- Python emits **whole phrases with relative event offsets**; Max schedules them (§3.2).
- Python sends **semantic compositional information**, never pixels, geometry, or audio samples (§47).
- The composition logic must not become dependent on Max. The neutral event representation (§5) is the boundary; Max, REAPER and MIDI export are all just renderers behind it.

## Layout

| Path | Holds |
| --- | --- |
| `src/aap/core/` | Neutral representation: `Hit`, `Event`, `Phrase`, `Gesture` (§5). The shared vocabulary every other module speaks. |
| `src/aap/form/` | `Composition`, `Section`, `FormalCurve`, `CompositionState` — macro form and the JSON score loader (§19–22, §31–35). |
| `src/aap/rhythm/` | `RhythmicTree`, hierarchical proportional subdivision (§17). |
| `src/aap/analysis/` | Gesture segmentation and deterministic feature extraction (§14–15). |
| `src/aap/generators/` | Phrase archetypes: Fragment, Converge, Propagate, Resonate, Shadow, Interrupt (§18). |
| `src/aap/memory/` | `GestureMemory`, recall and transformation, memory timescales (§28–30). |
| `src/aap/constraints/` | Hard limits, soft preferences, candidate scoring (§24), layer-weight negotiation (§25–27). |
| `src/aap/io/` | OSC live input/output, MIDI-file input, event logging (§4, §36, §42). |
| `src/aap/metrics/` | Descriptors for comparing renders (§41). Descriptors, never quality scores. |
| `max/` | Max patches. `max/abstractions/` holds the modular pieces (§44). |
| `scores/` | Composition JSON — one file per piece (§31–32). |
| `fixtures/midi/` | Fixed MIDI performances used as deterministic test input (§36–37). |
| `renders/` | Audio renders and event logs. Gitignored. |
| `reaper/` | REAPER projects for offline rendering and clip preparation. |

## Conventions

**Time.** Use `fractions.Fraction` for all structural/proportional calculation. Convert to float seconds only at render time, at the I/O boundary (§17).

**Determinism.** The engine must produce identical output from identical input. Any stochastic process takes an explicit seed, and the seed goes in the event log (§42). Never call the global `random` module directly — thread a `Random` instance through. This is what makes A/B testing meaningful (§39).

**No machine learning.** Deterministic feature extraction and explicit rules only (§15). If a categorical label is wanted, derive it from continuous features with a visible threshold.

**Input normalisation.** The engine must not know whether a `Hit` came from live e-drums or a MIDI file (§36). Both normalise to the same type before entering the engine. Anything that branches on input source is a design error.

**Semantic protocol.** OSC addresses carry meaning (`/hit/snare`), not MIDI note numbers (§4). Pad-number-to-name mapping happens once, at the edge.

**Naming.** Use the design document's vocabulary exactly: gesture, phrase, archetype, formal state, autonomy, topology, residue. Do not invent synonyms.

**File names.** SCREAMING_CASE for the root meta documents (`README.md`, `CLAUDE.md`, `ROADMAP.md`); kebab-case for content under `docs/`, `max/`, `scores/` and `fixtures/`; snake_case only for `.py`, where it is an identifier convention and nothing else. Fixture and score names reach the code as string literals, and macOS is case-insensitive where CI is not — so keep them lowercase and the mismatch cannot happen. The `.RPP` extension stays uppercase because REAPER writes it that way.

**A REAPER project and its export share a stem.** `reaper/gesture.RPP` is the source you edit; `fixtures/midi/gesture.mid` is what the engine reads. The shared stem is the entire relationship — no `_export`, `_final` or `_v2` suffix. A fixture is defined by not changing (§37), so a version number in the name is an invitation to edit one in place. New variant, new stem.

**Render filenames are generated, not typed,** and encode what varied, because A/B comparison is the point (§39, §42): `renders/<fixture>-<score>-<preset>-s<seed>.wav`, e.g. `benchmark-study1-fragment-violent-s42.wav`. Slugify preset names to kebab on the way out — they are snake_case as JSON keys in the score, which is correct there and should not leak into a filename.

**Markdown is unwrapped.** One line per paragraph, list item and blockquote — no hard wrapping at a column. A one-word edit then changes one line instead of rewrapping the paragraph, and exact-string edits do not have to span line breaks. Code fences and tables keep their own line structure. Editors soft-wrap; do not do it by hand.

## Working discipline

**Follow the roadmap.** [ROADMAP.md](ROADMAP.md) mirrors the staged implementation order from §54. Build the current stage; do not build ahead of it. The object model in §55 is *a possible destination, not a mandatory initial architecture* — do not scaffold those classes before a stage needs them.

**Every stage ends listening, not passing tests.** Tests prove the code does what was specified; only the ear decides whether the specification was worth anything (§38, §41, §56.10). A stage is not done until it has been rendered and heard.

**Change one hypothesis at a time.** When altering compositional behaviour, keep the MIDI fixture fixed and vary a single parameter, so a difference in the render has exactly one cause (§39).

**Max patches.** Generate them modularly, one abstraction per file — never one enormous patch (§44). Valid JSON is not a valid patch: **you cannot verify a `.maxpat` yourself.** After writing or editing one, stop and ask the user to open it in Max and report the Max Console output. Treat Max as the validator.

**Prefer presets to search.** When exploring generator parameters, define a few named, musically meaningful presets rather than sweeping the space (§40).

## Decide vs. ask

Decide yourself: code structure, types, tests, refactors, tooling, anything the design notes already settle.

Ask the user: musical and formal choices — section durations, which archetypes belong in a section, curve shapes, mapping ranges, whether something sounds right. §57 lists seventeen questions the document deliberately leaves open; those are answered by composing and listening, not by reasoning in a chat. Surface the tradeoff and let the composer choose.

## Commands

```sh
source .venv/bin/activate     # Python 3.12
pytest                        # tests
ruff check . && ruff format .  # lint + format
```
