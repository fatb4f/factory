package catalog

import upstream "github.com/fatb4f/factory/cue-lattice-conformance/upstream"

// Raw negative inputs remain separate from their target schemas. Validation
// conjoins one selected value with its declared target and requires bottom.
negativeFixtures: close({
	applicationVocabularyLeak: {
		target: "#Concept"
		value: {
			id: "deployment-projection", term: "deployment projection", statement: "application-specific claim"
			relations: [], applicability: {scopes: ["plain-values"], limits: []}
			observationModes: ["specification-analysis"]
			sources: [{artifact: "language-specification", locatorKind: "section", locator: "Values", use: "defines"}]
			applicationVocabulary: true
		}
	}
	unknownArtifactReference: {
		target: "catalog.concepts[\"directional-subsumption\"].sources[0]"
		value: {artifact: "mutable-web-page", locatorKind: "section", locator: "Values", use: "defines"}
	}
	missingObservationMode: {
		target: "#Concept"
		value: {
			id: "directional-subsumption", term: "subsumption", statement: "directional relation"
			relations: ["specific ⊑ general"], applicability: {scopes: ["all-values"], limits: []}
			observationModes: [], sources: [{artifact: "language-specification", locatorKind: "section", locator: "Values", use: "defines"}]
			applicationVocabulary: false
		}
	}
	movingAuthorityRevision: {
		target: "catalog"
		value: {id: "cue-lattice-concept-catalog-v1", authorityID: upstream.authority.id, authorityRevision: "master", concepts: {}}
	}
})

positiveFixtures: close({
	directionalSourceBound: catalog.concepts["directional-subsumption"].sources[0].artifact == "language-specification"
	apiSymbolBound:          catalog.concepts["directional-subsumption"].sources[1].locator == "cue.Value.Subsume"
	defaultLimitsExplicit:   len(catalog.concepts["marked-disjunction-defaults"].applicability.limits) > 0
	cliBoundaryExplicit:     catalog.concepts["structural-cli-gates"].applicability.scopes[0] == "tooling-boundary"
})

invariantFixtures: close({
	domainNeutral:             catalogComplete
	authorityRevisionPinned:   catalog.authorityRevision == upstream.authority.revision
	unificationNotSubsumption: catalog.concepts["meet-unification"].applicability.limits[0] == "Successful unification establishes compatibility, not directional subsumption by itself."
	sourceClassesDistinguished: upstream.classBoundaryComplete
})

catalogFixtureSatisfaction: positiveFixtures.directionalSourceBound && positiveFixtures.apiSymbolBound &&
	positiveFixtures.defaultLimitsExplicit && positiveFixtures.cliBoundaryExplicit &&
	invariantFixtures.domainNeutral && invariantFixtures.authorityRevisionPinned &&
	invariantFixtures.unificationNotSubsumption && invariantFixtures.sourceClassesDistinguished
