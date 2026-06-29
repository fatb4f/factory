#!/usr/bin/env python3
"""Idempotent plugin-bundle materializer for generation-distribution.

Public entrypoint:
    materializePluginBundle(input) -> result
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[3]

ADMITTED_BUNDLES: dict[str, dict[str, Any]] = {
    "agent-context-resolver": {
        "sourceRoot": "contracts/plugin-bundle/agent-context-resolver/src",
        "distributionRoot": ".codex/plugins/agent-context-resolver",
        "generatedRoot": "contracts/plugin-bundle/agent-context-resolver/generated",
        "runtimeFiles": [
            "manifest.json",
            "SKILL.md",
            "scripts/agent-context-resolver-hook",
            "scripts/resolve-agent-context",
        ],
        "lockEvidence": ["package.lock.json"],
        "sources": {
            "SKILL.md": "projections/codex/skills/resolve-agent-context/SKILL.md",
            "scripts/agent-context-resolver-hook": "projections/codex/skills/resolve-agent-context/scripts/agent-context-resolver-hook",
            "scripts/resolve-agent-context": "projections/codex/skills/resolve-agent-context/scripts/resolve-agent-context",
        },
    },
    "code-intel": {
        "sourceRoot": "contracts/plugin-bundle/code-intel/src",
        "distributionRoot": ".codex/plugins/code-intel",
        "generatedRoot": "contracts/plugin-bundle/code-intel/generated",
        "runtimeFiles": ["manifest.json", "SKILL.md"],
        "lockEvidence": [],
        "sources": {
            "manifest.json": "manifest.json",
            "SKILL.md": "SKILL.md",
        },
    },
}


def materializePluginBundle(input: dict[str, Any]) -> dict[str, Any]:
    """Compute or apply a deterministic plugin-bundle materialization."""

    mode = input.get("mode")
    bundle_id = input.get("bundleID")
    source_root = input.get("sourceRoot")
    distribution_root = input.get("distributionRoot")
    target_repo = input.get("targetRepo")
    overwrite_policy = input.get("overwritePolicy", "replace-generated")
    expected_inventory = input.get("expectedInventory")

    refused: list[dict[str, str]] = []
    if mode not in ("dry-run", "apply"):
        refused.append({"reason": "unsupported mode", "path": str(mode)})
    admitted = ADMITTED_BUNDLES.get(str(bundle_id))
    if admitted is None:
        refused.append({"reason": "undeclared bundle ID", "path": str(bundle_id)})
        admitted = {}
    if admitted and source_root != admitted["sourceRoot"]:
        refused.append({"reason": "undeclared source root", "path": str(source_root)})
    if admitted and distribution_root != admitted["distributionRoot"]:
        refused.append({"reason": "undeclared distribution root", "path": str(distribution_root)})
    if target_repo in ("", None):
        refused.append({"reason": "target repo is required", "path": "targetRepo"})
    if overwrite_policy != "replace-generated":
        refused.append({"reason": "unsupported overwrite policy", "path": str(overwrite_policy)})

    runtime_files = list(admitted.get("runtimeFiles", []))
    lock_files = list(admitted.get("lockEvidence", []))
    admitted_inventory = runtime_files + lock_files + ["materialization-report.json"]
    if expected_inventory is not None and list(expected_inventory) != admitted_inventory:
        refused.append({"reason": "expected inventory does not match admitted inventory", "path": "expectedInventory"})

    generated_root = admitted.get("generatedRoot", "")
    write_set: dict[str, bytes] = {}
    source_hashes: dict[str, str] = {}

    if admitted and not refused:
        for relative_path in runtime_files:
            logical_path = f"{distribution_root}/{relative_path}"
            if not _contained(logical_path, distribution_root):
                refused.append({"reason": "output path escapes bundle root", "path": logical_path})
                continue
            content = _runtime_content(bundle_id, relative_path, admitted, target_repo)
            write_set[relative_path] = content
            source_hashes[relative_path] = _sha256(content)

        lock = _lock_evidence(
            bundle_id=bundle_id,
            source_root=source_root,
            distribution_root=distribution_root,
            generated_root=generated_root,
            target_repo=target_repo,
            runtime_files=runtime_files,
            source_hashes=source_hashes,
        )
        if lock_files:
            write_set[lock_files[0]] = _canonical_json(lock)

        report = _completion_report(
            bundle_id=bundle_id,
            source_root=source_root,
            distribution_root=distribution_root,
            generated_root=generated_root,
            target_repo=target_repo,
            inventory=admitted_inventory,
            source_hashes=source_hashes,
            validation_status="pass",
        )
        write_set["materialization-report.json"] = _canonical_json(report)

        for relative_path, content in write_set.items():
            if not _contained(f"{distribution_root}/{relative_path}", distribution_root):
                refused.append({"reason": "output path escapes bundle root", "path": relative_path})
            metadata = _json_object(content)
            if metadata.get("authority") is True:
                refused.append({"reason": "generated/runtime file marked as authority", "path": relative_path})
            if metadata.get("generatedAtRuntime") is True or metadata.get("nonDeterministicInput") is True:
                refused.append({"reason": "non-deterministic runtime input", "path": relative_path})
            if metadata.get("runtimeRequiresExternalFactoryLookup") is True or metadata.get("runtimeRequiresContractCuemodLookup") is True:
                refused.append({"reason": "runtime requires external source lookup", "path": relative_path})

    changed: list[str] = []
    unchanged: list[str] = []
    if admitted and not refused:
        for relative_path, content in sorted(write_set.items()):
            out_path = REPO_ROOT / generated_root / relative_path
            current = out_path.read_bytes() if out_path.exists() else None
            if current == content:
                unchanged.append(str(Path(generated_root) / relative_path))
            else:
                changed.append(str(Path(generated_root) / relative_path))

        if mode == "apply":
            for relative_path, content in sorted(write_set.items()):
                out_path = REPO_ROOT / generated_root / relative_path
                out_path.parent.mkdir(parents=True, exist_ok=True)
                out_path.write_bytes(content)
                out_path.chmod(_runtime_mode(relative_path, admitted))

    return {
        "idempotent": len(changed) == 0,
        "changedFiles": changed,
        "unchangedFiles": unchanged,
        "refusedWrites": refused,
        "lockEvidence": _json_object(write_set.get(lock_files[0], b"{}")) if lock_files else {},
        "validationCommands": [
            "cue vet ./contracts/plugin-bundle/generation-distribution",
            "cue export ./contracts/plugin-bundle/generation-distribution -e normalizedPluginBundleGenerationDistributionManifest",
            "cue export ./contracts/plugin-bundle/generation-distribution -e pluginBundleGenerationDistributionValidationPlan",
            "cue export ./contracts/plugin-bundle/generation-distribution -e pluginBundleGenerationDistributionCompletionReportContract",
            "python3 contracts/plugin-bundle/generation-distribution/materializer.py --self-test",
        ],
        "completionReport": _json_object(write_set.get("materialization-report.json", b"{}")),
    }


def _runtime_content(bundle_id: str, relative_path: str, admitted: dict[str, Any], target_repo: str) -> bytes:
    if relative_path in admitted["sources"]:
        return (REPO_ROOT / admitted["sourceRoot"] / admitted["sources"][relative_path]).read_bytes()
    if bundle_id == "agent-context-resolver" and relative_path == "manifest.json":
        return _canonical_json(
            {
                "schema": "factory.plugin-bundle.runtime-manifest.v1",
                "bundleID": bundle_id,
                "generated": True,
                "authority": False,
                "targetRepo": target_repo,
                "sourceRoot": admitted["sourceRoot"],
                "distributionRoot": admitted["distributionRoot"],
                "generatedRoot": admitted["generatedRoot"],
                "runtimeRequiresExternalFactoryLookup": False,
                "runtimeRequiresContractCuemodLookup": False,
            }
        )
    raise ValueError(f"no admitted source for {bundle_id}:{relative_path}")


def _runtime_mode(relative_path: str, admitted: dict[str, Any]) -> int:
    source = admitted["sources"].get(relative_path)
    if source is None:
        return 0o644
    source_path = REPO_ROOT / admitted["sourceRoot"] / source
    return 0o755 if os.access(source_path, os.X_OK) else 0o644


def _lock_evidence(**data: Any) -> dict[str, Any]:
    files = [
        {
            "path": f"{data['distribution_root']}/{path}",
            "generatedPath": str(Path(data["generated_root"]) / path),
            "sha256": data["source_hashes"][path],
            "generated": True,
            "authority": False,
        }
        for path in data["runtime_files"]
    ]
    inventory_digest = _sha256(_canonical_json(files))
    return {
        "schema": "factory.plugin-bundle.materialization-lock.v1",
        "bundleID": data["bundle_id"],
        "sourceRoot": data["source_root"],
        "distributionRoot": data["distribution_root"],
        "generatedRoot": data["generated_root"],
        "targetRepo": data["target_repo"],
        "generatedInventory": files,
        "inventoryDigest": inventory_digest,
        "validationStatus": "pass",
        "generated": True,
        "authority": False,
    }


def _completion_report(**data: Any) -> dict[str, Any]:
    return {
        "schema": "factory.plugin-bundle.materialization-report.v1",
        "function": "materializePluginBundle",
        "bundleID": data["bundle_id"],
        "sourceRoot": data["source_root"],
        "distributionRoot": data["distribution_root"],
        "generatedRoot": data["generated_root"],
        "targetRepo": data["target_repo"],
        "inventory": data["inventory"],
        "contentIdentity": data["source_hashes"],
        "validationStatus": data["validation_status"],
        "idempotenceProof": "same input inventory and content hashes reproduce the same write set",
        "generatedOutputsAreAuthority": False,
        "runtimeExternalSourceLookupRequired": False,
        "generated": True,
        "authority": False,
    }


def _contained(path: str, root: str) -> bool:
    pure = Path(path)
    if pure.is_absolute() or ".." in pure.parts:
        return False
    return path == root or path.startswith(f"{root}/")


def _canonical_json(value: Any) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode("utf-8")


def _json_object(content: bytes) -> dict[str, Any]:
    try:
        value = json.loads(content.decode("utf-8"))
    except Exception:
        return {}
    return value if isinstance(value, dict) else {}


def _sha256(content: bytes) -> str:
    return "sha256:" + hashlib.sha256(content).hexdigest()


def _run_self_test() -> None:
    fixtures = [
        {
            "bundleID": "agent-context-resolver",
            "sourceRoot": "contracts/plugin-bundle/agent-context-resolver/src",
            "distributionRoot": ".codex/plugins/agent-context-resolver",
            "targetRepo": "fatb4f/factory",
            "mode": "dry-run",
            "overwritePolicy": "replace-generated",
            "expectedInventory": [
                "manifest.json",
                "SKILL.md",
                "scripts/agent-context-resolver-hook",
                "scripts/resolve-agent-context",
                "package.lock.json",
                "materialization-report.json",
            ],
        },
        {
            "bundleID": "code-intel",
            "sourceRoot": "contracts/plugin-bundle/code-intel/src",
            "distributionRoot": ".codex/plugins/code-intel",
            "targetRepo": "fatb4f/factory",
            "mode": "dry-run",
            "overwritePolicy": "replace-generated",
            "expectedInventory": ["manifest.json", "SKILL.md", "materialization-report.json"],
        },
    ]
    for fixture in fixtures:
        first = materializePluginBundle(fixture)
        second = materializePluginBundle(copy.deepcopy(fixture))
        assert first["refusedWrites"] == [], first
        assert second == first

    bad_cases = [
        {**fixtures[0], "bundleID": "unknown"},
        {**fixtures[0], "sourceRoot": "contracts/plugin-bundle/template"},
        {**fixtures[0], "distributionRoot": ".codex/../escape"},
    ]
    for bad in bad_cases:
        assert materializePluginBundle(bad)["refusedWrites"], bad

    original_code_intel = copy.deepcopy(ADMITTED_BUNDLES["code-intel"])
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        (tmp_path / "SKILL.md").write_text("test skill\n", encoding="utf-8")
        negative_metadata = [
            {"authority": True},
            {"generatedAtRuntime": True, "nonDeterministicInput": True},
            {"runtimeRequiresExternalFactoryLookup": True},
            {"runtimeRequiresContractCuemodLookup": True},
        ]
        for metadata in negative_metadata:
            (tmp_path / "manifest.json").write_text(json.dumps(metadata), encoding="utf-8")
            ADMITTED_BUNDLES["code-intel"] = {
                **original_code_intel,
                "sourceRoot": str(tmp_path),
            }
            negative_input = {
                **fixtures[1],
                "sourceRoot": str(tmp_path),
            }
            assert materializePluginBundle(negative_input)["refusedWrites"], metadata
    ADMITTED_BUNDLES["code-intel"] = original_code_intel

    with tempfile.TemporaryDirectory() as tmp:
        generated_root = REPO_ROOT / ADMITTED_BUNDLES["code-intel"]["generatedRoot"]
        backup = Path(tmp) / "generated"
        if generated_root.exists():
            shutil.copytree(generated_root, backup)
            shutil.rmtree(generated_root)
        try:
            apply_input = {**fixtures[1], "mode": "apply"}
            first_apply = materializePluginBundle(apply_input)
            second_apply = materializePluginBundle(apply_input)
            assert first_apply["refusedWrites"] == [], first_apply
            assert second_apply["changedFiles"] == [], second_apply
            assert second_apply["unchangedFiles"], second_apply
        finally:
            if generated_root.exists():
                shutil.rmtree(generated_root)
            if backup.exists():
                shutil.copytree(backup, generated_root)


def _main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="JSON input file for materializePluginBundle")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        _run_self_test()
        return 0
    if not args.input:
        parser.error("--input is required unless --self-test is used")
    with open(args.input, "r", encoding="utf-8") as handle:
        result = materializePluginBundle(json.load(handle))
    json.dump(result, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
