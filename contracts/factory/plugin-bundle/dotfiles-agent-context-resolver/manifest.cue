package dotfilespluginbundle

#PluginName: =~"^[a-z0-9][a-z0-9-]*$"
#RelativePath: string & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#SemVer: =~"^[0-9]+\\.[0-9]+\\.[0-9]+([+-][0-9A-Za-z.-]+)?$"

#PluginInterface: close({
	displayName:      #NonEmptyString
	shortDescription: #NonEmptyString
	longDescription?: #NonEmptyString
	developerName?:   #NonEmptyString
	category?:        #NonEmptyString
	capabilities?: [...#NonEmptyString]
	urls?: [...#NonEmptyString]
	defaultPrompts?: [...#NonEmptyString]
	brandColor?: #NonEmptyString
	icons?: [...#RelativePath]
	logos?: [...#RelativePath]
	screenshots?: [...#RelativePath]
})

#PluginManifest: close({
	name:         #PluginName
	version?:     #SemVer
	description?: #NonEmptyString
	keywords?: [...#NonEmptyString]

	skills?:     #RelativePath
	mcpServers?: #RelativePath | {...}
	apps?:       #RelativePath

	// Upstream Rust models hooks structurally. Keep hooks gated until install/runtime behavior is proven end-to-end.
	hooks?: #RelativePath | [..._]

	interface?: #PluginInterface
})

resolverPluginManifestPath: "plugins/agent-context-resolver/.codex-plugin/plugin.json"

resolverPluginManifest: #PluginManifest & {
	name:        "agent-context-resolver"
	version:     "0.1.0"
	description: "Resolve repository-local agent context from contract authority into admitted Codex skill context."
	keywords: ["codex", "cue", "context", "resolver", "contracts"]
	skills: "./skills/"
	interface: {
		displayName:      "Agent Context Resolver"
		shortDescription: "Resolve contract-owned Codex context."
		longDescription:  "Packages the repository context-resolution workflow as a reusable Codex skill backed by CUE authority and validation gates."
		developerName:    "fatb4f"
		category:         "Developer Tools"
		capabilities: ["Read", "Analyze", "Workflow"]
	}
}

resolverPluginManifestJSON: """
	{
	  "name": "agent-context-resolver",
	  "version": "0.1.0",
	  "description": "Resolve repository-local agent context from contract authority into admitted Codex skill context.",
	  "keywords": ["codex", "cue", "context", "resolver", "contracts"],
	  "skills": "./skills/",
	  "interface": {
	    "displayName": "Agent Context Resolver",
	    "shortDescription": "Resolve contract-owned Codex context.",
	    "longDescription": "Packages the repository context-resolution workflow as a reusable Codex skill backed by CUE authority and validation gates.",
	    "developerName": "fatb4f",
	    "category": "Developer Tools",
	    "capabilities": ["Read", "Analyze", "Workflow"]
	  }
	}
	"""
