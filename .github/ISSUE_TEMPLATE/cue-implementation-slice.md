---
name: CUE constructor manifest slice
about: Implement a bounded CUE slice from repo-local constructor calls.
title: "cue: "
labels: cue, contract, implementation
---

```cue
import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

// Fill this manifest with compact constructor calls only.
// Do not inline constructor definitions.
// Do not invent alternate constructor shapes.
// Do not encode CUE expressions as strings.
// Keep negative checks as real intersections in a loaded check/test surface.

_issue: {
	tracking: {
		parent?:    int | string
		dependsOn?: [...int | string]
		blocks?:    [...int | string]
	}

	goal: {
		implement: [...string & !=""] & [_, ...]
		doNotImplement: [...string & !=""] | *[
			"Go wrapper",
			"MCP exposure",
			"GitHub mutation controller",
			"shell-only semantic validation",
		]
	}

	target: {
		contractPath: string & !="" // example: "contracts/<name>"
		package:      string & !=""
		checkFile:    string | *""  // example: "./checks_test.cue" when needed
	}
}

_constructorAuthority: impl.constructorCatalog & {
	package: "impl"
	root:    "contracts/meta/impl"
	invariants: [
		"Constructor definitions live in the repo-local impl package.",
		"Issue manifests carry constructor calls, not constructor bodies.",
		"CUE expressions remain CUE values, not stringified expression metadata.",
		"Negative checks are generated as intersections, not invalidity flags.",
		"Go wrappers are deferred to transport and materialization.",
	]
}

_constructorWorkflow: [
	{
		order: 1
		id: "#MakePrimitive"
		constructor: impl.#MakePrimitive
		instantiateAt: "_primitives"
		requirements: [
			"Declare each primitive that Codex must materialize.",
			"Give each primitive a role, required field list, and constraints.",
		]
		invariants: [
			"Primitive descriptions are metadata contracts, not implementation bodies.",
			"Closed primitives remain closed unless explicitly relaxed.",
		]
		constraints: [
			"Do not duplicate primitive prose outside this constructor call.",
		]
	},
	{
		order: 2
		id: "#MakeSurfaceSet"
		constructor: impl.#MakeSurfaceSet
		instantiateAt: "_surfaces"
		requirements: [
			"Declare admissible, observed, candidate, fixture, check, and public export surfaces.",
			"Include every surface needed by validation and completion reporting.",
		]
		invariants: [
			"Observed surfaces may contain invalid facts.",
			"Admissible surfaces reject invalid values structurally.",
			"Candidate surfaces are gates, not review notes.",
		]
		constraints: [
			"Do not omit fixtures, checks, or public exports when the slice needs them.",
		]
	},
	{
		order: 3
		id: "#MakeNegativeFixture"
		constructor: impl.#MakeNegativeFixture
		instantiateAt: "_negativeFixtures"
		requirements: [
			"Declare invalid observed inputs that must be rejected.",
			"State the violated boundary and expected refusal.",
		]
		invariants: [
			"Negative fixtures are first-class evidence for rejection.",
			"expectedBottom means structural failure, not a truth flag.",
		]
		constraints: [
			"Do not use isInvalid: true.",
			"Do not replace structural conflict with metadata assertions.",
		]
	},
	{
		order: 4
		id: "#MakeBottomCheck"
		constructor: impl.#MakeBottomCheck
		instantiateAt: "_bottomCheckConstructors and _negativeBottomChecks"
		requirements: [
			"Create a bottom-check constructor per negative fixture.",
			"Expose _negativeBottomChecks in a loaded check/test surface.",
		]
		invariants: [
			"Negative checks are real CUE intersections.",
			"A valid negative check fails by conflict/bottom, not undefined selector.",
		]
		constraints: [
			"Do not encode intersection expressions as strings.",
			"Do not hide _negativeBottomChecks behind defaults or disjunctions.",
		]
	},
	{
		order: 5
		id: "#MakeValidationPlan"
		constructor: impl.#MakeValidationPlan
		instantiateAt: "_validation"
		requirements: [
			"Generate cue vet, public export, negative bottom, and forbidden-pattern commands.",
			"Use checkFile when negative checks live outside the normal package surface.",
		]
		invariants: [
			"Normal package cue vet remains clean.",
			"Negative exports must load the check/test surface explicitly when required.",
		]
		constraints: [
			"Do not use shell-only validation as semantic authority.",
		]
	},
	{
		order: 6
		id: "#MakeCompletionReport"
		constructor: impl.#MakeCompletionReport
		instantiateAt: "_completion"
		requirements: [
			"Constrain Codex final output into deterministic review evidence.",
			"List files, primitives, surfaces, fixtures, checks, commands, and final result.",
		]
		invariants: [
			"Completion report shape is part of the contract.",
			"Commands run are review evidence, not authority by themselves.",
		]
		constraints: [
			"Do not omit failed or skipped commands.",
		]
	},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#<PrimitiveName>"
			role: "<bounded role>"
			requiredFields: ["<field>"]
			constraints: [
				"<primitive invariant>",
			]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#<AdmissibleSurface>"]
		observed: ["#<ObservedSurface>"]
		candidates: ["#<CandidateSurface>"]
		fixtures: ["validBaseline", "negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["publicContract"]
	}
}

_negativeFixtures: {
	<fixtureName>: impl.#MakeNegativeFixture & {
		in: {
			name: "<fixtureName>"
			violates: "<authority or structural boundary>"
			refusal: "<expected refusal reason>"
			input: {
				// invalid observed input goes here
			}
		}
	}
}

_bottomCheckConstructors: {
	<fixtureName>: impl.#MakeBottomCheck & {
		in: {
			name: "<fixtureName>"
			input: _negativeFixtures.<fixtureName>.out.input
			target: #<AdmissibleOrCandidateSurface>
		}
	}
}

// Place this in the check/test surface when the normal package must remain cue-vet clean.
_negativeBottomChecks: {
	for k, v in _bottomCheckConstructors {
		"\(k)": v.out[k]
	}
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: _issue.target.contractPath
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["<fixtureName>"]
		checkFile: _issue.target.checkFile
		forbiddenPattern: "truthFlag|operatorSupplied|bottomCheckSurface|expression:|isInvalid: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for p in _primitives {p.out.name}]
		surfaces: _surfaces.out.admissible + _surfaces.out.observed + _surfaces.out.candidates + _surfaces.out.publicExports
		fixtures: [for _, f in _negativeFixtures {f.out.id}]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
	}
}

normalizedIssueManifest: {
	issue: _issue
	authority: _constructorAuthority
	workflow: _constructorWorkflow
	primitives: [for p in _primitives {p.out}]
	surfaces: _surfaces.out
	negativeFixtures: {for k, f in _negativeFixtures {"\(k)": f.out}}
	validationPlan: _validation.out
	completionReportContract: _completion.out
}
```
