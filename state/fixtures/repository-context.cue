package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

repositoryContextBuildFixture: state.#RepositoryContextBuild & {
	apiVersion: "factory.repository-context/v1"
	kind:       "RepositoryContextBuild"
	input: {
		repository: "github.com/fatb4f/factory"
		revision:   "5fda25a964eb8c55081e3f5cbf4d5ec27f7f5997"
		scope:      "state/fixtures/repository-context"
		compiler: {
			name:         "factory.repository-context"
			version:      "1"
			configDigest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		}
		acquisition: {configDigest: "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}
		canonicalization: {
			algorithm: "json-sort-keys-compact"
			version:   "stdlib-json-v1"
		}
		analyzers: [{name: "python-ast", version: "stdlib-3.13+"}, {name: "jedi", version: "fixture-contract-v1"}, {name: "tree-sitter", version: "fixture-contract-v1", grammarRevision: "python-fixture-v1"}]
	}
	typedMarkdownRecords: [{
		id:           "record:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		type:         "semantic-ref"
		path:         "state/fixtures/repository-context/context.md"
		lineStart:    3
		lineEnd:      11
		byteStart:    30
		byteEnd:      200
		sourceDigest: "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
		recordDigest: "sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
		payload:      "subject: \"factory.repository-context\""
	}]
	structuralObservations: [{plane: "structural", analyzer: "python-ast", path: "state/fixtures/repository-context/sample.py", kind: "class-definition", symbol: "FixtureCompiler", line: 3}, {plane: "structural", analyzer: "jedi", path: "state/fixtures/repository-context/sample.py", kind: "definition-reference", symbol: "compile_fixture", line: 6}, {plane: "structural", analyzer: "tree-sitter", path: "state/fixtures/repository-context/sample.py", kind: "function-definition", symbol: "compile_fixture", line: 6}]
	trackerMetadata: [{
		occurrence:      "occ:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		factoryIssueKey: "engineering:substrate:factory.repository-context:integration:typed-acquisition"
		issueNumber:     145
	}]
	snapshot: semanticContextSnapshot
}
