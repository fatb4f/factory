# Generated from CUE native bindings and pinned typeshed evidence. Do not edit.
from __future__ import annotations

import builtins
import dataclasses
import typing

from runtime.native_binding import UNSET, UnsetType
from runtime.semantic_metadata import semantic_type

PROJECTION_PLAN = {'id': 'semantic-context-native-v1',
 'apiSource': {'repository': 'https://github.com/python/typeshed',
               'revision': 'e75a39fec6f375f5002d54c5607b44bedc025a4b',
               'targetPython': {'major': 3, 'minor': 12},
               'files': {'builtins': {'path': 'state/python-api/typeshed/stdlib/builtins.pyi',
                                      'digest': 'sha256:115e4ecfbbc94d11e8d602ed26efc4cb1994add4994277a2cb9634340e477703'},
                         'dataclasses': {'path': 'state/python-api/typeshed/stdlib/dataclasses.pyi',
                                         'digest': 'sha256:7bf3761f6af1321bff9de1b5522d9d0071a45db197d0531d6f2a6c28685205c7'},
                         'typing': {'path': 'state/python-api/typeshed/stdlib/typing.pyi',
                                    'digest': 'sha256:edb6fcd5ba33fe423235a86f5f21a05188996fa7fbc867699622de4c8502691e'}},
               'license': {'path': 'state/python-api/typeshed/LICENSE',
                           'digest': 'sha256:295f8538c94ae5c3043301cf7cff1c852dab6a786a8ddee471e061b40d5ecabe'},
               'requests': {'dataclass': {'module': 'dataclasses', 'symbol': 'dataclass'},
                            'str': {'module': 'builtins', 'symbol': 'str'},
                            'int': {'module': 'builtins', 'symbol': 'int'},
                            'tuple': {'module': 'builtins', 'symbol': 'tuple'},
                            'literal': {'module': 'typing', 'symbol': 'Literal'}}},
 'apiVersion': 'factory.native-python-projection/v1',
 'cuePackage': 'state',
 'source': 'contracts/state/semantic-context.cue',
 'sourceDigest': 'sha256:6326c3e37ad1fe8ea70511d2ea5c2e8eb2cb8f5546740cb36b3324324006ac28',
 'decorator': {'api': 'dataclass', 'keywords': {'frozen': True, 'slots': True, 'kw_only': True}},
 'tupleAPI': 'tuple',
 'literalAPI': 'literal',
 'optionalRepresentation': 'unset-sentinel',
 'constraintPolicy': 'all-values-revalidate-in-cue',
 'admission': 'not-determined',
 'types': [{'name': 'SemanticAuthorityRef',
            'cueType': '#SemanticAuthorityRef',
            'space': 'semantic',
            'fields': [{'name': 'id',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'contract',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False}],
            'cueRequired': ['nonempty identity', 'repository path constraints']},
           {'name': 'SemanticRef',
            'cueType': '#SemanticRef',
            'space': 'semantic',
            'fields': [{'name': 'authority',
                        'annotation': {'kind': 'local', 'name': 'SemanticAuthorityRef'},
                        'optional': False},
                       {'name': 'subject',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'kind',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': True}],
            'cueRequired': ['nonempty subject and optional kind',
                            'authority qualification remains external']},
           {'name': 'SourceIdentity',
            'cueType': '#SourceIdentity',
            'space': 'provenance',
            'fields': [{'name': 'kind',
                        'annotation': {'kind': 'literal',
                                       'values': ['repository',
                                                  'document',
                                                  'github-issue',
                                                  'run',
                                                  'evidence',
                                                  'other']},
                        'optional': False},
                       {'name': 'id',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False}],
            'cueRequired': ['source-kind enum and nonempty identity']},
           {'name': 'SourceOccurrence',
            'cueType': '#SourceOccurrence',
            'space': 'provenance',
            'fields': [{'name': 'id',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'source',
                        'annotation': {'kind': 'local', 'name': 'SourceIdentity'},
                        'optional': False},
                       {'name': 'locator',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'payloadDigest',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'revisionHint',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': True},
                       {'name': 'acquiredAt',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': True},
                       {'name': 'lineStart',
                        'annotation': {'kind': 'api', 'api': 'int'},
                        'optional': True},
                       {'name': 'lineEnd',
                        'annotation': {'kind': 'api', 'api': 'int'},
                        'optional': True},
                       {'name': 'byteStart',
                        'annotation': {'kind': 'api', 'api': 'int'},
                        'optional': True},
                       {'name': 'byteEnd',
                        'annotation': {'kind': 'api', 'api': 'int'},
                        'optional': True}],
            'cueRequired': ['SHA-256 pattern',
                            'nonempty identity and locator',
                            'line minima 1 and byte minima 0']},
           {'name': 'ContextArtifactRef',
            'cueType': '#ContextArtifactRef',
            'space': 'context',
            'fields': [{'name': 'id',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False}],
            'cueRequired': ['nonempty identity']},
           {'name': 'ContextArtifact',
            'cueType': '#ContextArtifact',
            'space': 'context',
            'fields': [{'name': 'id',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'plane',
                        'annotation': {'kind': 'literal',
                                       'values': ['documentary',
                                                  'operational',
                                                  'structural',
                                                  'evidential']},
                        'optional': False},
                       {'name': 'role',
                        'annotation': {'kind': 'api', 'api': 'str'},
                        'optional': False},
                       {'name': 'subjects',
                        'annotation': {'kind': 'tuple',
                                       'item': {'kind': 'local', 'name': 'SemanticRef'}},
                        'optional': False},
                       {'name': 'occurrence',
                        'annotation': {'kind': 'local', 'name': 'SourceOccurrence'},
                        'optional': False}],
            'cueRequired': ['nonempty subjects',
                            'nonempty identity and role',
                            'context-only plane; no semantic admission']}]}
PLAN_DIGEST = 'sha256:042ce0d74d011a5a0862e7ce4eca4fec358650925016bda24e1e1e63a7605d12'
API_FACTS_DIGEST = 'sha256:e61600867baa2eec841787848a63c491f367caf5f61b792e2a03661ef8b91996'

@semantic_type(cue_package='state', cue_type='#SemanticAuthorityRef', space='semantic', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class SemanticAuthorityRef:
    id: builtins.str
    contract: builtins.str

@semantic_type(cue_package='state', cue_type='#SemanticRef', space='semantic', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class SemanticRef:
    authority: SemanticAuthorityRef
    subject: builtins.str
    kind: builtins.str | UnsetType = UNSET

@semantic_type(cue_package='state', cue_type='#SourceIdentity', space='provenance', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class SourceIdentity:
    kind: typing.Literal['repository', 'document', 'github-issue', 'run', 'evidence', 'other']
    id: builtins.str

@semantic_type(cue_package='state', cue_type='#SourceOccurrence', space='provenance', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class SourceOccurrence:
    id: builtins.str
    source: SourceIdentity
    locator: builtins.str
    payloadDigest: builtins.str
    revisionHint: builtins.str | UnsetType = UNSET
    acquiredAt: builtins.str | UnsetType = UNSET
    lineStart: builtins.int | UnsetType = UNSET
    lineEnd: builtins.int | UnsetType = UNSET
    byteStart: builtins.int | UnsetType = UNSET
    byteEnd: builtins.int | UnsetType = UNSET

@semantic_type(cue_package='state', cue_type='#ContextArtifactRef', space='context', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class ContextArtifactRef:
    id: builtins.str

@semantic_type(cue_package='state', cue_type='#ContextArtifact', space='context', source='contracts/state/semantic-context.cue')
@dataclasses.dataclass(frozen=True, kw_only=True, slots=True)
class ContextArtifact:
    id: builtins.str
    plane: typing.Literal['documentary', 'operational', 'structural', 'evidential']
    role: builtins.str
    subjects: builtins.tuple[SemanticRef, ...]
    occurrence: SourceOccurrence
