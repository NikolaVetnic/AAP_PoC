"""Neutral event representation — the shared vocabulary of the whole system.

``Hit``, ``Event``, ``Phrase``, ``Gesture``. Rich enough to describe a percussion
event beyond what MIDI conveniently expresses (instrument, zone, velocity,
duration, pitch shift, brightness, pan, flam, timing deviation), and independent
of any renderer, so the same phrase can go to Max, REAPER or MIDI export.

Live input and MIDI-file input both normalise to these types before reaching
the engine; nothing downstream may branch on where a hit came from.

Design notes 5, 36.  Populated at roadmap Stage 4-5.
"""
