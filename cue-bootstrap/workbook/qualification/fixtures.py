from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Fixture:
    id: str
    path: Path
    value_path: str = "value"

    def source(self) -> str:
        return self.path.read_text(encoding="utf-8")


ROOT = Path(__file__).resolve().parents[2]
PATTERN = ROOT / "pattern" / "bounded-int"
FIXTURES = PATTERN / "fixtures"

REGISTRY: dict[str, Fixture] = {
    "bounded-int.pattern": Fixture("bounded-int.pattern", PATTERN / "pattern.cue", "#BoundedInt"),
    "bounded-int.positive.min": Fixture("bounded-int.positive.min", FIXTURES / "positive" / "min.cue"),
    "bounded-int.positive.mid": Fixture("bounded-int.positive.mid", FIXTURES / "positive" / "mid.cue"),
    "bounded-int.positive.max": Fixture("bounded-int.positive.max", FIXTURES / "positive" / "max.cue"),
    "bounded-int.negative.below": Fixture("bounded-int.negative.below", FIXTURES / "negative" / "below.cue"),
    "bounded-int.negative.above": Fixture("bounded-int.negative.above", FIXTURES / "negative" / "above.cue"),
    "bounded-int.negative.wrong-type": Fixture("bounded-int.negative.wrong-type", FIXTURES / "negative" / "wrong_type.cue"),
    "bounded-int.directional.general": Fixture("bounded-int.directional.general", FIXTURES / "directional" / "general.cue"),
    "bounded-int.directional.bounded": Fixture("bounded-int.directional.bounded", FIXTURES / "directional" / "bounded.cue"),
    "bounded-int.directional.specific": Fixture("bounded-int.directional.specific", FIXTURES / "directional" / "specific.cue"),
}


def get(fixture_id: str) -> Fixture:
    try:
        return REGISTRY[fixture_id]
    except KeyError as exc:
        raise KeyError(f"unknown registered fixture: {fixture_id}") from exc
