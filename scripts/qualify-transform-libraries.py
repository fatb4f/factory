"""T1 qualification probes for the candidate upstream stack."""
from importlib.metadata import version
import unittest

PINS = {"pydantic": "2.14.0", "ibis-framework": "11.0.0", "duckdb": "1.5.6", "pyarrow": "26.0.0"}


class Qualification(unittest.TestCase):
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
