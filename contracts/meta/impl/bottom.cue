package impl

#BottomCheckPlanSpec: close({
	name: string & !=""
	fixture: string & !=""
	checkSurface: string & !=""
	checkFile: string & !=""
	targetBoundByAdapter: true | *true
})

#BottomCheckPlan: close({
	kind: "bottom-check-plan"
	name: string & !=""
	fixture: string & !=""
	checkSurface: string & !=""
	checkFile: string & !=""
	targetBoundByAdapter: true
})

#ProofInput: close({
	value: _
})

#ProofTargetRef: close({
	name: string & !=""
	contract: _
})

#BottomCheckProofSpec: close({
	name: string & !=""
	input: #ProofInput
	target: #ProofTargetRef
	expression?: false
	isInvalid?: false
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
})

#MakeBottomCheckPlan: {
	in: #BottomCheckPlanSpec

	out: #BottomCheckPlan & {
		kind: "bottom-check-plan"
		name: in.name
		fixture: in.fixture
		checkSurface: in.checkSurface
		checkFile: in.checkFile
		targetBoundByAdapter: in.targetBoundByAdapter
	}
}

#MakeBottomCheckProof: {
	in: #BottomCheckProofSpec

	out: {
		"\(in.name)": in.input.value & in.target.contract
	}
}

// Deprecated compatibility name for manifests that still need a plan-shaped
// constructor during migration. Executable checks must use #MakeBottomCheckProof.
#MakeBottomCheck: #MakeBottomCheckPlan
