"""``Hit`` — the neutral input record (§5, §6, §36).

Tests the *decisions*, not the language. That `@dataclass` generates a working
``__eq__`` is CPython's problem; that this particular type is frozen, slotted,
range-checked and measured in seconds is ours, and each of those is easy to
lose silently in a later refactor.
"""

import pytest
import dataclasses

from aap.core import Hit

# =-=-=-=


def test_hit_construction():
    h = Hit(timestamp=1.23, pad="snare", velocity=0.5)
    assert h.timestamp == 1.23
    assert h.pad == "snare"
    assert h.velocity == 0.5


def test_hit_construction_positional():
    h = Hit(1.23, "snare", 0.5)
    assert h.timestamp == 1.23
    assert h.pad == "snare"
    assert h.velocity == 0.5


# =-=-=-=


@pytest.mark.parametrize("velocity", [0.0, 0.5, 1.0])
def test_velocity_within_range_is_accepted(velocity):
    h = Hit(timestamp=0.0, pad="snare", velocity=velocity)
    assert h.velocity == velocity


# =-=-=-=


@pytest.mark.parametrize("velocity", [-0.1, 1.1])
def test_velocity_out_of_range_raises(velocity):
    with pytest.raises(ValueError, match="out of range"):
        Hit(timestamp=0.0, pad="snare", velocity=velocity)


def test_empty_pad_name_raises():
    with pytest.raises(ValueError, match="pad name cannot be empty"):
        Hit(timestamp=0.0, pad="", velocity=0.5)


# =-=-=-=


def test_hit_is_frozen():
    h = Hit(timestamp=0.0, pad="snare", velocity=0.5)
    with pytest.raises(dataclasses.FrozenInstanceError):
        h.velocity = 0.6


# =-=-=-=


def test_hit_is_slotted():
    h = Hit(timestamp=0.0, pad="snare", velocity=0.5)
    assert not hasattr(h, "__dict__")


# =-=-=-=


def test_hit_is_hashable_and_compared_by_value():
    h1 = Hit(timestamp=0.0, pad="snare", velocity=0.5)
    h2 = Hit(timestamp=0.0, pad="snare", velocity=0.5)
    h3 = Hit(timestamp=0.1, pad="snare", velocity=0.5)

    assert h1 == h2
    assert hash(h1) == hash(h2)
    assert h1 != h3


# =-=-=-=


def test_nan_velocity_raises():
    with pytest.raises(ValueError, match="out of range"):
        Hit(timestamp=0.0, pad="snare", velocity=float("nan"))
