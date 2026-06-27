package dotfilespluginbundle

contractCuemodInput: #ContractCuemodInput & {
	repo: "github.com/fatb4f/contract.cuemod"
	ref:  "contract.cuemod:agent-context-resolver-plugin-bundle-v0"
	paths: [
		"contracts/agent-context-resolver",
		"contracts/agent-context-resolver/generated/turn_start_fragments.json",
		"contracts/agent-context-resolver/generated/prompt_routes.json",
		"contracts/agent-context-resolver/generated/route_inventory.json",
		"contracts/agent-context-resolver/generated/fragment_inventory.json",
		"contracts/agent-context-resolver/generated/provider_inventory.json",
	]
	exports: [
		"agentContextResolver",
		"turnStartFragments",
		"promptRoutes",
		"routeInventory",
		"fragmentInventory",
		"providerInventory",
	]
}
