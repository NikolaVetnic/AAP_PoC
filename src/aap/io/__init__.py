"""The I/O boundary: OSC, MIDI fixtures, event logging.

Inputs (``OscLiveInput``, ``MidiFileInput``) normalise to the same ``Hit`` type,
so the engine cannot tell a live performer from a fixture. Outputs
(``OscMaxOutput``, ``EventLogger``) emit whole phrases with relative offsets for
Max to schedule — never one time-delayed message per event.

OSC addresses are semantic (``/hit/snare 0.82``), not MIDI note numbers; the
pad-number-to-name mapping happens once, here at the edge.

``EventLogger`` writes the source hit, the formal state, the resulting phrase and
any random seed, which is what makes performances reproducible and A/B
comparison meaningful.

Design notes 4, 36, 42.  Populated at roadmap Stage 2-3, 5.
"""
