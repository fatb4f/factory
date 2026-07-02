package agentcontextresolverpluginbundlechecks

import (
	resolver "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver:agentcontextresolverpluginbundle"
)

agentContextResolverBundleRootShapeChecks: close({
	requiredFiles: {
		rootManifest:   "manifest.cue"
		checksManifest: "checks/manifest.cue"
	}
	requiredDirectories: {
		checks:           "checks"
		instances:        "instances"
		dotfilesInstance: "instances/dotfiles"
		src:              "src"
	}
	siblingRootShape: close({
		root:                    resolver.agentContextResolverSiblingRootShape.root
		sourceAuthorityRoot:     resolver.agentContextResolverSiblingRootShape.sourceAuthorityRoot
		generatedProjectionRoot: resolver.agentContextResolverSiblingRootShape.generatedProjectionRoot
		requiredRootEntries:     resolver.agentContextResolverSiblingRootShape.requiredRootEntries
		requiredSrcEntries:      resolver.agentContextResolverSiblingRootShape.requiredSrcEntries
		requiredGeneratedEntries: resolver.agentContextResolverSiblingRootShape.requiredGeneratedEntries

		root:                    "contracts/plugin-bundle/agent-context-resolver"
		sourceAuthorityRoot:     "contracts/plugin-bundle/agent-context-resolver/src"
		generatedProjectionRoot: "contracts/plugin-bundle/generated/agent-context-resolver"
		requiredRootEntries:     ["checks", "instances", "src", "manifest.cue"]
		requiredSrcEntries:      ["checks", "contracts", "generated", "manifest.cue"]
		requiredGeneratedEntries: [".codex-plugin", "hooks", "scripts", "skills"]
	})
	validationCommands: [
		"test -f contracts/plugin-bundle/agent-context-resolver/manifest.cue",
		"test -f contracts/plugin-bundle/agent-context-resolver/checks/manifest.cue",
		"test -d contracts/plugin-bundle/agent-context-resolver/instances/dotfiles",
		"test -d contracts/plugin-bundle/agent-context-resolver/src/checks",
		"test -d contracts/plugin-bundle/agent-context-resolver/src/contracts",
		"test -d contracts/plugin-bundle/agent-context-resolver/src/generated",
		"test -d contracts/plugin-bundle/generated/agent-context-resolver/.codex-plugin",
		"test -d contracts/plugin-bundle/generated/agent-context-resolver/hooks",
		"test -d contracts/plugin-bundle/generated/agent-context-resolver/scripts",
		"test -d contracts/plugin-bundle/generated/agent-context-resolver/skills",
	]
})
