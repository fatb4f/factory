package catalog

import (
	"list"

	upstream "github.com/fatb4f/factory/cue-skill/lattice/conformance/upstream"
)

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
	contextSourceDefines: {
		target: "#SourceReference"
		value: {artifact: "implementation-reference", locatorKind: "section", locator: "Evaluation", use: "defines"}
	}
	contextSourceConstrains: {
		target: "#SourceReference"
		value: {artifact: "implementation-reference", locatorKind: "section", locator: "Evaluation", use: "constrains"}
	}
	normativeSourceCorroborates: {
		target: "#SourceReference"
		value: {artifact: "language-specification", locatorKind: "section", locator: "Values", use: "corroborates"}
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

let completedBottomObservation = {
	protocol:       "cueprobe/v1"
	sourceRevision: upstream.authority.revision
	executionState: "completed"
	stages: {
		load:         "succeeded"
		lookup:       "succeeded"
		precondition: "succeeded"
		operation:    "succeeded"
	}
	semanticBottom: "observed-true"
}

negativeFixtureObservations: close({
	applicationVocabularyLeak: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "applicationVocabularyLeak"
		target:     negativeFixtures.applicationVocabularyLeak.target
	}
	unknownArtifactReference: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "unknownArtifactReference"
		target:     negativeFixtures.unknownArtifactReference.target
	}
	contextSourceDefines: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "contextSourceDefines"
		target:     negativeFixtures.contextSourceDefines.target
	}
	contextSourceConstrains: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "contextSourceConstrains"
		target:     negativeFixtures.contextSourceConstrains.target
	}
	normativeSourceCorroborates: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "normativeSourceCorroborates"
		target:     negativeFixtures.normativeSourceCorroborates.target
	}
	missingObservationMode: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "missingObservationMode"
		target:     negativeFixtures.missingObservationMode.target
	}
	movingAuthorityRevision: upstream.#NegativeFixtureObservation & completedBottomObservation & {
		fixtureKey: "movingAuthorityRevision"
		target:     negativeFixtures.movingAuthorityRevision.target
	}
})

negativeFixtureEvaluations: close({
	for fixtureKey, fixture in negativeFixtures {
		"\(fixtureKey)": (upstream.#NegativeFixtureEvaluation & {
			Fixture:     fixture
			Observation: negativeFixtureObservations[fixtureKey]
		}).Result
	}
})

negativeFixtureEvaluationComplete: list.SortStrings([for key, _ in negativeFixtures {key}]) ==
	list.SortStrings([for key, _ in negativeFixtureEvaluations {key}]) &&
	!list.Contains([for _, evaluation in negativeFixtureEvaluations {evaluation.satisfied}], false)

positiveFixtures: close({
	directionalSourceBound: catalog.concepts["directional-subsumption"].sources[0].artifact == "language-specification"
	apiSymbolBound:         catalog.concepts["directional-subsumption"].sources[1].locator == "cue.Value.Subsume"
	defaultLimitsExplicit:  len(catalog.concepts["marked-disjunction-defaults"].applicability.limits) > 0
	cliBoundaryExplicit:    catalog.concepts["structural-cli-gates"].applicability.scopes[0] == "tooling-boundary"
})

invariantFixtures: close({
	domainNeutral:              catalogComplete
	authorityRevisionPinned:    catalog.authorityRevision == upstream.authority.revision
	unificationNotSubsumption:  catalog.concepts["meet-unification"].applicability.limits[0] == "Successful unification establishes compatibility, not directional subsumption by itself."
	sourceClassesDistinguished: upstream.classBoundaryComplete
})

catalogFixtureSatisfaction: positiveFixtures.directionalSourceBound && positiveFixtures.apiSymbolBound &&
	positiveFixtures.defaultLimitsExplicit && positiveFixtures.cliBoundaryExplicit &&
	invariantFixtures.domainNeutral && invariantFixtures.authorityRevisionPinned &&
	invariantFixtures.unificationNotSubsumption && invariantFixtures.sourceClassesDistinguished &&
	negativeFixtureEvaluationComplete
