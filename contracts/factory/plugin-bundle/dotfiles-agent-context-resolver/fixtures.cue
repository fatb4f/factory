package dotfilespluginbundle

negativeFixtures: {
	codexAsAuthority: {
		input: dotfilesAgentContextResolverBundleInput & {
			codexAuthority: true
		}
	}

	generatedAsAuthority: {
		input: dotfilesAgentContextResolverBundleInput & {
			generatedAuthority: true
		}
	}

	externalDependency: {
		input: dotfilesAgentContextResolverBundleInput & {
			externalFactoryRootLookup: true
		}
	}

	providerOutputAsAuthority: {
		input: dotfilesAgentContextResolverBundleInput & {
			providerOutputIsAuthority: true
		}
	}

	materializationWithoutLock: {
		input: {
			repo:      dotfilesTarget.repo
			root:      dotfilesTarget.root
			files:     generatedFileInventory
			overwrite: "replace-generated"
			provenance: {
				kind:       "projection"
				sourceRepo: contractCuemodInput.repo
				sourceRef:  contractCuemodInput.ref
				projection: "dotfiles-agent-context-resolver-plugin-bundle-v0"
				lockID:     "missing-lock-evidence"
				authority:  false
			}
			lock: dotfilesAgentContextResolverLock
		}
	}
}
