"""T1 qualification probes for the candidate upstream stack."""
from hashlib import sha256
from importlib.metadata import distribution, version
from pathlib import Path
import unittest

PINS = {"pydantic": "2.14.0", "ibis-framework": "11.0.0", "duckdb": "1.5.6", "pyarrow": "26.0.0"}


# Reviewed release declarations; the compiled DuckDB interface is backed by its wheel stub.
DECLARATIONS = (
    ("pydantic", "pydantic/main.py", "84335fc05a112a2834af4a048f71c6a7c46b90f4468bee541da36e438a387190"),
    ("pydantic", "pydantic/config.py", "ce6280cd61c4d3ce852122e3f75996711baed907ccab1b609a9aebf6f1a12171"),
    ("ibis-framework", "ibis/backends/duckdb/__init__.py", "4936175fec92d960f68123b1e145b1ea0919aca97f6757425b0493024c69bfa5"),
    ("duckdb", "duckdb/__init__.py", "c5b4efa32761b6ff6eed37cda365fd371743c062ffabd9125aa24b5f13b662e7"),
    ("duckdb", "_duckdb-stubs/__init__.pyi", "635861d25b401a6ecddb1274a38f5194b736bdec049585824e7d86a53eff9471"),
)


class Qualification(unittest.TestCase):
    def test_installed_declarations_match_reviewed_sources(self):
        requirements = Path(__file__).with_name("requirements-ivac-regulatory.txt")
        pins = dict(line.split("==") for line in requirements.read_text().splitlines()
                    if line and not line.startswith("#"))
        declared = {name.partition("[")[0]: pin for name, pin in pins.items()}
        self.assertEqual({name: declared[name] for name in PINS}, PINS)
        for package, filename, expected in DECLARATIONS:
            with self.subTest(package=package, file=filename):
                dist = distribution(package)
                self.assertEqual(dist.version, PINS[package])
                self.assertEqual(sha256(dist.locate_file(filename).read_bytes()).hexdigest(), expected)

    def test_pydantic_strict_closed_wire_round_trip(self):
        self.assertEqual(version("pydantic"), PINS["pydantic"])
        from pydantic import BaseModel, ConfigDict, ValidationError

        class Row(BaseModel):
            model_config = ConfigDict(strict=True, extra="forbid")
            key: int
            label: str

        wire = {"key": 1, "label": "synthetic"}
        self.assertEqual(Row.model_validate(wire).model_dump(mode="json"), wire)
        for invalid in ({**wire, "key": "1"}, {**wire, "extra": True}):
            with self.assertRaises(ValidationError):
                Row.model_validate(invalid)

    def test_ibis_duckdb_deterministic_null_preserving_execution(self):
        import ibis

        for package in ("ibis-framework", "duckdb", "pyarrow"):
            self.assertEqual(version(package), PINS[package])
        backend = ibis.duckdb.connect()
        try:
            rows = ibis.memtable({"key": [3, 2, 1], "value": [None, 20, 10]})
            expr = rows.filter(rows.key != 2).order_by("key")
            result = backend.to_pyarrow(expr)
            self.assertEqual(result.to_pylist(), [{"key": 1, "value": 10}, {"key": 3, "value": None}])
        finally:
            backend.disconnect()


if __name__ == "__main__":
    unittest.main()
