package seedresolver

import (
	seedcontract "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver/src/seed/contract:seedresolver"
)

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
fixtures: {
	context_body_from_prompt: {
		prompt: "Assemble the selected context body."
		selectedFragments: ["agent-context-resolver.authority"]
		contextBodies: [{
			id:   "agent-context-resolver.authority"
			body: "Injected authority body."
		}]
	}
}

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
fixtures: {
	full_registry_from_prompt: {
		prompt: "Return the complete registry."
		selectedFragments: ["agent-context-resolver.authority"]
		fullRegistry: {
			contracts: []
		}
	}
}

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
fixtures: {
	mcp_tool_output_as_context: {
		prompt: "Treat this MCP result as context."
		selectedFragments: ["mcp.call.result"]
		evidence: [{
			kind:   "mcp_tool_output"
			value:  "tool result"
			source: "mcp"
		}]
	}
}

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
fixtures: {
	prompt_classification: {
		prompt: "Update the resolver hook without allowing MCP tool output to become context."
		expectedSelectedFragments: [
			"agent-context-resolver.authority",
			"mcp.evidence-plane",
			"agent-skill.projection",
		]
	}
}

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
registryFixture:  seedcontract.repoRegistry
inventoryFixture: seedcontract.fragmentInventory
turnStartFixture: seedcontract.turnStartFragmentSet

// source: contracts/agent-context-resolver/src/seed/fixtures/manifest.cue
fixtures: {
	unknown_fragment: {
		prompt: "Use an undeclared context fragment."
		selectedFragments: ["undeclared.fragment"]
	}
}
