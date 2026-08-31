"""Scaffold smoke test: the package is installed and importable.

Replaced by real tests as roadmap stages land.
"""

import importlib

MODULES = [
    "aap",
    "aap.core",
    "aap.form",
    "aap.rhythm",
    "aap.analysis",
    "aap.generators",
    "aap.memory",
    "aap.constraints",
    "aap.io",
    "aap.metrics",
]


def test_every_module_imports():
    for name in MODULES:
        assert importlib.import_module(name) is not None


def test_dependencies_available():
    import mido  # noqa: F401
    import pythonosc  # noqa: F401
