package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

workbookDirectory: state.#DirectoryOccurrence & {
	repository: "github.com/fatb4f/factory"
	revision:   "ed7108d1907695a967d979a35eeffdcd28002c2e"
	path:       "world/industrial-signals"
}

workbookBinding: state.#DirectoryBinding & {
	id:        "binding:world.industrial-signals"
	directory: workbookDirectory
	subjects:  [semanticSubject]
}

ambiguousWorkbookBinding: state.#DirectoryBinding & {
	id:        "binding:ambiguous-fixture"
	directory: {repository: "github.com/fatb4f/factory", revision: workbookDirectory.revision, path: "state/fixtures"}
	subjects:  [semanticSubject, secondarySubject]
}

workbookScope: state.#WorkbookScope & {
	binding:  workbookBinding
	primary:  semanticSubject
	includes: [secondarySubject]
	snapshot: semanticContextSnapshot.identity.digest
}

navigationView: state.#ViewSpec & {
	id:           "industrial-evidence-topology"
	presentation: "topology"
	source: {
		kind:     "bounded-navigation"
		root:     semanticSubject
		plane:    "evidential"
		maxDepth: 2
	}
}

analyticalView: state.#ViewSpec & {
	id:           "industrial-funding-chart"
	presentation: "chart"
	source: {
		kind:    "analytical"
		request: analyticsRequest
	}
}

workbookProjectionFixture: state.#ProjectionResult & {
	apiVersion:   "factory.workbook/v1"
	kind:         "ProjectionResult"
	viewID:       navigationView.id
	presentation: navigationView.presentation
	snapshot:     semanticContextSnapshot.identity.digest
	subject:      semanticSubject
	nodes: [{
		space:      "semantic"
		id:         "semantic:industrial-signals"
		semantic:   semanticSubject
		provenance: [semanticContextSnapshot.identity.digest]
	}, {
		space:      "context"
		id:         "artifact-industrial-evidence"
		artifact:   {id: "artifact-industrial-evidence"}
		plane:      "evidential"
		provenance: ["occ-industrial-evidence"]
	}]
	edges: [{
		id:         "edge:industrial-evidence"
		plane:      "evidential"
		relation:   "has-evidence-context"
		source:     "semantic:industrial-signals"
		target:     "artifact-industrial-evidence"
		basis:      ["occ-industrial-evidence"]
		provenance: ["occ-industrial-evidence"]
	}]
	rows: []
	points: []
	provenance: [semanticContextSnapshot.identity.digest]
}
