package codeintelpluginbundlechecks

import (
	codeintel "github.com/fatb4f/factory/contracts/plugin-bundle/code-intel:codeintelpluginbundle"
	resolver "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver:agentcontextresolverpluginbundle"
)

codeIntelBundleRootShapeChecks: close({
	requiredFiles: {
		rootManifest: "manifest.cue"
		checksManifest: "checks/manifest.cue"
	}
	requiredDirectories: {
		checks:           "checks"
		instances:        "instances"
		dotfilesInstance: "instances/dotfiles"
		src:              "src"
	}
	rootShapeMatchesResolverSibling: close({
		codeIntelSourceRoot: codeintel.codeIntelPluginBundleSourceRoot.path
		resolverSourceRoot:  resolver.agentContextResolverPluginBundleSourceRoot.path
		codeIntelSourceRoot: "contracts/plugin-bundle/code-intel/src"
		resolverSourceRoot:  "contracts/plugin-bundle/agent-context-resolver/src"

		codeIntelInstanceRoot: codeintel.codeIntelPluginBundleInstanceRoot.lock.instanceRoot
		resolverInstanceRoot:  resolver.agentContextResolverPluginBundleDistributionLock.instanceRoot
		codeIntelInstanceRoot: "contracts/plugin-bundle/code-intel/instances/dotfiles"
		resolverInstanceRoot:  "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"

		requiredDirectories: codeintel.codeIntelPluginBundleRootShape.requiredDirectories
		requiredDirectories: ["checks", "instances", "instances/dotfiles", "src"]

		codeIntelSiblingRootEntries: codeintel.codeIntelSiblingRootShape.requiredRootEntries
		resolverSiblingRootEntries:  resolver.agentContextResolverSiblingRootShape.requiredRootEntries
		codeIntelSiblingRootEntries: ["checks", "instances", "src", "manifest.cue"]
		resolverSiblingRootEntries:  ["checks", "instances", "src", "manifest.cue"]

		codeIntelSrcEntries: codeintel.codeIntelSiblingRootShape.requiredSrcEntries
		resolverSrcEntries:  resolver.agentContextResolverSiblingRootShape.requiredSrcEntries
		codeIntelSrcEntries: ["checks", "contracts", "generated", "manifest.cue"]
		resolverSrcEntries:  ["checks", "contracts", "generated", "manifest.cue"]

		codeIntelGeneratedEntries: codeintel.codeIntelSiblingRootShape.requiredGeneratedEntries
		resolverGeneratedEntries:  resolver.agentContextResolverSiblingRootShape.requiredGeneratedEntries
		codeIntelGeneratedEntries: [".codex-plugin", "hooks", "scripts", "skills"]
		resolverGeneratedEntries:  [".codex-plugin", "hooks", "scripts", "skills"]
	})
	noTopLevelGeneratedPayloadUnderCodeIntelRoot: close({
		codeIntelRoot:          codeintel.codeIntelPluginBundleRootShape.root
		generatedPayloadRoot:   codeintel.codeIntelPluginBundleRootShape.generatedPayloadRoot
		generatedPayloadAtRoot: codeintel.codeIntelPluginBundleRootShape.topLevelGeneratedPayloadUnderRoot
		codeIntelRoot:          "contracts/plugin-bundle/code-intel"
		generatedPayloadRoot:   "contracts/plugin-bundle/generated/code-intel"
		generatedPayloadAtRoot: false
	})
	validationCommands: [
		"test -f contracts/plugin-bundle/code-intel/manifest.cue",
		"test -f contracts/plugin-bundle/code-intel/checks/manifest.cue",
		"test -d contracts/plugin-bundle/code-intel/instances",
		"test -d contracts/plugin-bundle/code-intel/instances/dotfiles",
		"test -d contracts/plugin-bundle/code-intel/src/checks",
		"test -d contracts/plugin-bundle/code-intel/src/contracts",
		"test -d contracts/plugin-bundle/code-intel/src/generated",
		"test -d contracts/plugin-bundle/generated/code-intel/.codex-plugin",
		"test -d contracts/plugin-bundle/generated/code-intel/hooks",
		"test -d contracts/plugin-bundle/generated/code-intel/scripts",
		"test -d contracts/plugin-bundle/generated/code-intel/skills",
		"test ! -e contracts/plugin-bundle/code-intel/generated",
		"test ! -e contracts/plugin-bundle/generated/code-intel/manifest.json",
		"test ! -e contracts/plugin-bundle/generated/code-intel/contracts",
		"test ! -e contracts/plugin-bundle/generated/code-intel/generated",
		"cue vet ./contracts/plugin-bundle/code-intel",
		"cue vet ./contracts/plugin-bundle/code-intel/checks",
		"cue export ./contracts/plugin-bundle/code-intel -e codeIntelPluginBundleSourceRoot",
		"cue export ./contracts/plugin-bundle/code-intel -e codeIntelPluginBundleDistributionLock",
	]
})
