package meta

#ContractScaffoldGenerator: close({
	kind:    "contract-scaffold-generator"
	command: string & !=""
	inputs: close({
		issue:   "required numeric issue identifier"
		sliceID: "required stable slice identifier"
		title:   "required issue or contract title"
		out:     "optional output directory, defaults to contracts/issues/<issue>"
		force:   "optional overwrite switch"
	})
	outputs: [
		"manifest.cue with constructor-instantiated meta workflow",
		"checks/checks.cue with executable #MakeBottomCheckProof checks",
	]
	invariants: [
		"contracts/meta remains constructor authority",
		"generated skeletons are scaffolds only",
		"manifest packages carry bottom-check plans only",
		"check packages carry executable bottom-check proofs only",
		"generated checks do not use default fallbacks, top fallbacks, invalidity flags, or expression strings",
	]
})

contractScaffoldGenerator: #ContractScaffoldGenerator & {
	kind:    "contract-scaffold-generator"
	command: "contracts/meta/scripts/scaffold-contract-slice"
}
