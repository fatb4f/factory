"""Verified schedule navigation and caller-scoped review flags."""

from copy import deepcopy
from dataclasses import dataclass
from typing import Protocol

import ibis
import pyarrow as pa

import ivac_regulatory_schedule_index as schedules
import ivac_workbench as workbench
from personal.ivac.regulatory.generated.legal_unit import ScheduleLeaf

sources = schedules.sources


@dataclass(frozen=True)
class Scope:
    """IDs authorized for this case and snapshot, including nested references."""

    case_id: str
    snapshot_id: str
    relationships: frozenset[str]
    observations: frozenset[str]
    evidence: frozenset[str]
    actors: frozenset[str]


class ScopeProvider(Protocol):
    def __call__(self, case_id: str, snapshot_id: str) -> Scope: ...


class Schedule:
    def __init__(self, index, candidate):
        index = deepcopy(index)
        text = sources.verify_acquisition(candidate["acquisition"])
        schedules.verify(index, candidate, text)
        self._sections = {s["number"]: s for s in index["sections"]}
        self._units = {u["number"]: u for u in index["units"]}
        self.version = index["acquisition"]["id"]
        self.applicability = index["caseApplicability"]

    @classmethod
    def load(cls):
        return cls(
            *(
                sources.read_json(sources.DATA / f"annex-i-2021.{part}.json")
                for part in ("schedule-index", "candidate")
            )
        )

    def unit(self, number):
        record = self._units[number]
        return LegalUnit(self, ScheduleLeaf.model_validate(record))


@dataclass(frozen=True, init=False)
class LegalUnit:
    schedule: Schedule
    _serialized_leaf: str

    def __init__(self, schedule: Schedule, leaf: ScheduleLeaf):
        if schedule._units.get(leaf.number) != leaf.model_dump(mode="json"):
            raise ValueError("leaf does not match the verified schedule")
        object.__setattr__(self, "schedule", schedule)
        object.__setattr__(self, "_serialized_leaf", leaf.model_dump_json())

    @property
    def leaf(self):
        """Return a detached view of the verified leaf."""
        return ScheduleLeaf.model_validate_json(self._serialized_leaf)

    @property
    def parent(self):
        return deepcopy(self.schedule._sections[self.leaf.section])

    def to_record(self):
        return self.leaf.model_dump(mode="json")

    @property
    def source_pieces(self):
        pieces = {p["id"]: p for p in self.parent["pieces"]}
        return [pieces[key] for key in self.to_record()["pieceIDs"]]

    def in_snapshot(self, snapshot):
        if self.schedule.version != snapshot._data["sourceVersion"]:
            raise ValueError("incompatible schedule version")
        for relationship in snapshot._data["relationships"].values():
            if relationship["unitNumber"] not in self.schedule._units:
                raise ValueError("incompatible legal-unit reference")
        return BoundUnit(self, snapshot)


class Snapshot:
    """Construct at the server boundary with a trusted caller-bound provider."""

    def __init__(
        self,
        data,
        scope_provider: ScopeProvider,
        *,
        rules=(),
        verify_basis=None,
        synthetic=False,
    ):
        self._data = deepcopy(data)
        workbench.cue_validate(self._data, "#LegalUnitSnapshot")
        if any(
            r["observationID"] not in self._data["observations"]
            for r in self._data["relationships"].values()
        ):
            raise ValueError("incompatible observation reference")
        self._provider = scope_provider
        self._rules = deepcopy(tuple(rules))
        for rule in self._rules:
            workbench.cue_validate(rule, "#CrossUnitRule")
            if rule["sourceVersion"] != data["sourceVersion"]:
                raise ValueError("incompatible rule version binding")
            if rule["status"] == "test-only":
                if not synthetic:
                    raise ValueError("test rule requires a synthetic snapshot")
            elif verify_basis is None or verify_basis(deepcopy(rule)) is not True:
                raise ValueError("unverified clinical basis")

    def _scope(self):
        spec = self._data["snapshot"]
        key = (spec["caseID"], spec["id"])
        scope = self._provider(*key) if self._provider else None
        if not isinstance(scope, Scope) or (scope.case_id, scope.snapshot_id) != key:
            raise PermissionError("caller scope unavailable")
        return scope


def _query(rows, number):
    """Execute the legal-unit selection over only authorized relationships."""
    import json

    basis = ["caller-authorized explicit relationships"]
    source = {
        "id": "links",
        "snapshotDigest": sources.spans.digest(sources.encoded(rows)),
        "provenance": basis,
        "admissibility": {
            "state": "admitted",
            "authority": "caller-scope-provider",
            "basis": basis,
        },
    }
    operation = {
        "kind": "filter",
        "predicate": "unitNumber == " + json.dumps(number),
        "basis": basis,
    }
    grain = {"keys": ["relationshipID"], "unit": "explicit-relationship"}
    plan = {
        "apiVersion": "factory.analytics-ir/v1",
        "kind": "RelationalPlan",
        "id": "legal-unit-links",
        "request": {
            "apiVersion": "factory.analytics-ir/v1",
            "kind": "AnalyticalRequest",
            "id": "legal-unit-links",
            "source": source,
            "operations": [operation],
            "grain": grain,
        },
        "steps": [operation],
        "outputGrain": grain,
        "provenance": {
            "authority": "contracts/personal/ivac/workbench/legal_units.cue",
            "basis": basis,
        },
    }
    con = ibis.duckdb.connect()
    try:
        schema = pa.schema(
            [("relationshipID", pa.string()), ("unitNumber", pa.string())]
        )
        table = con.create_table("links", pa.Table.from_pylist(rows, schema=schema))
        expr = workbench.execute_plan(plan, {"links": table}).expression
        return sorted(expr.to_pyarrow()["relationshipID"].to_pylist())
    finally:
        con.disconnect()


@dataclass(frozen=True)
class BoundUnit:
    unit: LegalUnit
    snapshot: Snapshot

    def linked_objects(self):
        scope = self.snapshot._scope()
        data = self.snapshot._data
        allowed = {}
        for key in scope.relationships.intersection(data["relationships"]):
            rel = data["relationships"][key]
            if rel["observationID"] not in scope.observations:
                continue
            obj = data["observations"][rel["observationID"]]
            provenance = obj["provenance"]
            actors = {obj["subject"]["id"]}
            if "assertedBy" in provenance:
                actors.add(provenance["assertedBy"]["id"])
            if actors <= scope.actors and all(
                e["id"] in scope.evidence for e in provenance["evidence"]
            ):
                allowed[key] = {
                    "object": obj,
                    "relationship": rel,
                    "provenance": provenance,
                }
        rows = [
            {
                "relationshipID": k,
                "unitNumber": allowed[k]["relationship"]["unitNumber"],
            }
            for k in sorted(allowed)
        ]
        return [deepcopy(allowed[k]) for k in _query(rows, self.unit.leaf.number)]

    def evaluate_cross_unit_rules(self):
        links = self.linked_objects()
        results = []
        for rule in self.snapshot._rules:
            if rule["from"] != self.unit.leaf.number:
                continue
            target = self.unit.schedule.unit(rule["target"])
            if target.leaf.section == self.unit.leaf.section:
                raise ValueError("rule target must belong to another section")
            relevant = [
                link for link in links if link["object"]["concept"] == rule["concept"]
            ]
            matches = [
                link for link in relevant if link["object"]["value"] == rule["expectedValue"]
            ]
            if matches:
                unresolved = list(rule["unresolvedConditions"])
                if len(matches) != len(relevant):
                    unresolved.append(
                        "Other authorized observations of this concept have different values; review is required."
                    )
                results.append(
                    {
                        "ruleID": rule["id"],
                        "version": rule["version"],
                        "status": rule["status"],
                        "basis": deepcopy(rule["basis"]),
                        "target": target.leaf.model_dump(mode="json"),
                        "matches": matches,
                        "unresolvedConditions": unresolved,
                    }
                )
        return results
