# Generated from Factory CUE projection. Do not edit by hand.
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping

@dataclass(frozen=True, slots=True)
class SemanticAuthorityRef:
    id: str
    contract: str

@dataclass(frozen=True, slots=True)
class SemanticRef:
    authority: Mapping[str, Any]
    subject: str
    kind: str | None = None

@dataclass(frozen=True, slots=True)
class SourceOccurrence:
    id: str
    source: Mapping[str, Any]
    locator: str
    payloadDigest: str
    revisionHint: str | None = None
    acquiredAt: str | None = None

@dataclass(frozen=True, slots=True)
class ContextArtifactRef:
    id: str

@dataclass(frozen=True, slots=True)
class ContextArtifact:
    id: str
    plane: str
    role: str
    subjects: tuple[Mapping[str, Any], ...]
    occurrence: Mapping[str, Any]

