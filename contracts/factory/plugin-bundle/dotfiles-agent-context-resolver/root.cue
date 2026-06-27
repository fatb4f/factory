package dotfilespluginbundle

import "strings"

#NonEmptyString: string & !=""

#ContractCuemodInput: close({
	repo: "github.com/fatb4f/contract.cuemod"
	ref:  #NonEmptyString
	paths: [#NonEmptyString, ...#NonEmptyString]
	exports: [#NonEmptyString, ...#NonEmptyString]

	semanticsRedefined:           *false | bool
	externalContractCuemodLookup: *false | bool
})

#DotfilesTargetFile: close({
	path:      #NonEmptyString
	generated: true
	authority: false
	source:    "projection"
})

#ProjectionComponent: close({
	id:        #NonEmptyString
	path:      #NonEmptyString
	role:      "source" | "projection" | "generated-output" | "evidence" | "runtime"
	generated: *false | bool
	authority: bool
})

#ProviderReachabilityEvidence: close({
	kind:         "provider-reachability"
	authority:    false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#DotfilesPluginBundleProjection: {
	source: #ContractCuemodInput
	target: #DotfilesTarget
	components: [...#ProjectionComponent]
	generatedFiles: [...#DotfilesTargetFile]
	materialization: #DotfilesPluginMaterialization
	lock:            #BundleLockEvidence
	gates: [...#Gate]

	providerReachability?: #ProviderReachabilityEvidence

	codexAuthority:               *false | bool
	generatedAuthority:           *false | bool
	providerOutputIsAuthority:    *false | bool
	externalFactoryRootLookup:    *false | bool
	externalContractCuemodLookup: *false | bool
}

#ProjectionPredicates: {
	input: #DotfilesPluginBundleProjection

	codexAsAuthority:
		len([for c in input.components if c.authority && strings.HasPrefix(c.path, ".codex/") {c}]) > 0

	generatedAsAuthority:
		len([for c in input.components if c.authority && c.generated {c}]) > 0

	providerOutputAsAuthority:
		input.providerOutputIsAuthority ||
		(input.providerReachability != _|_ && input.providerReachability.authority)

	externalDependency:
		input.externalFactoryRootLookup ||
		input.externalContractCuemodLookup ||
		input.source.externalContractCuemodLookup

	materializationWithoutLock:
		input.materialization.provenance.lockID != input.lock.id
}

#AdmissibleDotfilesPluginBundleProjection: _candidate=(#DotfilesPluginBundleProjection & {
	_predicates: #ProjectionPredicates & {
		input: {
			source:          _candidate.source
			target:          _candidate.target
			components:      _candidate.components
			generatedFiles:  _candidate.generatedFiles
			materialization: _candidate.materialization
			lock:            _candidate.lock
			gates:           _candidate.gates

			if _candidate.providerReachability != _|_ {
				providerReachability: _candidate.providerReachability
			}

			codexAuthority:               _candidate.codexAuthority
			generatedAuthority:           _candidate.generatedAuthority
			providerOutputIsAuthority:    _candidate.providerOutputIsAuthority
			externalFactoryRootLookup:    _candidate.externalFactoryRootLookup
			externalContractCuemodLookup: _candidate.externalContractCuemodLookup
		}
	}

	if _predicates.codexAsAuthority || _candidate.codexAuthority {
		_codexAsAuthority: _|_
	}

	if _predicates.generatedAsAuthority || _candidate.generatedAuthority {
		_generatedAsAuthority: _|_
	}

	if _predicates.externalDependency {
		_externalDependency: _|_
	}

	if _predicates.providerOutputAsAuthority {
		_providerOutputAsAuthority: _|_
	}

	if _predicates.materializationWithoutLock {
		_materializationWithoutLock: _|_
	}
})
