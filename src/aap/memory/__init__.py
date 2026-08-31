"""Machine memory.

``GestureMemory`` stores gestures with relative event timing plus extracted
features, so a gesture keeps its identity independently of when it occurred.

Recall transforms rather than repeats: temporal compression/expansion,
topological mapping, dynamic inversion, and partial recall of a single property
(rhythm, velocity contour, topology, density profile) into new material.

Three horizons — short-term (last 2-4 gestures), medium-term (current section),
long-term (earlier sections) — with the macro form deciding which is active.
Memory is a formal device, not a technical effect.

Design notes 28-30.  Populated at roadmap Stage 11.
"""
