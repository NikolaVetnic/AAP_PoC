# Scores

One JSON file per piece. A score is **not** a finished performance — it is a score/configuration for the Python engine (design notes §31).

```
Python source   defines the general system
score JSON      defines one particular piece
Max patch       defines the performance/rendering environment
```

A score holds form and section boundaries, formal curves, selected rhythmic trees, phrase-archetype parameters, transformations, mappings, constraints and per-section layer weights.

It can also describe *relationships* rather than only values — a mapping from `hit.velocity` to fragmentation depth, or a weighted combination of several sources — at which point it functions as a small domain-specific language for algorithmic composition, with Python as its interpreter (§35).
