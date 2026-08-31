# Algorithmically Augmented Percussion

A proof of concept for computer music built from **hierarchical, multi-parametric, partially independent and sometimes conflicting formal processes** — and for future compositions written in the same vein.

A simple live electronic-drum performance supplies structural, temporal and energetic information. A precomposed Python system interprets that information according to the current formal state, memory and multiple partially independent parametric processes, producing a complex audiovisual superstructure whose relationship to the performer changes over the course of the piece.

The premise: **compositional complexity does not require equivalent physical performance complexity.** The distribution of responsibility between performer and machine is itself part of the composition.

```
                       COMPOSITION JSON
                              |
                     precomposed formal model
                              v
ELECTRONIC DRUMS ---> MAX ---> PYTHON
       |                       |
       |                  analyze gesture / determine state
       |                  consult memory / run processes
       |                  negotiate conflicts / apply constraints
       |                       v
       +<------ MAX <----- generated phrase
                 |
          +------+------+
         MSP          JITTER
          |             |
        AUDIO         VISUALS
```

## Documents

| File | Purpose |
| --- | --- |
| [docs/design-notes.md](docs/design-notes.md) | The design rationale. 58 numbered sections; the reference for everything else. |
| [CLAUDE.md](CLAUDE.md) | How agents work in this repository: architecture boundary, conventions, discipline. |
| [ROADMAP.md](ROADMAP.md) | Staged implementation order with exit conditions. |
| [docs/decisions.md](docs/decisions.md) | Compositional decisions as they get answered by composing and listening. |

## Setup

Requires Python 3.12 and Max 8.

```sh
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest
```

## Layout

```
src/aap/      composition engine  (core, form, rhythm, analysis,
                                   generators, memory, constraints, io, metrics)
max/          Max patches, one abstraction per file
scores/       composition JSON — one file per piece
fixtures/midi/ fixed MIDI performances used as deterministic test input
reaper/       REAPER projects for offline rendering and clip preparation
renders/      audio and event logs (gitignored — reproducible from fixture + score + seed)
tests/
```
