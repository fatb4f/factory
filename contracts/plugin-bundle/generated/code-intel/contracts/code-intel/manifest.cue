package codeintel

#RuntimeEvidenceSurface: close({
	id:   string & !=""
	kind: "mcp" | "lsp" | "types" | "workflow" | "contract"
	paths: [...string] & [_, ...]
	authority:    false
	evidenceOnly: true
})

#RuntimeCueImportRefusal: close({
	path: string & !=""
	forbiddenImports: [...string] & [_, ...]
	forbiddenConstructors: [...string] & [_, ...]
	refusal: string & !=""
})

#GeneratedManifestContractInventoryAlignment: close({
	manifestJSON: string & !=""
	contracts: [...string]
	materializedContractFiles: [...string]
	diffIsEmpty:               true
	runtimeEvidenceListedOnce: true
})

#CodeIntelRuntimeEvidenceManifest: close({
	schema:       "factory.plugin-bundle.code-intel.runtime-evidence.v1"
	bundleID:     "code-intel"
	generated:    true
	authority:    false
	evidenceOnly: true
	surfaces: [...#RuntimeEvidenceSurface] & [_, ...]
	denies: [...string] & [_, ...]
})

codeIntelRuntimeEvidenceManifest: #CodeIntelRuntimeEvidenceManifest & {
	surfaces: [
		{
			id:   "manifest-json"
			kind: "contract"
			paths: ["manifest.json"]
			authority:    false
			evidenceOnly: true
		},
		{
			id:   "runtime-evidence-cue"
			kind: "contract"
			paths: ["contracts/code-intel/manifest.cue"]
			authority:    false
			evidenceOnly: true
		},
		{
			id:   "mcp-projection"
			kind: "mcp"
			paths: ["generated/mcp/server-manifest.json", "generated/mcp/tool-registry.json", "generated/mcp/context-projection.json"]
			authority:    false
			evidenceOnly: true
		},
		{
			id:   "lsp-projection"
			kind: "lsp"
			paths: ["generated/lsp/cue-lsp.json", "generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"]
			authority:    false
			evidenceOnly: true
		},
		{
			id:   "type-overlays"
			kind: "types"
			paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua", "generated/types/nvim/vim.lua"]
			authority:    false
			evidenceOnly: true
		},
		{
			id:   "lua-first-workflow"
			kind: "workflow"
			paths: ["generated/workflows/lua-first/workflow.json", "generated/workflows/lua-first/entrypoints.json", "generated/workflows/lua-first/diagnostic-map.json"]
			authority:    false
			evidenceOnly: true
		},
	]
	denies: [
		"bundled runtime CUE imports factory source authority",
		"bundled runtime CUE imports contract.cuemod authority",
		"bundled runtime CUE instantiates source-only bottom-check proof constructors",
		"generated runtime files become source authority",
		"manifest.json references non-materialized contract files",
	]
}

runtimeCueImportRefusal: #RuntimeCueImportRefusal & {
	path: "contracts/plugin-bundle/generated/code-intel/contracts/code-intel/manifest.cue"
	forbiddenImports: [
		"CUE import block",
		"factory source authority import",
		"external contract module import",
	]
	forbiddenConstructors: [
		"source-only bottom-check proof constructor",
		"implementation selector",
	]
	refusal: "generated plugin runtime CUE must be evidence-only and import-free"
}

generatedManifestContractInventoryAlignment: #GeneratedManifestContractInventoryAlignment & {
	manifestJSON: "contracts/plugin-bundle/generated/code-intel/manifest.json"
	contracts: [
		"contracts/code-intel/manifest.cue",
	]
	materializedContractFiles: [
		"contracts/code-intel/manifest.cue",
	]
	diffIsEmpty:               true
	runtimeEvidenceListedOnce: true
}

codeIntelRuntimeEvidenceValidationPlan: close({
	path:         "contracts/plugin-bundle/generated/code-intel"
	checkSurface: "runtime evidence manifest"
	bottomChecks: ["forbidden-import-search"]
	commands: [
		"test -f contracts/plugin-bundle/generated/code-intel/contracts/code-intel/manifest.cue",
		"jq -e '.contracts | index(\"contracts/code-intel/manifest.cue\")' contracts/plugin-bundle/generated/code-intel/manifest.json",
		"! jq -e '.contracts[] | select(. == \"contracts/code-intel/lua-first-workflow.cue\" or . == \"contracts/code-intel/checks.cue\" or . == \"contracts/code-intel/recommendations.cue\")' contracts/plugin-bundle/generated/code-intel/manifest.json",
	]
})

codeIntelRuntimeEvidenceCompletionReport: close({
	bundleID:   codeIntelRuntimeEvidenceManifest.bundleID
	schema:     codeIntelRuntimeEvidenceManifest.schema
	authority:  codeIntelRuntimeEvidenceManifest.authority
	validation: codeIntelRuntimeEvidenceValidationPlan
	evidence: [
		"bundled runtime CUE is an evidence-only manifest with no external imports",
		"source authority and bottom-check construction remain under contracts/code-intel/src",
		"generated manifest.json contracts inventory matches actual materialized files",
	]
})
