package s00

import "list"

matrix: #MatrixSnapshot & {
	id:         "fatb4f/factory#107"
	marker:     "cue-lattice-conformance-requirements-matrix:v1"
	revision:   "v1"
	updatedAt:  "2026-07-13T15:05:57Z"
	bodySHA256: "6a32affbfd803849abdf2d79c16d5150cda38708257b84dfdae3ae374d69b61c"
}

source: #SourceIdentity & {
	repository:   "https://github.com/fatb4f/lattice"
	revision:     "4148dc1a2d1adfa0782e93e89ea402ce41c56d35"
	retrieval:    "git-blob-at-commit"
	movingTarget: false
}

let sourceIdentity = source

patternInventory: #PatternInventory & {
	id:     "lattice-pattern-inventory-v1"
	source: sourceIdentity
	patterns: close({
		attributes: {id: "attributes", path: "patterns/attributes.cue", blob: "274a95c29c03a74f6c6d6e3de6c2d4ee02026a3d", contentSHA256: "28a96a79bbe1a5383001e538ce0e56d22f345bc5929da35ffbadef9278b233b2", classification: "application-pattern", status: "provisional"}
		bounds: {id: "bounds", path: "patterns/bounds.cue", blob: "8c7604d7bbaff1fed2c5a2766dc4adc35ce3ee59", contentSHA256: "1adf46115a863f03abc7876fba1d6acab137e7915b3965a7527618561c138202", classification: "lattice-primitive", status: "provisional"}
		closedness: {id: "closedness", path: "patterns/closedness.cue", blob: "00253047555118893daa5de1ef1f25b134fe3c8a", contentSHA256: "7eebfa2e9aea9380eab719da79e7243d7b3561e586f366b4bd93e0e8b291fcc8", classification: "evaluation-consequence", status: "provisional"}
		comprehensions: {id: "comprehensions", path: "patterns/comprehensions.cue", blob: "01ea02b3b8812351be6e2b2b0b671975496644cc", contentSHA256: "66e8ebd68759e2bc5dd10be7e148a012a323946ef4e2f82335c9fb331edfac62", classification: "application-pattern", status: "provisional"}
		constructors: {id: "constructors", path: "patterns/constructors.cue", blob: "eadbed0bce2ea3c88d542a2316e0c1d5a6927abb", contentSHA256: "2e8a6c1592349c84731ce19e4d3c6b621b4a47845b28ecb6c52457d555cd24ae", classification: "application-pattern", status: "provisional"}
		cycles: {id: "cycles", path: "patterns/cycles.cue", blob: "616408cee2f6bf10529e864c9846a4a31c654510", contentSHA256: "e6e604ed471db5a0e89223034df01a5e7eca1e4ffbf7c694b60f71d04df27966", classification: "evaluation-consequence", status: "provisional"}
		defaults: {id: "defaults", path: "patterns/defaults.cue", blob: "8c415e642c3b97624935177d70e5109c47ad1817", contentSHA256: "ec0c1596fe615adde0b17eb55aa6a3cdbd603773b77154fc5663b6ff80f9e640", classification: "evaluation-consequence", status: "provisional"}
		definitions: {id: "definitions", path: "patterns/definitions.cue", blob: "3d25033ddb0c157fdc0ee85360447e7e579505af", contentSHA256: "9355ceeed9f836f9deeccdab7be8b52b6794efd1eb78ea16c940637a8ec6721d", classification: "evaluation-consequence", status: "provisional"}
		disjunctions: {id: "disjunctions", path: "patterns/disjunctions.cue", blob: "dcd80ee02012e5863e121aba33ebef8cd68f8179", contentSHA256: "35be824ae72a54a8345e3cfc649065b17125b485b9c295e1761a79b960a62152", classification: "lattice-primitive", status: "provisional"}
		"hidden-and-let": {id: "hidden-and-let", path: "patterns/hidden-and-let.cue", blob: "f9f1149999c8ef4c39beb8df2f802556a8e07e5b", contentSHA256: "ab327c1ae1e0b09a280e4e5b3e24ee5971cf100bcbf7888b342128a8b4d44141", classification: "application-pattern", status: "provisional"}
		lists: {id: "lists", path: "patterns/lists.cue", blob: "d9968e695f789c86684ea14bb1b66c22a3dd85ed", contentSHA256: "a7bf25ed7ff6a688fcf35f5949389652f3bc02affe3954a4cfe20cb84c0c7e95", classification: "lattice-primitive", status: "provisional"}
		"negative-fixtures": {id: "negative-fixtures", path: "patterns/negative-fixtures.cue", blob: "3e7e95d99f5d706ebb2fb7542c338dff2834373f", contentSHA256: "d85b491e6b55d0566168b834ae16b5ea055abe05f442de923ce4a21e888aa6bc", classification: "fixture-protocol", status: "provisional"}
		projections: {id: "projections", path: "patterns/projections.cue", blob: "087631a18a751229c4a09554b5024ca0aa911bf1", contentSHA256: "abc0359f820542022b1abe2e7c72a7b63a3a25afd1e2880c128d0455f80d3ebd", classification: "application-pattern", status: "provisional"}
		subsumption: {id: "subsumption", path: "patterns/subsumption.cue", blob: "3e92af5cedd78aac2103e43c0b3e30466a7c3f4f", contentSHA256: "45e4c3a1f88bf51d3d84e9436f1bea12980134df5f7cf549c54916b8dc1dfe41", classification: "lattice-law", status: "provisional"}
		"top-and-bottom": {id: "top-and-bottom", path: "patterns/top-and-bottom.cue", blob: "f5fbd09392bc153c0f1d573533c08c8cbd0e01c4", contentSHA256: "3ac335fd3fcbb32360a576f8013ca7352398c28ce521ad3313f3f9ff78309004", classification: "lattice-primitive", status: "provisional"}
		unification: {id: "unification", path: "patterns/unification.cue", blob: "e3e6f0bc07ae91fc60182323f535b0d2253b6ab2", contentSHA256: "d6cff6d27aebe30c1a7cb9f6be4f636606ac0b29e5aa7b93907378b40a09f82b", classification: "lattice-law", status: "provisional"}
	})
	metadata: {schema: {id: "schema", path: "patterns/schema.cue", blob: "e8e82f8977967766ba1badaf2d8503e064983130", contentSHA256: "4cfe3b0ec2b896e60b47b5448f00768c8f4973d8df12c69562c0f9f10fbbb416", classification: "metadata", status: "provisional", semanticProof: false}}
	semanticCount: 16
	status:        "provisional"
}

kernelManifest: #KernelManifest & {
	id:                  "lattice-kernel-source-manifest-v1"
	source:              sourceIdentity
	sourcePath:          "meta/kernel.cue"
	sourceBlob:          "f2570c424de2d4cb5b4603a265b7a6fc9dd7a0dd"
	sourceContentSHA256: "2ab6df31c80276c7f5dc1097e23641339676c5aeca3bfd610fe52aa394b5cd19"
	localPath:           ".codex/skills/cue/contracts/kernel/kernel.cue"
	localContentSHA256:  "2321bdf585fd0d7be027a50d5dc55c6602dd9ac5ae55d99c663c851fd0ceab85"
	exportedDeclarations: [
		"#NonEmptyString", "#NonEmptyStringList", "#KebabIdentifier", "#CueSelectorExpr", "#KebabMapKeyGuard", "#RefSet",
		"#ResourceRole", "#OperationKind", "#GeneratedOutputResourceRole", "#VisibilityTier", "#Resource", "#Operation", "#Gate", "#Witness",
		"#ResourceMap", "#OperationMap", "#GateMap", "#WitnessMap", "#ObligationState", "#ClosedObligationState", "#MakeClosedObligationState",
		"#StateKeySet", "#OperationRefKeySet", "#NoWideningProof", "#NegativeFixtureSpec", "#NegativeFixture", "#UncheckedNegativeFixture",
		"#NegativeFixtureProbeSpec", "#NegativeFixtureConflictProbe", "#NegativeFixtureProbeBinding", "#NegativeFixtureCheck",
		"#MakeUncheckedNegativeFixture", "#MakeNegativeFixtureSpec", "#MakeNegativeFixtureProbeBinding", "#MakeNegativeFixture", "#MakeNegativeFixtureCheck",
	]
	intentionalDivergences: [{id: "exact-key-compatibility-name", description: "The skill-local copy exposes #ExactKeyCompatibilityProof and retains #NoWideningProof only as a provisional compatibility alias."}]
	patternDependencies: [for id in ["bounds", "closedness", "constructors", "hidden-and-let", "negative-fixtures", "projections", "subsumption", "top-and-bottom", "unification"] {{id: id, status: "provisional", admitted: false}}]
	conceptDependencies: [for id in ["closed-ingress", "constructor-wiring", "destructive-conflict", "exact-key-identity", "reference-integrity", "structural-compatibility"] {{id: id, status: "provisional", admitted: false}}]
	status: "provisional"
}

patternIDs: list.SortStrings([for id, _ in patternInventory.patterns {id}])
classificationIDs: list.SortStrings([for _, pattern in patternInventory.patterns {pattern.classification}])
expectedPatternIDs: ["attributes", "bounds", "closedness", "comprehensions", "constructors", "cycles", "defaults", "definitions", "disjunctions", "hidden-and-let", "lists", "negative-fixtures", "projections", "subsumption", "top-and-bottom", "unification"]

_patternIdentityProof: {
	for id, pattern in patternInventory.patterns {
		"\(id)-identity": pattern.id & id
	}
}

inventoryComplete: patternIDs == expectedPatternIDs &&
	len(patternIDs) == patternInventory.semanticCount &&
	len(_patternIdentityProof) == patternInventory.semanticCount &&
	patternInventory.metadata.schema.semanticProof == false &&
	len(kernelManifest.exportedDeclarations) == 36
