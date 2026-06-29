package dotfilespluginbundle

dotfilesTarget: #DotfilesTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

dotfilesContractTargetInventory: [
	for relativePath in pluginBundleContractRequiredPaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

dotfilesRuntimePackageTargetInventory: [
	for relativePath in pluginBundleRuntimePackagePaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

// Backwards-compatible aliases. The materialized package uses the runtime inventory.
dotfilesTargetInventory: dotfilesContractTargetInventory
dotfilesRuntimeTargetInventory: dotfilesRuntimePackageTargetInventory

generatedFileInventory: [
	for targetPath in dotfilesRuntimePackageTargetInventory {
		path: targetPath
		generated: true
		authority: false
		source: "bundle-projection"
	},
]

fullGeneratedFileInventory: [
	for targetPath in dotfilesContractTargetInventory {
		path: targetPath
		generated: true
		authority: false
		source: "bundle-projection"
	},
]

projectionComponents: [
	{id: "plugin-bundle-contract", path: pluginBundleContractRoot, role: "contract", authority: true},
	{id: "plugin-bundle-source", path: pluginBundleSourceRoot, role: "contract", authority: true},
	{id: "plugin-bundle-template", path: pluginBundleTemplateRoot, role: "contract", authority: true},
	{id: "template-application", path: "\(pluginBundleContractRoot)/template_application.cue", role: "contract", authority: true},
	{id: "dotfiles-runtime-package-root", path: pluginBundleRoot, role: "generated-package", generated: true, authority: false},
	{id: "runtime-generated-surfaces", path: "\(pluginBundleRoot)/generated", role: "package-content", generated: true, authority: false},
	{id: "runtime-manifest", path: "\(pluginBundleRoot)/manifest.json", role: "package-metadata", generated: true, authority: false},
	{id: "runtime-package-lock", path: "\(pluginBundleRoot)/package.lock.json", role: "idempotency-lock", generated: true, authority: false},
	{id: "codex-hook-integration", path: ".codex/hooks.json", role: "integration", generated: true, authority: false},
]

projectionGates: [
	{id: "plugin-bundle-cue-vet", kind: "cue-vet", target: "./contracts/plugin-bundle/agent-context-resolver/instances/dotfiles", required: true},
	{id: "plugin-bundle-contract-export", kind: "cue-export", target: "dotfilesAgentContextResolverBundleContract", required: true},
	{id: "plugin-bundle-template-application-export", kind: "cue-export", target: "dotfilesAgentContextResolverTemplateApplication", required: true},
	{id: "plugin-bundle-materialization-export", kind: "cue-export", target: "dotfilesAgentContextResolverMaterialization", required: true},
	{id: "plugin-bundle-lock-export", kind: "cue-export", target: "dotfilesAgentContextResolverLock", required: true},
	{id: "plugin-bundle-package-export", kind: "cue-export", target: "dotfilesAgentContextResolverPackage", required: true},
	{id: "plugin-bundle-negative-bottom", kind: "negative-bottom", target: "_negativeBottomChecks", required: true},
]

dotfilesAgentContextResolverBundleInput: {
	contract: dotfilesAgentContextResolverBundleContract
	templateApplication: dotfilesAgentContextResolverTemplateApplication
	target: dotfilesTarget
	components: projectionComponents
	generatedFiles: generatedFileInventory
	materialization: dotfilesAgentContextResolverMaterializationInput
	lock: dotfilesAgentContextResolverLock
	package: dotfilesAgentContextResolverPackage
	gates: projectionGates
	providerReachability: {
		kind: "provider-reachability"
		authority: false
		evidenceOnly: true
		providers: [
			"fragment_inventory",
			"prompt_routes",
			"route_inventory",
		]
	}
}

dotfilesAgentContextResolverBundle: #AdmissibleDotfilesPluginBundleProjection & dotfilesAgentContextResolverBundleInput
