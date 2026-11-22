#!/usr/bin/env python3
"""Pinned declaration compatibility and CUE/native boundary regressions."""
from __future__ import annotations

import ast
import copy
from dataclasses import FrozenInstanceError, is_dataclass
import inspect
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from python_api_facts import BindingError, ROOT, declarations, export, extract, guard, verify, vet
from native_python_projection import render_native
from generate_semantic_runtime_types import render as render_legacy
from runtime.generated import native_semantic_context as native
from runtime.native_binding import NativeBindingError, NativeModelAdapter, UNSET, to_wire
from runtime.semantic_runtime import SemanticRuntime


class NativeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.plan = export("nativePythonProjection")
        cls.facts = json.loads((ROOT / "state/python-api/facts.json").read_text())
        cls.adapter = NativeModelAdapter(native)

    def test_pinned_facts_and_both_generators_reproduce(self):
        verify(self.facts, self.plan["apiSource"])
        self.assertEqual(render_native(self.plan, self.facts), (ROOT / "runtime/generated/native_semantic_context.py").read_text())
        self.assertEqual(render_legacy(export("semanticRuntimeProjection")), (ROOT / "runtime/generated/semantic_context.py").read_text())
        self.assertEqual(self.facts["behavior"], "not-qualified")

    def test_native_nested_objects_and_missing_values(self):
        wire = {"authority": {"id": "fixture", "contract": "contracts/state/semantic-context.cue"}, "subject": "sample"}
        value = self.adapter.decode_validated("SemanticRef", wire)
        self.assertIsInstance(value.value.authority, native.SemanticAuthorityRef)
        self.assertIs(value.value.kind, UNSET)
        self.assertEqual(to_wire(value.value), wire)
        self.assertEqual(value.admission, "not-determined")
        self.assertEqual(value.plan_digest, native.PLAN_DIGEST)
        self.assertEqual(value.api_facts_digest, native.API_FACTS_DIGEST)
        self.assertTrue(is_dataclass(value.value))
        self.assertFalse(hasattr(value.value, "__dict__"))
        with self.assertRaises(FrozenInstanceError):
            value.value.subject = "changed"

    def test_full_provenance_and_tuple_round_trip(self):
        wire = {"id": "artifact", "plane": "documentary", "role": "source",
                "subjects": [{"authority": {"id": "fixture", "contract": "contracts/state/semantic-context.cue"}, "subject": "sample"}],
                "occurrence": {"id": "source", "source": {"kind": "document", "id": "synthetic"},
                               "locator": "fixture", "payloadDigest": "sha256:" + "a" * 64,
                               "revisionHint": "fixture", "acquiredAt": "fixture-time", "lineStart": 1,
                               "lineEnd": 3, "byteStart": 0, "byteEnd": 12}}
        value = self.adapter.decode_validated("ContextArtifact", wire).value
        self.assertIsInstance(value.subjects, tuple)
        self.assertIsInstance(value.subjects[0], native.SemanticRef)
        self.assertIsInstance(value.occurrence.source, native.SourceIdentity)
        self.assertEqual(to_wire(value), wire)

    def test_shape_validation_is_separate_from_construction_and_admission(self):
        wire = {"authority": {"id": "fixture", "contract": "contracts/state/semantic-context.cue"}, "subject": ""}
        self.assertEqual(self.adapter.decode("SemanticRef", wire).subject, "")
        with self.assertRaises(NativeBindingError):
            self.adapter.decode_validated("SemanticRef", wire)
        occurrence = {"id": "source", "source": {"kind": "document", "id": "fixture"},
                      "locator": "x", "payloadDigest": "sha256:bad"}
        with self.assertRaises(NativeBindingError):
            self.adapter.decode_validated("SourceOccurrence", occurrence)
        occurrence["payloadDigest"] = "sha256:" + "a" * 64
        occurrence["lineStart"] = 0
        with self.assertRaises(NativeBindingError):
            self.adapter.decode_validated("SourceOccurrence", occurrence)
        wire["subject"] = "not-in-snapshot"
        validated = self.adapter.decode_validated("SemanticRef", wire).value
        runtime = SemanticRuntime({"identity": {"digest": "sha256:" + "b" * 64}, "subjects": []})
        with self.assertRaises(KeyError):
            runtime.semantic(validated)

    def test_runtime_accepts_native_refs_without_breaking_legacy(self):
        wire = {"authority": {"id": "fixture", "contract": "contracts/state/semantic-context.cue"}, "subject": "sample"}
        value = self.adapter.decode_validated("SemanticRef", wire).value
        runtime = SemanticRuntime({"identity": {"digest": "sha256:" + "b" * 64}, "subjects": [wire]})
        self.assertEqual(runtime.semantic(value).ref.subject, runtime.semantic(wire).ref.subject)
        import dataclasses
        params = inspect.signature(dataclasses.dataclass).parameters
        self.assertTrue({"slots", "frozen", "kw_only"} <= params.keys())

    def test_native_wire_shape_rejections(self):
        base = {"authority": {"id": "fixture", "contract": "contracts/state/semantic-context.cue"}, "subject": "sample"}
        for value in [dict(base, kind=None), dict(base, unknown=True), {"subject": "missing authority"}, dict(base, subject=12)]:
            with self.subTest(value=value), self.assertRaises(NativeBindingError):
                self.adapter.decode("SemanticRef", value)
        with self.assertRaises(NativeBindingError):
            self.adapter.decode("SourceIdentity", {"id": "x", "kind": "invented"})
        with self.assertRaises(NativeBindingError):
            to_wire(UNSET)

    def test_source_and_fact_tampering_rejected(self):
        source = copy.deepcopy(self.plan["apiSource"])
        source["files"]["dataclasses"]["digest"] = "sha256:" + "0" * 64
        with self.assertRaisesRegex(BindingError, "source digest"):
            extract(source)
        facts = copy.deepcopy(self.facts)
        facts["symbols"]["dataclass"]["declarations"][0]["parameters"] = []
        with self.assertRaisesRegex(BindingError, "pinned declaration"):
            verify(facts, self.plan["apiSource"])
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / self.plan["source"]
            path.parent.mkdir(parents=True)
            path.write_text("tampered")
            with self.assertRaisesRegex(NativeBindingError, "authority source drift"):
                NativeModelAdapter(native, Path(directory))

    def test_binding_constraints_and_identifier_rejections(self):
        mutations = [
            lambda p: p["decorator"].update(api="missing"),
            lambda p: p["decorator"]["keywords"].update(slots=False),
            lambda p: p["types"][0]["fields"][0].update(annotation={"kind": "python-code", "code": "bad()"}),
            lambda p: p["types"].append(copy.deepcopy(p["types"][0])),
            lambda p: p["types"][0]["fields"].append(copy.deepcopy(p["types"][0]["fields"][0])),
            lambda p: p["types"][1]["fields"][0]["annotation"].update(name="Absent"),
            lambda p: p["types"][0].update(name="x; bad()"),
            lambda p: p["types"][0].update(name="UNSET"),
            lambda p: p["types"][0]["fields"][0].update(name="dataclasses"),
            lambda p: p.update(cuePackage="wrong_package"),
            lambda p: p["types"][0].update(cueType="#Absent"),
        ]
        for mutation in mutations:
            plan = copy.deepcopy(self.plan)
            mutation(plan)
            with self.assertRaises(BindingError):
                render_native(plan, self.facts)
        facts = copy.deepcopy(self.facts)
        facts["symbols"].pop("tuple")
        with self.assertRaises(BindingError):
            vet({"plan": self.plan, "facts": facts}, "#NativePythonBinding")

    def test_version_guards_are_selected_and_unknown_guards_fail_closed(self):
        self.assertTrue(guard(ast.parse("sys.version_info > (3, 12)", mode="eval").body, (3, 12)))
        self.assertFalse(guard(ast.parse("sys.version_info == (3, 12)", mode="eval").body, (3, 12)))
        with self.assertRaises(BindingError):
            guard(ast.parse("sys.version_info >= (3, 12, 5)", mode="eval").body, (3, 12))
        code = "if sys.version_info >= (3, 12):\n def api(*, slots: bool = False): ...\nelse:\n def api(): ...\n"
        tree = ast.parse(code)
        self.assertEqual(len(list(declarations(tree.body, "api", (3, 12)))[0][0].args.kwonlyargs), 1)
        self.assertEqual(len(list(declarations(tree.body, "api", (3, 11)))[0][0].args.kwonlyargs), 0)
        tree = ast.parse("if platform_unknown:\n def api(): ...\n")
        with self.assertRaisesRegex(BindingError, "unsupported relevant"):
            list(declarations(tree.body, "api", (3, 12)))
        source = copy.deepcopy(self.plan["apiSource"])
        source["requests"]["str"]["symbol"] = "does_not_exist"
        with self.assertRaisesRegex(BindingError, "missing API declaration"):
            extract(source)


if __name__ == "__main__":
    unittest.main(verbosity=2)
