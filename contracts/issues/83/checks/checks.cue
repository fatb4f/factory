package issue83checks

_negativeFixtures: {
	codeIntelDistributedToFactoryAccepted: {
		input: {
			sourceBundle:     "code-intel"
			targetRepository: "fatb4f/factory"
			targetPath:       ".codex/plugins/code-intel"
		}
	}
	dotfilesSourceAuthorityAccepted: {
		input: {
			targetRepository:       "fatb4f/dotfiles"
			sourceAuthority:        "fatb4f/dotfiles:.codex/plugins"
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

_negativeBottomChecks: {
	codeIntelDistributedToFactoryAccepted: _negativeFixtures.codeIntelDistributedToFactoryAccepted.input & {
		sourceBundle: string
		targetRepository: != "fatb4f/factory"
	}
	dotfilesSourceAuthorityAccepted: _negativeFixtures.dotfilesSourceAuthorityAccepted.input & {
		targetOwnsSourceAuthority: false
	}
	outsidePluginRootAccepted: _negativeFixtures.outsidePluginRootAccepted.input & {
		pathContained: true
		targetPath: =~"^\\.codex/plugins/[^/]+$"
	}
	unreviewedCrossRepoWriteAccepted: _negativeFixtures.unreviewedCrossRepoWriteAccepted.input & {
		reviewBoundary: != "none"
		reviewableDiff: true
	}
}
