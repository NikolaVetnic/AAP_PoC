"""Macro form: sections, formal curves, and the score loader.

``Composition``, ``Section``, ``FormalCurve``, ``CompositionState``.

The macro form has authority over the local interpretation of live input: the
same hit must mean something different at minute 1 and at minute 8. Formal
curves (autonomy, density, memory depth, ...) are the main mechanism by which
that authority reaches the microstructure.

Loads ``scores/*.json``, which is a score/configuration for the engine and not
a finished performance.

Design notes 9.2, 19-22, 31-35.  Populated at roadmap Stage 9.
"""
