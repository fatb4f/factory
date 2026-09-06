package state

import unit "github.com/fatb4f/factory/contracts:unit"

#SemanticContextSchema: "factory.semantic-context/v1"

#ContextPlane:
	"semantic" |
	"documentary" |
	"operational" |
	"structural" |
	"evidential"

#ContextOnlyPlane:
	"documentary" |
	"operational" |
	"structural" |
	"evidential"

// Semantic meaning remains owned by the referenced authority. The repository
// path locates that authority; it does not identify subjects within it.
#SemanticAuthorityRef: close({
	id:       #NonEmptyString
	contract: unit.#RepositoryPath
})

#SemanticRef: close({
	authority: #SemanticAuthorityRef
	subject:   #NonEmptyString
	kind?:     #NonEmptyString
})

#SemanticPredicateRef: close({
	authority: #SemanticAuthorityRef
	id:        #NonEmptyString
})

#AdmittedDomainSnapshotRef: close({
	authority: #SemanticAuthorityRef
	id:        #NonEmptyString
	digest?:   #SHA256
})

#SourceKind:
	"repository" |
	"document" |
	"github-issue" |
	"run" |
	"evidence" |
	"other"

#SourceIdentity: close({
	kind: #SourceKind
	id:   #NonEmptyString
})

// payloadDigest is immutable captured-content identity. revisionHint and
// acquiredAt are provenance/version metadata unless an owning authority says
// otherwise.
#SourceOccurrence: close({
	id:            #NonEmptyString
	source:        #SourceIdentity
	locator:       #NonEmptyString
	revisionHint?: #NonEmptyString
	payloadDigest: #SHA256

	lineStart?: int & >=1
	lineEnd?:   int & >=1
	byteStart?: int & >=0
	byteEnd?:   int & >=0

	acquiredAt?: #NonEmptyString
})

#OccurrenceIdentity: close({
	id:            #NonEmptyString
	payloadDigest: #SHA256
	revisionHint?: #NonEmptyString
})

#ContextArtifactRef: close({
	id: #NonEmptyString
})

#ContextArtifact: close({
	id:         #NonEmptyString
	plane:      #ContextOnlyPlane
	role:       #NonEmptyString
	subjects:   [#SemanticRef, ...#SemanticRef]
	occurrence: #SourceOccurrence
})

#ContextNodeRef:
	close({
		kind:     "semantic"
		semantic: #SemanticRef
	}) |
	close({
		kind:     "artifact"
		artifact: #ContextArtifactRef
	})

#RelationBasis: close({
	occurrences: [#NonEmptyString, ...#NonEmptyString]
	note?:       #NonEmptyString
})

// A semantic relation cannot be established from endpoints alone. It must name
// an authority-owned predicate and the admitted domain snapshot that established
// the relation.
#SemanticRelation: close({
	plane:     "semantic"
	authority: #SemanticAuthorityRef
	predicate: #SemanticPredicateRef
	snapshot:  #AdmittedDomainSnapshotRef
	source:    #SemanticRef
	target:    #SemanticRef
	basis:     #RelationBasis
})

#DocumentaryRelation: close({
	plane:    "documentary"
	relation: #NonEmptyString
	source:   #ContextNodeRef
	target:   #ContextNodeRef
	basis:    #RelationBasis
})

#OperationalRelation: close({
	plane:    "operational"
	relation: #NonEmptyString
	source:   #ContextNodeRef
	target:   #ContextNodeRef
	basis:    #RelationBasis
})

#StructuralRelation: close({
	plane:    "structural"
	relation: #NonEmptyString
	source:   #ContextNodeRef
	target:   #ContextNodeRef
	basis:    #RelationBasis
})

#EvidentialRelation: close({
	plane:    "evidential"
	relation: #NonEmptyString
	source:   #ContextNodeRef
	target:   #ContextNodeRef
	basis:    #RelationBasis
})

#ContextRelation:
	#DocumentaryRelation |
	#OperationalRelation |
	#StructuralRelation |
	#EvidentialRelation

#AnalyzerVersion: close({
	name:             #NonEmptyString
	version:          #NonEmptyString
	configDigest?:    #SHA256
	grammarRevision?: #NonEmptyString
})

#CanonicalizationVersion: close({
	algorithm: #NonEmptyString
	version:   #NonEmptyString
})

#SnapshotCompiler: close({
	name:         #NonEmptyString
	version:      #NonEmptyString
	configDigest: #SHA256
})

#AcquisitionConfiguration: close({
	configDigest: #SHA256
})

#RootRepositoryRevision: close({
	repository: #NonEmptyString
	revision:   #NonEmptyString
})

// This manifest is the complete deterministic identity input. Any analyzer,
// grammar, compiler, acquisition, or canonicalization change capable of
// changing output must alter the manifest and therefore the snapshot digest.
#SnapshotInputManifest: close({
	rootRepository: #RootRepositoryRevision
	occurrences:    [#OccurrenceIdentity, ...#OccurrenceIdentity]
	compiler:       #SnapshotCompiler
	acquisition:    #AcquisitionConfiguration
	canonicalization: #CanonicalizationVersion
	analyzers:        [...#AnalyzerVersion]

	admittedContentDigest: #SHA256
	coverageDigest:        #SHA256
	manifestDigest:        #SHA256
})

#CoverageGap: close({
	id:          #NonEmptyString
	plane:       #ContextPlane
	description: #NonEmptyString
	subject?:    #SemanticRef
	source?:     #SourceIdentity
})

#SemanticContextSnapshot: close({
	apiVersion: #SemanticContextSchema
	kind:       "SemanticContextSnapshot"

	identity: close({
		algorithm: "sha256"
		digest:    #SHA256
	})

	manifest: #SnapshotInputManifest

	subjects:          [#SemanticRef, ...#SemanticRef]
	occurrences:       [#SourceOccurrence, ...#SourceOccurrence]
	artifacts:         [...#ContextArtifact]
	semanticRelations: [...#SemanticRelation]
	contextRelations:  [...#ContextRelation]
	coverageGaps:      [...#CoverageGap]
})
