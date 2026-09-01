"""Stage 2: the OSC message → Hit conversion.

Only the pure part is tested. `hit_from_osc` is deterministic and needs no
socket; the server loop needs a socket and a live Max, and a test that binds a
UDP port to prove python-osc works is testing python-osc, not this project.

The bridge itself is verified by ear and eye — hit a pad, watch the console
(§38, §56.10). That is the roadmap's exit condition and no test replaces it.
"""

import pytest

from aap.io.osc_input import hit_from_osc


def test_hit_from_osc():
    h = hit_from_osc(address="/hit/snare", velocity=0.82, elapsed_ms=12734.0)
    assert h.pad == "snare"
    assert h.velocity == 0.82
    assert h.timestamp == pytest.approx(12.734)


def test_hit_from_osc_multiword_pad():
    h = hit_from_osc(address="/hit/snare_rim", velocity=0.5, elapsed_ms=1000.0)
    assert h.pad == "snare_rim"
    assert h.velocity == 0.5
    assert h.timestamp == pytest.approx(1.0)


def test_hit_from_osc_zero_timestamp():
    h = hit_from_osc(address="/hit/kick", velocity=0.7, elapsed_ms=0.0)
    assert h.pad == "kick"
    assert h.velocity == 0.7
    assert h.timestamp == pytest.approx(0.0)


@pytest.mark.parametrize("velocity", [0.0, 0.5, 1.0])
def test_hit_from_osc_velocity_passthrough(velocity):
    h = hit_from_osc(address="/hit/tom", velocity=velocity, elapsed_ms=500.0)
    assert h.pad == "tom"
    assert h.velocity == velocity
    assert h.timestamp == pytest.approx(0.5)


@pytest.mark.parametrize(
    ("address", "message"),
    [
        ("/hit", "unexpected OSC address"),  # missing pad name
        ("/hit/", "missing pad name in OSC address"),  # missing pad name
        ("/nonsense/snare", "unexpected OSC address"),  # wrong prefix
    ],
)
def test_hit_from_osc_malformed_address(address, message):
    with pytest.raises(ValueError, match=message):
        hit_from_osc(address=address, velocity=0.5, elapsed_ms=1000.0)
