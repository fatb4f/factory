package dotfilespluginbundle

#FileLock: close({
	path:      #NonEmptyString
	generated: true
	authority: false
})

#BundleLockEvidence: close({
	id:        #NonEmptyString
	authority: false
	source: close({
		repo: "github.com/fatb4f/contract.cuemod"
		ref:  #NonEmptyString
		paths: [#NonEmptyString, ...#NonEmptyString]
	})
	projection: "dotfiles-agent-context-resolver-plugin-bundle-v0"
	target: close({
		repo: "github.com/fatb4f/dotfiles"
		root: "."
	})
	files: [...#FileLock]
	gates: [#NonEmptyString]: close({
		required: true
		result:   "pass" | "pending"
	})
})

dotfilesAgentContextResolverLock: #BundleLockEvidence & {
	id:        "dotfiles-agent-context-resolver-plugin-bundle-v0"
	authority: false
	source: {
		repo:  contractCuemodInput.repo
		ref:   contractCuemodInput.ref
		paths: contractCuemodInput.paths
	}
	projection: "dotfiles-agent-context-resolver-plugin-bundle-v0"
	target:     dotfilesTarget
	files: [
		for file in generatedFileInventory {
			path:      file.path
			generated: true
			authority: false
		},
	]
	gates: {
		for gate in projectionGates {
			"\(gate.id)": {
				required: true
				result:   "pending"
			}
		}
	}
}
