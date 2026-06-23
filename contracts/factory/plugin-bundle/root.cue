package pluginbundle

import "strings"

#NonEmptyString: string & !=""

#AuthorityPolicy: {
	generatedIsAuthority:    false
	materializedIsAuthority: false
}

#Metadata: {
	id:        #NonEmptyString
	name:      #NonEmptyString
	version:   #NonEmptyString
	stability: "experimental" | "stable"
}

#ExportRef: {
	id:     #NonEmptyString
	target: #NonEmptyString
}

#PluginBundle: {
	apiVersion: "contract.cuemod/plugin-bundle/v0"
	kind:       "PluginBundle"

	metadata:  #Metadata
	authority: #AuthorityPolicy

	components:       [...#Component]
	projections:      [...#Projection]
	materializations: [...#Materialization]
	gates:            [...#Gate]
	exports:          [#NonEmptyString]: #ExportRef
}

#ObservedBundleFile: close({
	path:         #NonEmptyString
	source:       "bundle" | "generated" | "materialized" | "external"
	authority?:   bool
	componentID?: #NonEmptyString
})

#ObservedMaterializedFile: close({
	path:             #NonEmptyString
	sourceProjection: #NonEmptyString
	hash?:            #NonEmptyString
	authority?:       bool
})

#PluginBundlePredicates: {
	input: #PluginBundle

	codexAsAuthority:
		len([for c in input.components if c.role == "authority" && strings.HasPrefix(c.path, ".codex/") {c}]) > 0

	generatedAsAuthority:
		len([for c in input.components if c.role == "authority" && c.generated {c}]) > 0

	materializationWithoutProjection:
		len([for m in input.materializations if len([for p in input.projections if p.id == m.sourceProjection {p}]) == 0 {m}]) > 0

	componentDependencyMissing:
		len([for c in input.components for dep in c.dependsOn if len([for target in input.components if target.id == dep {target}]) == 0 {dep}]) > 0
}

#AdmissiblePluginBundle: _candidate=close(#PluginBundle & {
	authority: #AuthorityPolicy

	_predicates: #PluginBundlePredicates & {
		input: {
			apiVersion:        _candidate.apiVersion
			kind:              _candidate.kind
			metadata:          _candidate.metadata
			authority:         _candidate.authority
			components:        _candidate.components
			projections:       _candidate.projections
			materializations:  _candidate.materializations
			gates:             _candidate.gates
			exports:           _candidate.exports
		}
	}

	if _predicates.codexAsAuthority {
		_codexAsAuthority: _|_
	}

	if _predicates.generatedAsAuthority {
		_generatedAsAuthority: _|_
	}

	if _predicates.materializationWithoutProjection {
		_materializationWithoutProjection: _|_
	}

	if _predicates.componentDependencyMissing {
		_componentDependencyMissing: _|_
	}
})
