package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

analyticsSource: state.#AnalyticalSourceRef & {
	id:             "industrial-project-trajectories"
	snapshotDigest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	semanticRef: {
		authority: {
			id:       "world.industrial-signals"
			contract: "contracts/world/industrial-signals/contract.cue"
		}
		subject: "world.industrial-signals"
		kind:    "graph"
	}
	provenance: ["industrial-snapshot:fixture-v1"]
	admissibility: {
		state:     "admitted"
		authority: "contracts/world/industrial-signals/contract.cue"
		basis:     ["industrial-snapshot:fixture-v1"]
	}
}

analyticsRequest: state.#AnalyticalRequest & {
	apiVersion: "factory.analytics-ir/v1"
	kind:       "AnalyticalRequest"
	id:         "funding-trajectory"
	source:     analyticsSource
	grain: {
		keys: ["project_id", "stage", "observed_at"]
		unit: "funding-stage-observation"
	}
	operations: [{
		kind: "group"
		keys: ["project_id", "stage"]
	}, {
		kind: "aggregate"
		measures: [{id: "amount_total", op: "sum", field: "amount"}]
	}, {
		kind: "grain-change"
		output: {
			keys: ["project_id", "stage"]
			unit: "project-funding-stage"
		}
	}, {
		kind: "order"
		by: [{field: "project_id", direction: "asc"}, {field: "stage", direction: "asc"}]
	}, {
		kind: "derive"
		expressions: [{id: "stage_share", expression: "amount_total / project_total", basis: ["amount_total", "project_total"]}]
	}]
}

relationalPlan: state.#RelationalPlan & {
	apiVersion: "factory.analytics-ir/v1"
	kind:       "RelationalPlan"
	id:         "plan:funding-trajectory"
	request:    analyticsRequest
	steps:      analyticsRequest.operations
	outputGrain: {
		keys: ["project_id", "stage"]
		unit: "project-funding-stage"
	}
	provenance: {
		authority: "contracts/state/analytics-ir.cue"
		basis: [
			analyticsRequest.source.snapshotDigest,
			analyticsRequest.source.admissibility.authority,
		]
	}
}

ibisTarget: state.#ExecutionTargetCapability & {
	id:                "ibis"
	capabilityVersion: "fixture-v1"
	transport:         "dataframe"
	supportedOperations: [
		"project", "filter", "join", "group", "aggregate", "grain-change", "order", "window", "derive",
	]
}

substraitTarget: state.#ExecutionTargetCapability & {
	id:                "substrait"
	capabilityVersion: "fixture-v1"
	transport:         "logical-plan"
	supportedOperations: [
		"project", "filter", "join", "group", "aggregate", "grain-change", "order", "window", "derive",
	]
}

limitedTarget: state.#ExecutionTargetCapability & {
	id:                  "limited-fixture"
	capabilityVersion:   "fixture-v1"
	transport:           "sql"
	supportedOperations: ["project", "filter"]
}

windowGap: state.#AnalyticsCapabilityGap & {
	kind:      "capability-gap"
	request:   analyticsRequest.id
	target:    limitedTarget.id
	operation: "window"
	reason:    "The fixture target does not declare window capability."
}
