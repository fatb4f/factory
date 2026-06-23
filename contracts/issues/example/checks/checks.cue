package issuechecks

#IssueManifestCandidate: close({
	manifestPath: string
	implImport: "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
	constructorCalls: [...string] & [_, ...]
	constructorBodies?: false
	stringifiedCueChecks?: false
})

negativeFixtures: {
	constructorBodies: {
		input: {
			manifestPath: "contracts/issues/example/manifest.cue"
			implImport: "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
			constructorCalls: ["impl.#MakePrimitive"]
			constructorBodies: true
		}
	}
}

_negativeBottomChecks: {
	constructorBodies: negativeFixtures.constructorBodies.input & #IssueManifestCandidate
}
