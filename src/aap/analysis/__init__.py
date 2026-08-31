"""Gesture segmentation and feature extraction.

Segmentation is explicit-delimiter-authoritative with a silence-threshold
fallback, and the rules may themselves change by section.

Feature extraction is deterministic and continuous — duration, IOI mean/slope/
variance, velocity mean/slope/variance, density, instrument entropy,
topological distance, direction consistency. Classification into named gesture
types is optional and, where used, is a visible threshold over these features.
No machine learning.

Also holds drum-kit topology: coordinates that let motion across the kit behave
somewhat like melodic contour.

Design notes 13-16.  Populated at roadmap Stage 6-7.
"""
