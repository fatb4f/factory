package state

import unit "github.com/fatb4f/factory/contracts:unit"

#RepositoryContextSchema: "factory.repository-context/v1"
#RepositoryScopePath: "." | unit.#RepositoryPath

#TypedMarkdownRecord: close({
	id:           #NonEmptyString
	type:         #NonEmptyString
	path:         unit.#RepositoryPath
	lineStart:    int & >=1
	lineEnd:      int & >=1
	byteStart:    int & >=0
	byteEnd:      int & >=0
	sourceDigest: #SHA256
	recordDigest: #SHA256
	payload:      string
})

#StructuralAnalyzer: "python-ast" | "jedi" | "tree-sitter"

#StructuralObservation: close({
	plane:    "structural"
	analyzer: #StructuralAnalyzer
	path:     unit.#RepositoryPath
	kind:     #NonEmptyString
	symbol?:  #NonEmptyString
	line?:    int & >=1
})

#TrackerOccurrenceMetadata: close({
	occurrence:      #NonEmptyString
	factoryIssueKey: #IssueKey
	issueNumber:     int & >=1
})

#RepositoryContextInput: close({
	repository:       #NonEmptyString
	revision:         #NonEmptyString
	scope:            #RepositoryScopePath
	compiler:         #SnapshotCompiler
	acquisition:      #AcquisitionConfiguration
	canonicalization: #CanonicalizationVersion
	analyzers:        [...#AnalyzerVersion]
})

#RepositoryContextBuild: close({
	apiVersion: #RepositoryContextSchema
	kind:       "RepositoryContextBuild"

	input:                  #RepositoryContextInput
	typedMarkdownRecords:   [...#TypedMarkdownRecord]
	structuralObservations: [...#StructuralObservation]
	trackerMetadata:        [...#TrackerOccurrenceMetadata]

	snapshot:     #SemanticContextSnapshot
	outputDigest: snapshot.identity.digest
})
