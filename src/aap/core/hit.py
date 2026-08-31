"""``Hit`` — one physical strike, however it arrived.

The first inhabitant of the neutral representation (§5). Deliberately small: a
``Hit`` is *input*, and input carries only what a performer actually supplied —
WHAT was struck, WHEN, and HOW HARD (§6). The richer fields in §5's example
(duration, brightness, pan, flam, timing deviation) belong to ``Event``, which
is *output*, and which Stage 4 will need. Do not add them here yet.

Both live OSC input and MIDI-file input normalise to this type before entering
the engine; nothing downstream may branch on which one it was (§36).

Design notes §5, §6, §36. Roadmap Stage 2.
"""

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Hit:
    """One physical strike, however it arrived."""

    timestamp: float
    pad: str
    velocity: float

    def __post_init__(self):
        if not (0.0 <= self.velocity <= 1.0):
            raise ValueError(f"velocity {self.velocity} out of range [0.0, 1.0]")
        if not self.pad:
            raise ValueError("pad name cannot be empty")
