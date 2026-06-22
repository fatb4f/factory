package assertions

#ReflectionProvenance: close({
	origin:          "reflection"
	reflector:       string & !=""
	sourceDigest:    string & =~"^sha256:[0-9a-f]{64}$"
	inventoryDigest: string & =~"^sha256:[0-9a-f]{64}$"
	materializedAt:  string & =~"^run:[0-9a-f]{16,64}$"
})

#ValidationProjection: close({
	path:              string & !=""
	kind:              "generated-executable-check" | "adapter-smoke-entrypoint"
	authority:         false
	assertionSurfaces: [string, ...string]
	generatedFrom:     string & !=""
	delegatesTo?:      string & !=""
})

#AdmittedAssertion: close({
	schema:              "factory.admitted-assertion.v1"
	id:                  string & !=""
	subject:             string & !=""
	invariant:           string & !=""
	assertionSurfaces:   [string, ...string]
	requiredValues:      [...string]
	validationPaths:     [string, ...string]
	fixturePaths:        [string, ...string]
	evidencePaths:       [string, ...string]
	contractExtensionID: string & !=""
	provenance:          #ReflectionProvenance
})

#ValidationAuthority: close({
	assertionRoot:  "contracts/factory/assertions"
	reflectionRoot: "contracts/factory/reflection"
	projections: [string]: #ValidationProjection
	assertions: [string]: #AdmittedAssertion
	for _, projection in projections {
		if projection.authority != false {
			_authoritativeProjection: _|_
		}
		if len(projection.assertionSurfaces) == 0 {
			_unbackedProjection: _|_
		}
	}
	for _, assertion in assertions {
		if assertion.provenance.origin != "reflection" {
			_manualAssertionInstance: _|_
		}
	}
})

#ValidationFixture: close({
	schema:      "factory.validation-fixture.v1"
	id:          string & !=""
	assertionID: string & !=""
	prompt:      string & !=""
	provenance:  #ReflectionProvenance
})

#ObservedPacketEvidence: close({
	schema:      "factory.observed-packet-evidence.v1"
	id:          string & !=""
	assertionID: string & !=""
	packetBytes: int & <50000
	packet:      _
	provenance:  #ReflectionProvenance
})

#AssertionResultProjection: close({
	schema:      "factory.assertion-results.v1"
	provenance:  #ReflectionProvenance
	results: [...close({
		id:          string & !=""
		assertionID: string & !=""
		status:      "pass" | "fail" | "blocked"
		evidence:    [string, ...string]
	})]
})

#MaterializationReport: close({
	schema:     "factory.materialization-report.v1"
	provenance: #ReflectionProvenance
	loop: [string, ...string]
	generated: close({
		assertions: [string, ...string]
		fixtures:   [string, ...string]
		checks:     [string, ...string]
		evidence:   [string, ...string]
	})
	inventory?:           _
	gaps?:                _
	materializationPlan?: _
})
