package pluginbundlegenerationdistributionchecks

import gen "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/generation-distribution:pluginbundlegenerationdistribution"

_crossRepoFixtures: {
	codeIntelDistributedToFactoryAccepted: {
		input: {
			sourceBundle:     "code-intel"
			targetRepository: "fatb4f/factory"
			targetPath:       ".codex/plugins/code-intel"
		}
	}
	dotfilesSourceAuthorityAccepted: {
		input: {
			targetRepository:         "fatb4f/dotfiles"
			sourceAuthority:          "fatb4f/dotfiles:.codex/plugins"
			targetOwnsSourceAuthority: true
		}
	}
	outsidePluginRootAccepted: {
		input: {
			targetRepository: "fatb4f/dotfiles"
			targetPath:       "contracts/plugin-bundle/generated/agent-context-resolver"
			pathContained:    false
		}
	}
	unreviewedCrossRepoWriteAccepted: {
		input: {
			targetRepository: "fatb4f/dotfiles"
			reviewBoundary:   "none"
			reviewableDiff:   false
		}
	}
}

crossRepoPluginBundleDistributionTargetMatrix: gen.CrossRepoPluginBundleDistributionTargetMatrix

_crossRepoBottomChecks: {
	codeIntelDistributedToFactoryAccepted: _crossRepoFixtures.codeIntelDistributedToFactoryAccepted.input & {
		targetRepository: != "fatb4f/factory"
	}
	dotfilesSourceAuthorityAccepted: _crossRepoFixtures.dotfilesSourceAuthorityAccepted.input & {
		targetOwnsSourceAuthority: false
	}
	outsidePluginRootAccepted: _crossRepoFixtures.outsidePluginRootAccepted.input & {
		pathContained: true
		targetPath: =~"^\\.codex/plugins/[^/]+$"
	}
	unreviewedCrossRepoWriteAccepted: _crossRepoFixtures.unreviewedCrossRepoWriteAccepted.input & {
		reviewBoundary: != "none"
		reviewableDiff: true
	}
}

_negativeFixtures: {
	generatedPackageAuthorityAccepted: {
		input: {
			path:                      ".codex/plugins/agent-context-resolver/manifest.json"
			role:                      "authority"
			generatedPackageAuthority: true
		}
	}
	distributionOutsidePluginRootAccepted: {
		input: {
			bundleID:         "agent-context-resolver"
			distributionRoot: ".codex/../contracts/plugin-bundle/agent-context-resolver/src"
			pathContained:    false
		}
	}
	nonDeterministicGenerationAccepted: {
		input: {
			generatedAtRuntime:    true
			nonDeterministicInput: true
		}
	}
	runtimeExternalSourceLookupAccepted: {
		input: {
			runtimeRequiresExternalFactoryLookup: true
			runtimeRequiresContractCuemodLookup:  true
		}
	}
}

_negativeBottomChecks: {
	generatedPackageAuthorityAccepted:     _negativeFixtures.generatedPackageAuthorityAccepted.input & gen.#GeneratedPackageAuthorityBoundary
	distributionOutsidePluginRootAccepted: _negativeFixtures.distributionOutsidePluginRootAccepted.input & gen.#DistributionRootContainmentBoundary
	nonDeterministicGenerationAccepted:    _negativeFixtures.nonDeterministicGenerationAccepted.input & gen.#DeterministicGenerationBoundary
	runtimeExternalSourceLookupAccepted:   _negativeFixtures.runtimeExternalSourceLookupAccepted.input & gen.#RuntimeExternalSourceLookupBoundary
}

crossRepoPluginBundleDistributionNegativeBottomChecks: _crossRepoBottomChecks

pluginBundleGenerationDistributionNegativeBottomChecks: _negativeBottomChecks
