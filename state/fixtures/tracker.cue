package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

engineeringIssue: state.#EngineeringWorkIssue & {
	apiVersion: "factory.tracker/v1"
	kind:       "EngineeringWorkIssue"
	origin:     "engineering-intent"
	entity: {
		kind: "substrate"
		id:   "factory.analytics-ir"
	}
	work: {
		class: "schema"
		slug:  "define-relational-plan"
	}
	state:     "ready"
	priority:  "p1"
	objective: "Define a backend-neutral relational plan boundary below Factory semantic authority."
	authority: [{
		path: "contracts/state/tracker.cue"
		role: "semantic"
	}]
	acceptance: [{
		id:        "contracted-plan"
		statement: "A closed plan contract exists and can project to replaceable execution adapters."
		state:     "pending"
	}]
}

engineeringProjection: state.#GitHubIssueProjection & {
	issue: engineeringIssue
	title: "[substrate] Define Factory analytical IR boundary"
}

evidenceIssue: state.#EvidenceDerivedIssue & {
	apiVersion: "factory.tracker/v1"
	kind:       "EvidenceDerivedIssue"
	origin:     "evidence-derived"
	entity: {
		kind: "profile"
		id:   "upstream-monitor.ctrl"
	}
	issue_class: "qualification-regression"
	slug:        "runtime-compatibility"
	state:       "actionable"
	priority:    "p1"
	runs: [{
		kind: "run"
		ref:  "projects/ctrl/upstream-monitor/runs/20260905T120000Z"
	}]
	evidence: [{
		kind: "evidence"
		ref:  "projects/ctrl/upstream-monitor/runs/20260905T120000Z/evidence.json"
	}]
	admission: {
		authority: "contracts/workers/upstream-monitor/profiles_ctrl/contract.cue"
		decision:  "Profile qualification admitted the regression."
	}
}
