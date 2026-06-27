package dotfilespluginbundle

#OverwritePolicy: "replace-generated"

#DotfilesPluginMaterialization: {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
	files: [...#DotfilesTargetFile]
	overwrite: #OverwritePolicy
	provenance: close({
		kind:       "projection"
		sourceRepo: "github.com/fatb4f/contract.cuemod"
		sourceRef:  #NonEmptyString
		projection: "dotfiles-agent-context-resolver-plugin-bundle-v0"
		lockID:     #NonEmptyString
		authority:  false
	})
	lock: #BundleLockEvidence
}

#AdmissibleDotfilesPluginMaterialization: _candidate=(#DotfilesPluginMaterialization & {
	if _candidate.provenance.lockID != _candidate.lock.id {
		_materializationWithoutLock: _|_
	}

	if _candidate.provenance.sourceRef != _candidate.lock.source.ref {
		_lockSourceRefMismatch: _|_
	}

	if _candidate.provenance.projection != _candidate.lock.projection {
		_lockProjectionMismatch: _|_
	}
})

dotfilesTarget: #DotfilesTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

dotfilesAgentContextResolverMaterializationInput: {
	repo:      dotfilesTarget.repo
	root:      dotfilesTarget.root
	files:     generatedFileInventory
	overwrite: "replace-generated"
	provenance: {
		kind:       "projection"
		sourceRepo: contractCuemodInput.repo
		sourceRef:  contractCuemodInput.ref
		projection: "dotfiles-agent-context-resolver-plugin-bundle-v0"
		lockID:     dotfilesAgentContextResolverLock.id
		authority:  false
	}
	lock: dotfilesAgentContextResolverLock
}

dotfilesAgentContextResolverMaterialization: #AdmissibleDotfilesPluginMaterialization & dotfilesAgentContextResolverMaterializationInput
