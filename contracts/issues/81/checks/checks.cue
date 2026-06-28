package issue81checks

import resolver "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

import codeintel "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/code-intel/src:codeintelsrc"

_negativeFixtures: {
	resolverShapeDrift: {
		input: {
			srcRoot: "contracts/plugin-bundle/agent-context-resolver/private-src"
		}
	}
	codeIntelShapeDrift: {
		input: {
			srcRoot: "contracts/plugin-bundle/code-intel/private-src"
		}
	}
}

_negativeBottomChecks: {
	resolverShapeDrift:  _negativeFixtures.resolverShapeDrift.input & resolver.normalizedMaterializedBundleShapeManifest
	codeIntelShapeDrift: _negativeFixtures.codeIntelShapeDrift.input & codeintel.normalizedMaterializedBundleShapeManifest
}
