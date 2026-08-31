# Max patches

One abstraction per file — never one enormous patch (design notes §44).

Planned modules:

```
midi-input.maxpat        pad/zone -> semantic name, velocity normalisation
python-bridge.maxpat     OSC send/receive
event-scheduler.maxpat   schedules phrases from relative offsets
percussion-voice.maxpat  one voice: sample + resonator + shaping
sample-engine.maxpat     sample mapping and playback
gesture-history.maxpat   local display/debug of recent input
visual-engine.maxpat     Jitter (Stage 14, not before)
```

## pad-map.txt

`coll` data mapping MIDI note number to semantic pad name, loaded by `midi-input.maxpat`. One entry per line, `note, name;`. Currently General MIDI drum defaults — **replace these with whatever the actual kit sends.** Editing this file is how the kit gets configured; the patch never changes.

A note absent from the map prints on `RAW` but not on `HIT`. That asymmetry is the discovery mechanism: hit every pad and zone, and anything that appears only as RAW is a note number still needing a name.

Names are snake_case and match the design notes' vocabulary (`floor_tom`, `snare_rim`, `hihat_closed`), because they become OSC addresses downstream (§4, §16).

**Max is the validator.** A syntactically valid `.maxpat` JSON file is not necessarily a correct patch, and an agent cannot verify one on its own. After any patch is written or edited: open it in Max, check the Max Console, test the behaviour, report back.

The patch should eventually become stable infrastructure. Development-time patch generation is used sparingly; performance-time musical generation happens in Python (§45).
