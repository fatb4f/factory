package pluginbundletemplate

import impl "github.com/fatb4f/factory/contracts/meta"

pluginBundleScaffoldGenerator: impl.#ContractGenerator & {
	kind:    "contract-generator"
	name:    "pluginBundleScaffoldGenerator"
	command: "contracts/plugin-bundle/template/scripts/scaffold-plugin-bundle"
	inputs: [
		"bundle-id",
		"src-root",
		"out",
		"force",
	]
	outputs: [
		"contract.cue",
		"checks/checks.cue",
		"generated/checks/check_manifest.json",
	]
	invariants: [
		"contracts/plugin-bundle/template remains parent authority for generated plugin-bundle children",
		"generated plugin-bundle artifacts are evidence only",
		"generated child contracts use repo-relative paths only",
		"generated child checks use #MakeBottomCheckProof",
	]
}
