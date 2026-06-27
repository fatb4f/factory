package dotfilespluginbundle

#PluginMarketplacePolicy: close({
	installation:   "AVAILABLE" | "REQUIRED" | "DISABLED"
	authentication: "ON_INSTALL" | "NONE"
})

#PluginSource: close({
	source: "local" | "git" | "npm"
	path?:  #RelativePath
	url?:   #NonEmptyString
	package?: #NonEmptyString
})

#MarketplacePluginEntry: close({
	name:     #PluginName
	source:   #PluginSource
	policy:   #PluginMarketplacePolicy
	category: #NonEmptyString
})

#MarketplaceManifest: close({
	plugins: [...#MarketplacePluginEntry]
})

resolverMarketplacePath: ".agents/plugins/marketplace.json"

resolverMarketplace: #MarketplaceManifest & {
	plugins: [{
		name: "agent-context-resolver"
		source: {
			source: "local"
			path:   "./plugins/agent-context-resolver"
		}
		policy: {
			installation:   "AVAILABLE"
			authentication: "ON_INSTALL"
		}
		category: "Developer Tools"
	}]
}

resolverMarketplaceJSON: """
	{
	  "plugins": [
	    {
	      "name": "agent-context-resolver",
	      "source": {
	        "source": "local",
	        "path": "./plugins/agent-context-resolver"
	      },
	      "policy": {
	        "installation": "AVAILABLE",
	        "authentication": "ON_INSTALL"
	      },
	      "category": "Developer Tools"
	    }
	  ]
	}
	"""
