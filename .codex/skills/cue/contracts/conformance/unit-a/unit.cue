package unita

import (
	"list"

	kernel "github.com/fatb4f/factory/cue-skill/kernel"
	kernelfixture "github.com/fatb4f/factory/cue-skill/fixtures/kernel:kernelfixture"
)

#Scenario: "positive" | "negative" | "invariant" | "compatibility" | "adversarial"
#Requirement: close({
	id: string
	dependsOn: [...string]
	scenarios: {[#Scenario]: true}
	order: int & >=0
})

requirements: close({
	"SK-01": {id: "SK-01-A1", dependsOn: [], scenarios: {positive: true, invariant: true}, order: 0}
	"SK-02": {id: "SK-02-A1", dependsOn: ["SK-01"], scenarios: {positive: true, negative: true, invariant: true}, order: 1}
	"KR-01": {id: "KR-01-A1", dependsOn: ["SK-02"], scenarios: {positive: true, negative: true, compatibility: true}, order: 2}
	"KR-02": {id: "KR-02-A1", dependsOn: ["KR-01"], scenarios: {positive: true, negative: true}, order: 3}
	"KR-03": {id: "KR-03-A1", dependsOn: ["KR-02"], scenarios: {positive: true, negative: true, adversarial: true}, order: 4}
	"KR-04": {id: "KR-04-A1", dependsOn: ["KR-03"], scenarios: {positive: true, negative: true, adversarial: true}, order: 5}
	"KR-05": {id: "KR-05-A1", dependsOn: ["KR-03"], scenarios: {positive: true, negative: true, adversarial: true, compatibility: true}, order: 6}
})

evidence: close({
	"SK-01-A1": {positive: "skill-root", invariant: "module-version"}
	"SK-02-A1": {positive: "contract-authority", negative: "prose-non-authority", invariant: "package-boundary"}
	"KR-01-A1": {positive: "kernel-reference", negative: "invalid-ingress", compatibility: "source-kernel-diff"}
	"KR-02-A1": {positive: "kernel-vocabulary", negative: "closed-key-guards"}
	"KR-03-A1": {positive: "constructed-state", negative: "invalid-references", adversarial: "wrong-create-role"}
	"KR-04-A1": {positive: "exact-key-compatibility", negative: "added-state-key", adversarial: "widened-operation-reference"}
	"KR-05-A1": {positive: "independent-operands", negative: "destructive-bottom", adversarial: "selected-proof", compatibility: "legacy-invalid-field"}
})

selectedIDs: list.SortStrings([for id, _ in requirements {id}])
_dependencyProof: {
	for id, requirement in requirements {
		for dependency in requirement.dependsOn {
			"\(id)-depends-on-\(dependency)": list.Contains(selectedIDs, dependency) & true
			"\(dependency)-before-\(id)":     (requirements[dependency].order < requirement.order) & true
		}
	}
}
_coverageProof: {
	for _, requirement in requirements {
		for scenario, _ in requirement.scenarios {
			"\(requirement.id)-\(scenario)": evidence[requirement.id][scenario] & string
		}
	}
}

// Explicit bindings prove that Unit A consumes the exported kernel rather than
// a reconstructed kernel-shaped schema.
kernelBindings: {
	nonEmpty:    kernel.#NonEmptyString & "unit-a"
	kebab:       kernel.#KebabIdentifier & "unit-a"
	selector:    kernel.#CueSelectorExpr & "#ClosedObligationState.resources"
	closedState: kernel.#ClosedObligationState & kernelfixture.referenceState
	stateKeys: kernel.#StateKeySet & {state: kernelfixture.referenceState}
	operationKeys: kernel.#OperationRefKeySet & {operation: kernelfixture.referenceState.operations.build}
	exactKeyCompatibility: kernel.#ExactKeyCompatibilityProof & {authority: kernelfixture.referenceState, target: kernelfixture.referenceState}
}

closureComplete:      len(_dependencyProof) == 12
coverageComplete:     len(_coverageProof) == 20
contractSatisfaction: closureComplete && coverageComplete && kernelfixture.kernelSatisfaction

// Application-pattern alignment is deliberately outside Unit A. The revised
// upstream-alignment slice makes those patterns consumers of a runner-backed
// lattice-conformance layer, so their catalog cannot admit the kernel. Keep the
// bootstrap contract result distinct from semantic admission until those
// prerequisites produce admitted observations.
upstreamAlignment: close({
	status: "provisional"
	blockedBy: [
		"lattice-conformance-contracts",
		"runner-backed-directional-subsumption",
		"runner-backed-destructive-probes",
	]
})

unitSatisfaction: contractSatisfaction && upstreamAlignment.status == "admitted"
