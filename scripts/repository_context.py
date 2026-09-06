#!/usr/bin/env python3
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

ISSUE_KEY_RE = re.compile(r"^factory-issue-key:\s*(\S+)\s*$", re.MULTILINE)
CUE_FENCE_RE = re.compile(r"^```cue(?:\s+([A-Za-z0-9._/-]+))?\s*$")


class RepositoryContextError(RuntimeError):
    pass


class UnsupportedNormativeFence(RepositoryContextError):
    pass


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def sha256_uri(data: bytes) -> str:
    return "sha256:" + hashlib.sha256(data).hexdigest()


def stable_record_id(path: str, fence_type: str, line_start: int, record_digest: str) -> str:
    seed = f"{path}\0{fence_type}\0{line_start}\0{record_digest}".encode()
    return "record:" + hashlib.sha256(seed).hexdigest()


@dataclass(frozen=True)
class TypedMarkdownRecord:
    id: str
    type: str
    path: str
    lineStart: int
    lineEnd: int
    byteStart: int
    byteEnd: int
    sourceDigest: str
    recordDigest: str
    payload: str

    def as_dict(self) -> dict[str, Any]:
        return self.__dict__.copy()


def parse_typed_markdown(path: str, data: bytes, supported_types: set[str]) -> list[TypedMarkdownRecord]:
    text = data.decode("utf-8")
    lines = text.splitlines(keepends=True)
    offsets: list[int] = []
    cursor = 0
    for line in lines:
        offsets.append(cursor)
        cursor += len(line.encode("utf-8"))

    source_digest = sha256_uri(data)
    records: list[TypedMarkdownRecord] = []
    index = 0
    while index < len(lines):
        stripped = lines[index].rstrip("\r\n")
        match = CUE_FENCE_RE.match(stripped)
        if not match:
            index += 1
            continue

        fence_type = match.group(1)
        if fence_type is None or fence_type not in supported_types:
            raise UnsupportedNormativeFence(f"{path}:{index + 1}: unsupported normative CUE fence {stripped!r}")

        start_index = index
        index += 1
        payload_lines: list[str] = []
        while index < len(lines) and lines[index].rstrip("\r\n") != "```":
            payload_lines.append(lines[index])
            index += 1
        if index >= len(lines):
            raise RepositoryContextError(f"{path}:{start_index + 1}: unterminated normative CUE fence")

        end_index = index
        payload = "".join(payload_lines)
        record_digest = sha256_uri(payload.encode("utf-8"))
        byte_start = offsets[start_index]
        byte_end = offsets[end_index] + len(lines[end_index].encode("utf-8"))
        line_start = start_index + 1
        line_end = end_index + 1
        records.append(TypedMarkdownRecord(
            id=stable_record_id(path, fence_type, line_start, record_digest),
            type=fence_type,
            path=path,
            lineStart=line_start,
            lineEnd=line_end,
            byteStart=byte_start,
            byteEnd=byte_end,
            sourceDigest=source_digest,
            recordDigest=record_digest,
            payload=payload,
        ))
        index += 1
    return records


def python_ast_observations(path: str, data: bytes) -> list[dict[str, Any]]:
    tree = ast.parse(data.decode("utf-8"), filename=path)
    observations: list[dict[str, Any]] = []
    for node in ast.walk(tree):
        kind: str | None = None
        name: str | None = None
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            kind, name = "function-definition", node.name
        elif isinstance(node, ast.ClassDef):
            kind, name = "class-definition", node.name
        elif isinstance(node, ast.Import):
            kind, name = "import", ",".join(alias.name for alias in node.names)
        elif isinstance(node, ast.ImportFrom):
            kind = "import-from"
            name = (node.module or "") + ":" + ",".join(alias.name for alias in node.names)
        if kind:
            observations.append({
                "plane": "structural",
                "analyzer": "python-ast",
                "path": path,
                "kind": kind,
                "symbol": name,
                "line": getattr(node, "lineno", None),
            })
    return sorted(observations, key=lambda item: (item["path"], item["line"] or 0, item["kind"], item["symbol"] or ""))


def normalized_external_observations(observations: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    normalized: list[dict[str, Any]] = []
    for item in observations:
        analyzer = item.get("analyzer")
        if analyzer not in {"jedi", "tree-sitter"}:
            raise RepositoryContextError(f"unsupported structural analyzer: {analyzer!r}")
        normalized.append({
            "plane": "structural",
            "analyzer": analyzer,
            "path": str(item["path"]),
            "kind": str(item["kind"]),
            "symbol": item.get("symbol"),
            "line": item.get("line"),
        })
    return sorted(normalized, key=lambda item: (item["analyzer"], item["path"], item["line"] or 0, item["kind"], item["symbol"] or ""))


def issue_key_from_payload(payload: dict[str, Any]) -> str:
    body = str(payload.get("body") or "")
    match = ISSUE_KEY_RE.search(body)
    if not match:
        raise RepositoryContextError("captured GitHub issue lacks factory-issue-key marker")
    return match.group(1)


def source_occurrence(*, occurrence_id: str, kind: str, source_id: str, locator: str, payload: bytes, acquired_at: str, revision_hint: str | None = None) -> dict[str, Any]:
    result: dict[str, Any] = {
        "id": occurrence_id,
        "source": {"kind": kind, "id": source_id},
        "locator": locator,
        "payloadDigest": sha256_uri(payload),
        "acquiredAt": acquired_at,
    }
    if revision_hint:
        result["revisionHint"] = revision_hint
    return result


def artifact_for(subject: dict[str, Any], occurrence: dict[str, Any], plane: str, role: str) -> dict[str, Any]:
    return {"id": "artifact:" + occurrence["id"], "plane": plane, "role": role, "subjects": [subject], "occurrence": occurrence}


def context_relation_for(subject: dict[str, Any], artifact: dict[str, Any]) -> dict[str, Any]:
    relation_by_plane = {"documentary": "documented-by", "operational": "tracked-by", "structural": "structured-by", "evidential": "evidenced-by"}
    occurrence_id = artifact["occurrence"]["id"]
    return {
        "plane": artifact["plane"],
        "relation": relation_by_plane[artifact["plane"]],
        "source": {"kind": "semantic", "semantic": subject},
        "target": {"kind": "artifact", "artifact": {"id": artifact["id"]}},
        "basis": {"occurrences": [occurrence_id]},
    }


def digest_config(value: Any) -> str:
    return sha256_uri(canonical_json_bytes(value))


def compile_repository_context(config: dict[str, Any], root: Path) -> dict[str, Any]:
    repository = str(config["repository"])
    revision = str(config["revision"])
    acquired_at = str(config["acquiredAt"])
    subject = config["subject"]
    supported_fence_types = set(config.get("supportedCueFenceTypes", []))

    occurrences: list[dict[str, Any]] = []
    artifacts: list[dict[str, Any]] = []
    context_relations: list[dict[str, Any]] = []
    coverage_gaps: list[dict[str, Any]] = []
    typed_records: list[dict[str, Any]] = []
    structural_observations: list[dict[str, Any]] = []
    tracker_metadata_items: list[dict[str, Any]] = []

    for item in sorted(config.get("files", []), key=lambda entry: entry["path"]):
        relpath = str(item["path"])
        data = (root / relpath).read_bytes()
        category = str(item["category"])
        occurrence_id = "occ:" + hashlib.sha256(f"{category}\0{relpath}\0{sha256_uri(data)}".encode()).hexdigest()

        if category == "markdown":
            typed_records.extend(record.as_dict() for record in parse_typed_markdown(relpath, data, supported_fence_types))
            plane, role, source_kind = "documentary", "typed-document", "document"
        elif category == "python":
            structural_observations.extend(python_ast_observations(relpath, data))
            plane, role, source_kind = "structural", "python-source", "repository"
        elif category == "cue":
            plane, role, source_kind = "structural", "cue-source", "repository"
        elif category == "run":
            plane, role, source_kind = "evidential", "run-manifest", "run"
        elif category == "evidence":
            plane, role, source_kind = "evidential", "evidence-artifact", "evidence"
        elif category == "github-issue":
            payload_obj = json.loads(data.decode("utf-8"))
            issue_key = issue_key_from_payload(payload_obj)
            occurrence = source_occurrence(
                occurrence_id=occurrence_id,
                kind="github-issue",
                source_id=repository,
                locator=f"issues/{payload_obj['number']}",
                payload=canonical_json_bytes(payload_obj),
                acquired_at=acquired_at,
                revision_hint=f"updatedAt={payload_obj['updated_at']}" if payload_obj.get("updated_at") else None,
            )
            occurrences.append(occurrence)
            artifact = artifact_for(subject, occurrence, "operational", "tracker-projection")
            artifacts.append(artifact)
            context_relations.append(context_relation_for(subject, artifact))
            tracker_metadata_items.append({"occurrence": occurrence_id, "factoryIssueKey": issue_key, "issueNumber": int(payload_obj["number"])})
            continue
        else:
            raise RepositoryContextError(f"unsupported fixture category: {category!r}")

        occurrence = source_occurrence(
            occurrence_id=occurrence_id,
            kind=source_kind,
            source_id=repository,
            locator=relpath,
            payload=data,
            acquired_at=acquired_at,
            revision_hint=revision,
        )
        occurrences.append(occurrence)
        artifact = artifact_for(subject, occurrence, plane, role)
        artifacts.append(artifact)
        context_relations.append(context_relation_for(subject, artifact))

    structural_observations.extend(normalized_external_observations(config.get("externalStructuralObservations", [])))
    configured_analyzers = {item["name"] for item in config.get("analyzers", [])}
    observed_analyzers = {item["analyzer"] for item in structural_observations}
    for missing in sorted(configured_analyzers - observed_analyzers):
        coverage_gaps.append({
            "id": f"gap:analyzer:{missing}",
            "plane": "structural",
            "description": f"Configured analyzer {missing} produced no structural observations.",
            "subject": subject,
            "source": {"kind": "repository", "id": repository},
        })

    occurrences.sort(key=lambda item: item["id"])
    artifacts.sort(key=lambda item: item["id"])
    context_relations.sort(key=lambda item: (item["plane"], item["target"]["artifact"]["id"], item["relation"]))
    coverage_gaps.sort(key=lambda item: item["id"])
    typed_records.sort(key=lambda item: item["id"])
    structural_observations.sort(key=lambda item: (item["analyzer"], item["path"], item["line"] or 0, item["kind"], item["symbol"] or ""))
    analyzer_versions = sorted([{key: value for key, value in item.items() if key in {"name", "version", "configDigest", "grammarRevision"}} for item in config.get("analyzers", [])], key=lambda item: item["name"])

    compiler_cfg = {"supportedCueFenceTypes": sorted(supported_fence_types), "scope": config.get("scope", ".")}
    acquisition_cfg = {"files": [{"path": item["path"], "category": item["category"]} for item in sorted(config.get("files", []), key=lambda entry: entry["path"])], "acquiredAt": acquired_at}
    compiler = {"name": "factory.repository-context", "version": str(config.get("compilerVersion", "1")), "configDigest": digest_config(compiler_cfg)}
    acquisition = {"configDigest": digest_config(acquisition_cfg)}
    canonicalization = {"algorithm": "json-sort-keys-compact", "version": "stdlib-json-v1"}

    admitted_content = {
        "subjects": [subject],
        "artifacts": artifacts,
        "contextRelations": context_relations,
        "typedMarkdownRecords": typed_records,
        "structuralObservations": structural_observations,
        "trackerMetadata": sorted(tracker_metadata_items, key=lambda item: item["occurrence"]),
    }
    occurrence_identities = [{"id": item["id"], "payloadDigest": item["payloadDigest"], **({"revisionHint": item["revisionHint"]} if "revisionHint" in item else {})} for item in occurrences]
    manifest_without_digest = {
        "rootRepository": {"repository": repository, "revision": revision},
        "occurrences": occurrence_identities,
        "compiler": compiler,
        "acquisition": acquisition,
        "canonicalization": canonicalization,
        "analyzers": analyzer_versions,
        "admittedContentDigest": digest_config(admitted_content),
        "coverageDigest": digest_config(coverage_gaps),
    }
    manifest = dict(manifest_without_digest)
    manifest["manifestDigest"] = digest_config(manifest_without_digest)

    snapshot_without_identity = {
        "apiVersion": "factory.semantic-context/v1",
        "kind": "SemanticContextSnapshot",
        "manifest": manifest,
        "subjects": [subject],
        "occurrences": occurrences,
        "artifacts": artifacts,
        "semanticRelations": [],
        "contextRelations": context_relations,
        "coverageGaps": coverage_gaps,
    }
    snapshot = dict(snapshot_without_identity)
    snapshot["identity"] = {"algorithm": "sha256", "digest": digest_config(snapshot_without_identity)}

    return {
        "apiVersion": "factory.repository-context/v1",
        "kind": "RepositoryContextBuild",
        "input": {"repository": repository, "revision": revision, "scope": str(config.get("scope", ".")), "compiler": compiler, "acquisition": acquisition, "canonicalization": canonicalization, "analyzers": analyzer_versions},
        "typedMarkdownRecords": typed_records,
        "structuralObservations": structural_observations,
        "trackerMetadata": sorted(tracker_metadata_items, key=lambda item: item["occurrence"]),
        "snapshot": snapshot,
        "outputDigest": snapshot["identity"]["digest"],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("config", type=Path)
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    config = json.loads(args.config.read_text(encoding="utf-8"))
    result = compile_repository_context(config, args.root)
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
