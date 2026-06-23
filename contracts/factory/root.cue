package factory

#Decision: "blocked" | "admissible" | "promoted"

#ObservedPatch: close({
	id: string

	files: [...#ObservedFile]

	rootModel: {
		baseVocabularyDeclared:  bool
		rootPackageDiscoverable: bool
		singlePackage:           bool
	}

	paths: *{} | {[string]: #ObservedPath}

	evidence: *{
		vcs: []
	} | {
		vcs?: [...#ObservedVCSEvidence]
	}

	provenance: *{} | #ObservedProvenance

	closureClaim: {
		decision:              #Decision
		declaresPass:          bool
		declaresClosurePassed: bool
	}

	empiricalGate: {
		requiredChecksDeclared: bool
		requiredChecksPass:     bool
		negativeFixturesTyped:  bool
		refusalEvalsDeclared:   bool
		everyInvariantCovered:  bool
		closureProven:          bool
	}

	predicates?: #PatchPredicates
})

#ObservedFile: close({
	path:    string
	package: string
	role:    "root" | "branch" | "leaf" | "legacy" | "unknown"
})

#RootFile: close({
	path:    string & =~"^contracts/factory(/.*)?$"
	package: "factory"
	role:    "root" | "branch" | "leaf" | "legacy"
})

#ObservedPath: close({
	owner: close({
		path: string
	})

	pathPolicy: close({
		segments: [string]: string
	})

	kind:  string
	name:  string
	value: string
})

#DerivedPath: close({
	owner: close({
		path: "contracts/factory"
	})

	pathPolicy: close({
		segments: {
			check:      "reflection/projections/checks"
			report:     "reports"
			fixture:    "fixtures"
			projection: "reflection/projections"
			operation:  "operations"
			evidence:   "evidence"
		}
	})

	kind: "check" | "report" | "fixture" | "projection" | "operation" | "evidence"
	name: string

	value: "\(owner.path)/\(pathPolicy.segments[kind])/\(name)"
})

#ObservedProvenance: close({
	sourceDigest?:    string
	inventoryDigest?: string
	materializedAt?:  string
})

#Provenance: close({
	sourceDigest?:    string & !="sha256:0000000000000000000000000000000000000000000000000000000000000000"
	inventoryDigest?: string & !="sha256:0000000000000000000000000000000000000000000000000000000000000000"
	materializedAt?:  string & !="run:0000000000000000"
})

#VCSEvidence: close({
	before?: {
		head?:  string & !="declared-by-adapter"
		clean?: bool
	}
	after?: {
		head?:  string & !="declared-by-adapter"
		clean?: bool
	}
	result?: "observed" | "blocked" | "failed"
})

#ObservedVCSEvidence: close({
	before: {
		head:   string
		clean?: bool
	}
	after: {
		head:   string
		clean?: bool
	}
	result: string
})

#PatchPredicates: close({
	input: #ObservedPatch

	sidePackageSchemaSprawl:
		!input.rootModel.singlePackage ||
		!input.rootModel.rootPackageDiscoverable

	vocabularyWithoutGateProof:
		input.rootModel.baseVocabularyDeclared &&
		(!input.empiricalGate.requiredChecksDeclared ||
		!input.empiricalGate.negativeFixturesTyped ||
		!input.empiricalGate.refusalEvalsDeclared ||
		!input.empiricalGate.everyInvariantCovered)

	prematureClosureClaim:
		input.closureClaim.decision != "blocked" ||
		input.closureClaim.declaresPass ||
		input.closureClaim.declaresClosurePassed ||
		input.empiricalGate.closureProven

	syntheticEvidence:
		len([for e in input.evidence.vcs if (e.before.head == "declared-by-adapter" || e.after.head == "declared-by-adapter" || e.result == "applied") {e}]) > 0

	fakeProvenance:
		len([for k, v in input.provenance if ((k == "sourceDigest" &&
			v == "sha256:0000000000000000000000000000000000000000000000000000000000000000") ||
			(k == "inventoryDigest" &&
			v == "sha256:0000000000000000000000000000000000000000000000000000000000000000") ||
			(k == "materializedAt" &&
			v == "run:0000000000000000")) {v}]) > 0

	syntheticEvidenceOrProvenance:
		syntheticEvidence || fakeProvenance

	nonDerivedPath:
		len([for _, p in input.paths if (p.value != "\(p.owner.path)/\(p.pathPolicy.segments[p.kind])/\(p.name)") {p}]) > 0
})

#RootPromotionCandidate: _candidate=close(#ObservedPatch & {
	files: [...#RootFile]

	rootModel: {
		baseVocabularyDeclared:  true
		rootPackageDiscoverable: true
		singlePackage:           true
	}

	closureClaim: {
		decision:              "blocked"
		declaresPass:          false
		declaresClosurePassed: false
	}

	paths: [string]: #DerivedPath

	evidence: {
		vcs: [...#VCSEvidence]
	}

	provenance: #Provenance

	empiricalGate: {
		requiredChecksDeclared: true
		negativeFixturesTyped:  true
		refusalEvalsDeclared:   true
		everyInvariantCovered:  true
		closureProven:          false
	}

	predicates: #PatchPredicates & {
		input: {
			id:            _candidate.id
			files:         _candidate.files
			rootModel:     _candidate.rootModel
			paths:         _candidate.paths
			evidence:      _candidate.evidence
			provenance:    _candidate.provenance
			closureClaim:  _candidate.closureClaim
			empiricalGate: _candidate.empiricalGate
		}
	}

	if predicates.vocabularyWithoutGateProof {
		_vocabularyWithoutGateProof: _|_
	}

	if predicates.sidePackageSchemaSprawl {
		_sidePackageSchemaSprawl: _|_
	}

	if predicates.prematureClosureClaim {
		_prematureClosureClaim: _|_
	}

	if predicates.syntheticEvidenceOrProvenance {
		_syntheticEvidenceOrProvenance: _|_
	}

	if predicates.nonDerivedPath {
		_nonDerivedPath: _|_
	}
})

#PromotionCandidate: #RootPromotionCandidate

#NegativeFixture: close({
	id:              string
	violates:        string
	expectedRefusal: string
	input:           #ObservedPatch
})

#GateCheck: close({
	id:      string
	command: "cue vet ./contracts/factory" |
		"cue export ./contracts/factory -e factory" |
		"cue export ./contracts/factory -e issue" |
		"cue export ./contracts/factory -e promotionGate" |
		"cue export ./contracts/factory -e closureReport" |
		"cue export ./contracts/factory -e factory.negativeFixtures" |
		"cue export ./contracts/factory -e factory.paths" |
		"cue export ./contracts/factory -e factory.operations" |
			"cue export ./contracts/factory -e factory.evidence"
	mutates: false
})

#RootPromotionGate: close({
	id:        string
	candidate: #RootPromotionCandidate
	checks: [...#GateCheck]
	negativeFixtures: [...#NegativeFixture]
	decision: "blocked"
})

#ClosureReport: close({
	id:        string
	gate:      #RootPromotionGate
	authority: false
	passed:    false
	candidate: #RootPromotionCandidate
})

injectedProvenance: {
	sourceDigest:    "sha256:1111111111111111111111111111111111111111111111111111111111111111"
	inventoryDigest: "sha256:2222222222222222222222222222222222222222222222222222222222222222"
	materializedAt:  "run:1111111111111111"
}
