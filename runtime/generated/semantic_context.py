# Generated from Factory CUE projection. Do not edit by hand.
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping

from runtime.semantic_metadata import semantic_relation, semantic_type

@semantic_type(cue_package='state', cue_type='#SemanticAuthorityRef', space='semantic', source='contracts/state/semantic-context.cue')
@dataclass(frozen=True, slots=True)
class SemanticAuthorityRef:
    id: str
    contract: str

@semantic_type(cue_package='state', cue_type='#SemanticRef', space='semantic', source='contracts/state/semantic-context.cue')
@semantic_relation(name='authority', target_cue_type='#SemanticAuthorityRef', via_field='authority', cardinality='one')
@dataclass(frozen=True, slots=True)
class SemanticRef:
    authority: Mapping[str, Any]
    subject: str
    kind: str | None = None

@semantic_type(cue_package='state', cue_type='#SourceOccurrence', space='provenance', source='contracts/state/semantic-context.cue')
@dataclass(frozen=True, slots=True)
class SourceOccurrence:
    id: str
    source: Mapping[str, Any]
    locator: str
    payloadDigest: str
    revisionHint: str | None = None
    acquiredAt: str | None = None

@semantic_type(cue_package='state', cue_type='#ContextArtifactRef', space='context', source='contracts/state/semantic-context.cue')
@dataclass(frozen=True, slots=True)
class ContextArtifactRef:
    id: str

@semantic_type(cue_package='state', cue_type='#ContextArtifact', space='context', source='contracts/state/semantic-context.cue')
@semantic_relation(name='occurrence', target_cue_type='#SourceOccurrence', via_field='occurrence', cardinality='one')
@semantic_relation(name='subjects', target_cue_type='#SemanticRef', via_field='subjects', cardinality='many')
@dataclass(frozen=True, slots=True)
class ContextArtifact:
    id: str
    plane: str
    role: str
    subjects: tuple[Mapping[str, Any], ...]
    occurrence: Mapping[str, Any]

