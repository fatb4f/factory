package qualification

import domain "github.com/fatb4f/factory/contracts/world/industrial-constraints:industrialconstraints"

// This fixture binds the synthetic qualification package to the canonical
// relation-state path used to reach admitted constraint intelligence.
qualificationProjectionPath: close({
	graphIntegrity: domain.projectionGraphIntegrity

	relationalAdmission: domain.projections["admit-relational-state"] & {
		purpose: "admission"
		outputs: [
			{relation: "documents", state: "admitted"},
			{relation: "entities", state: "admitted"},
			{relation: "observations", state: "admitted"},
			{relation: "events", state: "admitted"},
			{relation: "measurements", state: "admitted"},
			{relation: "relations", state: "admitted"},
		]
	}

	constraintEvidence: domain.projections["project-supply-pressure"] & {
		purpose: "constraint-evidence"
		outputs: [{relation: "constraint-evidence", state: "derived"}]
	}

	claims: domain.projections["derive-constraint-claims"] & {
		purpose: "claim"
		inputs: [{kind: "relation", relation: "constraint-evidence", state: "derived"}]
		outputs: [{relation: "claims", state: "derived"}]
	}

	assessments: domain.projections["assess-constraint-claims"] & {
		purpose: "assessment"
		inputs: [{kind: "relation", relation: "claims", state: "derived"}]
		outputs: [{relation: "assessments", state: "derived"}]
	}

	constraints: domain.projections["derive-constraints"] & {
		purpose: "constraint"
		inputs: [
			{kind: "relation", relation: "claims", state: "derived"},
			{kind: "relation", relation: "assessments", state: "derived"},
		]
		outputs: [{relation: "constraints", state: "derived"}]
	}

	constraintAdmission: domain.projections["admit-qualified-constraints"] & {
		purpose: "admission"
		outputs: [
			{relation: "claims", state: "admitted"},
			{relation: "assessments", state: "admitted"},
			{relation: "constraints", state: "admitted"},
		]
	}

	responseCorrelation: domain.projections["project-funding-response"] & {
		purpose: "correlation"
		inputs: [
			{kind: "relation", relation: "constraints", state: "admitted"},
			{kind: "relation", relation: "events", state: "admitted"},
			{kind: "relation", relation: "relations", state: "admitted"},
		]
	}
})
