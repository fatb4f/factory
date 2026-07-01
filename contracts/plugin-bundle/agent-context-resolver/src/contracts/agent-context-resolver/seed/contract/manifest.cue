package seedresolver

import (
	"list"
)

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#TurnStartFragment: #ProjectedFragment & {
	surface: "turn_start"
}

#TurnStartFragmentSet: {
	generatedFrom: "registry.index.json"
	fragments: [...#TurnStartFragment]
}

turnStartFragmentSet: #TurnStartFragmentSet & {
	generatedFrom: "registry.index.json"
	fragments: [
		for fragment in fragmentInventory.fragments
		if fragment.surface == "turn_start" {
			fragment
		},
	]
}

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#TurnStartInput: {
	registryIndex: "registry.index.json"
}

#TurnStartOutput: #TurnStartFragmentSet

#UserPromptSubmitInput: {
	prompt: string
	availableFragmentIDs: [...string]
}

#Evidence: {
	kind:   "prompt_term" | "route_default"
	value:  string
	source: "user_prompt"
}

#UserPromptSubmitOutput: {
	selectedFragments: [...string]
	compactHints: [...string]
	evidence: [...#Evidence]

	fullRegistry?:  _|_
	contextBodies?: _|_
}

#UserPromptSubmitContract: {
	input:  #UserPromptSubmitInput
	output: #UserPromptSubmitOutput

	for _, id in output.selectedFragments {
		list.Contains(input.availableFragmentIDs, id)
	}
}

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#ProjectedFragment: {
	id:             string
	sourceContract: string
	sourcePath:     string
	role:           "authority" | "orientation" | "workflow" | "constraint" | "evidence"
	surface:        "turn_start" | "prompt" | "subagent"
	summary:        string
	authorityRoot:  string
	contractPath:   string
}

#FragmentInventory: {
	repo: #RepoContractRegistry.repo
	fragments: [...#ProjectedFragment]
}

fragmentInventory: #FragmentInventory & {
	repo: repoRegistry.repo
	fragments: [
		for contract in repoRegistry.contracts
		for fragment in contract.fragments {
			id:             fragment.id
			sourceContract: fragment.sourceContract
			sourcePath:     fragment.sourcePath
			role:           fragment.role
			surface:        fragment.surface
			summary:        fragment.summary
			authorityRoot:  contract.authorityRoot
			contractPath:   contract.contractPath
		},
	]
}

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#PromptRoute: {
	id: string
	terms: [...string] & [_, ...]
	selects: [...string] & [_, ...]
	invokes: [...string] & [_, ...]
	hint:     string
	priority: int & >=0
}

promptRoutes: [...#PromptRoute] & [
	{
		id: "resolver"
		terms: ["resolver", "context", "prompt", "hook", "turnstart"]
		selects: ["agent-context-resolver.authority"]
		invokes: ["resolver.inspect.current", "resolver.plan.compile"]
		hint:     "Apply the resolver lifecycle and generated-fragment boundary."
		priority: 100
	},
	{
		id: "patch-stack"
		terms: ["patch", "stack", "rebase"]
		selects: ["vcs.patch-stack"]
		invokes: ["vcs.patch-stack.inspect"]
		hint:     "Apply the declared patch-stack workflow."
		priority: 80
	},
	{
		id: "mcp"
		terms: ["mcp", "tool", "server"]
		selects: ["mcp.evidence-plane"]
		invokes: ["mcp.evidence.inspect"]
		hint:     "Keep MCP results in the evidence plane."
		priority: 80
	},
	{
		id: "skill"
		terms: ["skill", "hook", "codex"]
		selects: ["agent-skill.projection"]
		invokes: ["agent-skill.projection.validate"]
		hint:     "Apply the generated agent skill and hook projection constraints."
		priority: 70
	},
	{
		id: "context-packet"
		terms: ["context packet", "dependency", "projection"]
		selects: ["resolver.context-packet"]
		invokes: ["resolver.context-packet.inspect"]
		hint:     "Apply the context packet projection workflow."
		priority: 70
	},
	{
		id: "repo"
		terms: ["repository", "generated", "fixture"]
		selects: ["repo.lifecycle"]
		invokes: ["repo.lifecycle.validate"]
		hint:     "Preserve repository lifecycle and generated-output boundaries."
		priority: 70
	},
]

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#ProofCheck: {
	id:   string
	pass: true
}

#LifecycleReport: {
	version: "contract-cuemod.agent-context-resolver-proof/v1"
	checks: [...#ProofCheck] & [_, ...]
}

// source: contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue
#RepoContractRegistry: {
	repo: {
		id:   string
		root: string
	}

	contracts: [...#ContractAuthority] & [_, ...]
}

#ContractAuthority: {
	id:            string
	authorityRoot: string
	contractPath:  string

	fragments: [...#FragmentDeclaration] & [_, ...]

	hooks?: {
		turnStart?:        bool
		userPromptSubmit?: bool
	}
}

#FragmentDeclaration: {
	id:             string
	sourceContract: string
	sourcePath:     string
	role:           "authority" | "orientation" | "workflow" | "constraint" | "evidence"
	surface:        "turn_start" | "prompt" | "subagent"
	summary:        string
}

repoRegistry: #RepoContractRegistry & {
	repo: {
		id:   "fatb4f/manifest.cuemod"
		root: "."
	}

	contracts: [
		{
			id:            "agent-context-resolver"
			authorityRoot: "contracts/plugin-bundle/agent-context-resolver/src"
			contractPath:  "contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/manifest.cue"
			hooks: {
				turnStart:        true
				userPromptSubmit: true
			}
			fragments: [
				{
					id:             "agent-context-resolver.authority"
					sourceContract: "agent-context-resolver"
					sourcePath:     "contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/manifest.cue"
					role:           "authority"
					surface:        "turn_start"
					summary:        "Authoritative resolver lifecycle and context selection boundary."
				},
				{
					id:             "agent-context-resolver.prompt-routing"
					sourceContract: "agent-context-resolver"
					sourcePath:     "contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/manifest.cue"
					role:           "workflow"
					surface:        "prompt"
					summary:        "Prompt classifier route hints and declared fragment selection rules."
				},
			]
		},
		{
			id:            "agent-skill"
			authorityRoot: "contracts/agent-skill"
			contractPath:  "contracts/agent-skill/manifest.cue"
			fragments: [{
				id:             "agent-skill.projection"
				sourceContract: "agent-skill"
				sourcePath:     "contracts/agent-skill/manifest.cue"
				role:           "constraint"
				surface:        "turn_start"
				summary:        "Generated agent skill, hook, and script projection constraints."
			}]
		},
		{
			id:            "mcp"
			authorityRoot: "contracts/protocols/mcp"
			contractPath:  "contracts/protocols/mcp/mcp.cue"
			fragments: [{
				id:             "mcp.evidence-plane"
				sourceContract: "mcp"
				sourcePath:     "contracts/protocols/mcp/mcp.cue"
				role:           "constraint"
				surface:        "turn_start"
				summary:        "MCP provider, result, and evidence-plane constraints."
			}]
		},
		{
			id:            "resolver"
			authorityRoot: "contracts/context/packet"
			contractPath:  "contracts/context/packet/manifest.cue"
			fragments: [{
				id:             "resolver.context-packet"
				sourceContract: "resolver"
				sourcePath:     "contracts/context/packet/manifest.cue"
				role:           "workflow"
				surface:        "turn_start"
				summary:        "Context packet selection and dependency projection workflow."
			}]
		},
		{
			id:            "repo"
			authorityRoot: "contracts/repo"
			contractPath:  "contracts/repo/lifecycle.cue"
			fragments: [{
				id:             "repo.lifecycle"
				sourceContract: "repo"
				sourcePath:     "contracts/repo/lifecycle.cue"
				role:           "constraint"
				surface:        "turn_start"
				summary:        "Repository source, generated, fixture, and lifecycle boundaries."
			}]
		},
		{
			id:            "vcs"
			authorityRoot: "contracts/vcs"
			contractPath:  "contracts/vcs/patch_stack_manifest.cue"
			fragments: [{
				id:             "vcs.patch-stack"
				sourceContract: "vcs"
				sourcePath:     "contracts/vcs/patch_stack_manifest.cue"
				role:           "workflow"
				surface:        "turn_start"
				summary:        "Patch stack ownership, ordering, and validation workflow."
			}]
		},
	]
}
