package assertions

import agentprojection "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver/src/projections/agent-skill:agentskillprojection"

codexPluginAssertions: {
	projectionAuthority: false
	extractable:         false

	hooks:        agentprojection.projection.hooks
	skillContent: agentprojection.skillContent
}
