// Opsec — root operational contract, version 0.1.0.
//
// Authority: the eight-step loop in OPSEC CA 001, v1.0, section 4.
// Purpose: expand an inspectable manual process before automating its execution.
// Shape: operation -> phase -> procedure branch -> manual activity leaf.
// Branch/leaf maps are extension points; the eight phases are fixed.
//
// Validate: cue vet -c opsec_operational_root.cue
// Inspect:  cue export opsec_operational_root.cue -e operation
// Expand:   add a same-package phase file, then validate/export both files.
// Tested with CUE v0.16.1. Standard-library imports only.
//
// This contract describes procedures. It grants no operational authority and
// does not execute tools, validate environmental truth, or attest readiness.
// Structural checks are native CUE constraints; prose rules require application
// by the operator and, if later implemented, the executor. Input/output lists
// declare relevant record kinds, not proof of production or a requirement that
// every kind already exists on the first cycle. Leaf prerequisites name the
// records and other conditions actually required for that activity.
package opsec

import "list"

#ID:   string & =~"^[a-z][a-z0-9_]*$"
#Text: string & =~"\\S"

#RecordKind: "policy" | "observation" | "coverage" | "assessment" | "decision" | "outcome"
#RecordKinds: [...#RecordKind] & list.UniqueItems()
#PhaseID: "frame" | "observe" | "reconcile_quality" | "model" | "discriminate" | "update" | "select" | "reconcile_outcome"
#PhaseOrder: ["frame", "observe", "reconcile_quality", "model", "discriminate", "update", "select", "reconcile_outcome"]

// An unresolved detail remains concrete, inspectable data. No empty success.
#Detail: {
	state:    "pending"
	question: #Text
} | {
	state: "specified"
	value: #Text
} | {
	state:  "not_applicable"
	reason: #Text
}

// Mapping intent is distinct from evidence that the referenced behavior occurred.
// ATT&CK's legacy DS objects are intentionally excluded from new references.
// Source: https://mitre-attack.github.io/attack-data-model/docs/principles/attack-detections/
#FrameworkRef: {
	framework:  "ATT&CK" | "D3FEND" | "CAR"
	object_id:  #Text
	relation:   "behavior_hypothesis" | "analysis_method" | "evidence_requirement" | "analytic_reference" | "context"
	source_url: string & =~"^https://[^[:space:]]+$"
	version: #Detail & {state: "pending" | "specified"}
	rationale: #Text
	review:    *"candidate" | "reviewed"
	if framework == "ATT&CK" {
		object_id: =~"^(T[0-9]{4}(\\.[0-9]{3})?|TA[0-9]{4}|DET[0-9]{4}|AN[0-9]{4}|DC[0-9]{4})$"
	}
	if framework == "D3FEND" {
		object_id: =~"^D3-[A-Z0-9]+$"
	}
	if framework == "CAR" {
		object_id: =~"^CAR-[0-9]{4}-[0-9]{2}-[0-9]{3}$"
	}
	if review == "reviewed" {
		version: {state: "specified"}
	}
}

#Technique: {
	name: #Text
	kind: "collection" | "analysis" | "comparison" | "validation" | "recording" | "decision"
	framework_refs: *[] | [...#FrameworkRef]
}

#ToolUse: {
	name:          #Text
	role:          "capture" | "inspect" | "analyze" | "record" | "validate"
	version:       #Detail
	configuration: #Detail
	prerequisites: *[] | [...#Text]
	expected_artifact: #Text
}

// Procedure documentation and actual evaluation are separate claims.
#Evaluation: {
	status: *"not_evaluated" | "manually_exercised" | "demonstrated"
	evidence_refs: *[] | [#Text, ...#Text]
	conditions: #Detail
	result:     *"not_evaluated" | "met" | "not_met" | "inconclusive"
	if status == "not_evaluated" {
		result: "not_evaluated"
	}
	if status != "not_evaluated" {
		evidence_refs: [#Text, ...#Text]
		conditions: {state: "specified"}
		result: "met" | "not_met" | "inconclusive"
	}
	if status == "demonstrated" {
		result: "met"
	}
}

#Process: {
	state:       "pending"
	next_detail: #Text
} | {
	state: "documented"
	manual_steps: [#Text, ...#Text]
}

#FailurePath: {
	condition: #Text
	response:  #Text
	// This is a prescribed response; actual decisions belong in Decision records.
	disposition: "continue" | "adapt" | "hold" | "end" | "reassess"
}

// A leaf is one manual activity. Its internal steps execute in list order.
// A leaf cannot contain children or declare its own authority/automation mode.
#Leaf: {
	id:        #ID
	kind:      "manual_activity"
	objective: #Text
	process:   #Process
	inputs:    #RecordKinds
	outputs: #RecordKinds & [#RecordKind, ...#RecordKind]
	prerequisites: *[] | [...#Text]
	tools: *[] | [...#ToolUse]
	techniques: *[] | [...#Technique]
	expected_effects:   #Detail
	observation_window: #Detail
	completion_criteria: [#Text, ...#Text]
	failure_paths: [#FailurePath, ...#FailurePath]
	additional_requirements: *[] | [...#Text]
	unknowns: *[] | [...#Text]
	evaluation: #Evaluation
	if evaluation.status != "not_evaluated" {
		process: {state: "documented"}
	}
	if evaluation.status == "demonstrated" {
		// A demonstration is limited to the recorded conditions. Resolve its
		// prediction, timing, and tool profile before making even that claim.
		expected_effects: {state: "specified" | "not_applicable"}
		observation_window: {state: "specified" | "not_applicable"}
		tools: [...{
			version: {state: "specified" | "not_applicable"}
			configuration: {state: "specified" | "not_applicable"}
		}]
	}
}

// Branches group related activities. Array order is explicit, never map order.
#Branch: {
	id:        #ID
	kind:      "procedure_branch"
	objective: #Text
	status:    *"pending" | "documented"
	additional_requirements: *[] | [...#Text]
	framework_refs: *[] | [...#FrameworkRef]
	leaf_order: *[] | ([...#ID] & list.UniqueItems())
	leaves: {
		[K=#ID]: #Leaf & {id: K}
	}
	let Keys = [for k, _ in leaves {k}]
	_order_count: true & (len(leaf_order) == len(Keys))
	_order_refs: [for k in leaf_order {true & list.Contains(Keys, k)}]
	if status == "documented" {
		leaf_order: [#ID, ...#ID]
		leaves: [#ID]: {process: {state: "documented"}}
	}
}

#Phase: {
	id:        #PhaseID
	kind:      "phase"
	ordinal:   int & >=1 & <=8
	title:     #Text
	objective: #Text
	inputs:    #RecordKinds
	outputs: #RecordKinds & [#RecordKind, ...#RecordKind]
	manual_process: [#Text, ...#Text]
	exit_criteria: [#Text, ...#Text]
	additional_requirements: *[] | [...#Text]
	branch_order: *[] | ([...#ID] & list.UniqueItems())
	branches: {
		[K=#ID]: #Branch & {id: K}
	}
	let Keys = [for k, _ in branches {k}]
	_order_count: true & (len(branch_order) == len(Keys))
	_order_refs: [for k in branch_order {true & list.Contains(Keys, k)}]
}

#OperationalRoot: {
	contract_id:      "opsec.operational.root"
	schema_version:   "opsec.operational/v1"
	contract_version: "0.1.0"
	status:           "draft"
	purpose:          #Text
	basis: {
		document: "OPSEC CA 001"
		version:  "1.0"
		section:  "4 — Execute the continuous loop"
	}
	execution: {
		mode:              "manual"
		automated_actions: false
		authority_source:  "engagement-policy"
		grants_authority:  false
		policy_binding: #Detail & {state: "pending" | "specified"}
	}
	// These requirements apply to every phase, branch, and leaf. Additional
	// requirements accumulate down the containment path; they cannot override
	// these root rules. Lists are not merged by CUE list unification.
	rules: {
		unknown_is_not_absent:                        true
		coverage_accompanies_observation:             true
		shared_lineage_is_not_independence:           true
		preserve_conflicting_evidence:                true
		separate_capability_activity_identity_intent: true
		prediction_precedes_check:                    true
		reconcile_expected_and_actual:                true
		framework_mapping_is_not_proof:               true
		schema_validity_is_not_readiness:             true
		authority_cannot_expand_in_tree:              true
		inherited_requirements_accumulate:            true
	}
	canonical_record_kinds: ["policy", "observation", "coverage", "assessment", "decision", "outcome"]
	phase_order: #PhaseOrder
	phases: {
		[#PhaseID]: #Phase
		for i, phase_id in #PhaseOrder {
			"\(phase_id)": {id: phase_id, ordinal: i + 1}
		}
	}
}

operation: #OperationalRoot & {
	purpose: "Expand continuous awareness into manual procedures, techniques, tools, and evidence requirements, one phase at a time."
	basis: {}
	execution: policy_binding: *{
		state:    "pending"
		question: "Which versioned engagement policy governs this particular use?"
	} | (#Detail & {state: "pending" | "specified"})
	phases: {
		frame: {
			title:     "Frame the next decision"
			objective: "Identify the decision, its assumptions, and the evidence that could change it."
			inputs: ["policy", "assessment", "outcome"]
			outputs: ["assessment"]
			manual_process: [
				"Name the activity, relevant assets, question, and available choices.",
				"Identify the unsupported assumption that could change the next action.",
				"Select the applicable observation procedure within the existing policy.",
			]
			exit_criteria: ["A specific decision question, its scope, and required evidence are recorded."]
		}
		observe: {
			title:     "Observe relevant deltas"
			objective: "Acquire decision-relevant observations and preserve their collection context."
			inputs: ["policy", "assessment", "coverage"]
			outputs: ["observation", "coverage"]
			manual_process: [
				"Select the source and tool; record configuration, interval, filters, and expected artifacts.",
				"Perform the permitted capture or export and retain its original evidence reference.",
				"Describe relevant changes, source lineage, timing, and measurement limits.",
			]
			exit_criteria: ["Observations have provenance and coverage context, or collection failure is explicit."]
		}
		reconcile_quality: {
			title:     "Reconcile data quality"
			objective: "Determine what the collected evidence can support."
			inputs: ["observation", "coverage", "decision"]
			outputs: ["coverage", "assessment"]
			manual_process: [
				"Check health, event and receipt times, expected delay, gaps, filters, and capture limits.",
				"Identify duplicate events and shared source lineage.",
				"Identify effects of our own tests and retain unexplained effects.",
			]
			exit_criteria: ["Evidence usability, dependencies, and unresolved measurement problems are explicit."]
		}
		model: {
			title:     "Model competing explanations"
			objective: "Explain observations while retaining material alternatives and unknowns."
			inputs: ["observation", "coverage", "assessment", "outcome"]
			outputs: ["assessment"]
			manual_process: [
				"State the narrow claim and supporting and contrary evidence.",
				"Consider ordinary change, authorized activity, our own effects, and measurement failure.",
				"State a distinguishing prediction or explain why available evidence cannot distinguish the alternatives.",
			]
			exit_criteria: ["The assessment includes alternatives, unknowns, and what could change the judgment."]
		}
		discriminate: {
			title:     "Select a discriminating check"
			objective: "Reduce consequential uncertainty with a permitted, bounded check."
			inputs: ["policy", "assessment", "coverage"]
			outputs: ["decision", "observation", "outcome"]
			manual_process: [
				"Prefer existing authoritative evidence where it can answer the question.",
				"Before a check, record predictions, prerequisites, observation window, effects, stop conditions, and restoration.",
				"Perform the selected manual check within policy, or record why no useful check is available.",
			]
			exit_criteria: ["The check and result are recorded, including missing, delayed, contradictory, or inconclusive results."]
		}
		update: {
			title:     "Update the claims"
			objective: "Revise only claims supported by the new evidence and its limitations."
			inputs: ["observation", "coverage", "assessment", "outcome"]
			outputs: ["assessment"]
			manual_process: [
				"Revise affected claim status, freshness, confidence rationale, and evidence references.",
				"Keep presence, access, capability, activity, identity, and intent distinguishable.",
				"Preserve contradictions and explain the reason for each material change.",
			]
			exit_criteria: ["The revised assessment records both the evidence-supported change and remaining uncertainty."]
		}
		select: {
			title:     "Select the next action"
			objective: "Choose what happens to the defined activity under its existing constraints."
			inputs: ["policy", "assessment", "coverage"]
			outputs: ["decision"]
			manual_process: [
				"Check applicable prerequisites and operating bounds.",
				"Record continue, adapt, hold, or end for the affected action.",
				"Assign the owner, expected effect, rationale, and review or hold-release conditions.",
			]
			exit_criteria: ["A decision can be followed and evaluated; unresolved holds have explicit release conditions."]
		}
		reconcile_outcome: {
			title:     "Reconcile the action outcome"
			objective: "Compare actual effects with predictions and establish the next review."
			inputs: ["decision", "observation", "coverage", "assessment"]
			outputs: ["outcome", "assessment", "coverage"]
			manual_process: [
				"Compare expected and actual effects, preserving incomplete or contradictory outcomes.",
				"Account for temporary changes, restoration, residual effects, and outstanding work.",
				"Update affected assumptions and record the next review trigger and owner.",
			]
			exit_criteria: ["An outcome, remaining uncertainty, and next review trigger close the cycle."]
		}
	}
}

// Expansion pattern: put the following in a new file with `package opsec`.
// Each parent has ONE owning order list. When adding a sibling, edit that list
// to contain all child IDs; other files may contribute the child maps. CUE list
// unification is positional: two different concrete order lists do not append.
// Revise a pending leaf in its owning file when its details become known;
// unification cannot replace a concrete pending state with a documented state.
// The root policy binding is a default so an engagement file can specify it.
// Keep root phases in this order. The next cycle returns to frame; runtime
// transitions and emergency interruptions are outside this procedure schema.
//
// operation: phases: observe: {
//   branch_order: ["wireless_observation"]
//   branches: wireless_observation: {
//     objective: "Establish the selected wireless observation path."
//     leaf_order: ["capture_known_change"]
//     leaves: capture_known_change: {
//       objective: "Observe an expected change involving a known lab device."
//       process: {
//         state: "pending"
//         next_detail: "Walk through the hardware, configuration, capture, and review steps."
//       }
//       inputs: ["policy", "assessment"]
//       outputs: ["observation", "coverage"]
//       tools: [{
//         name: "Kismet"
//         role: "capture"
//         version: {state: "pending", question: "Which installed version?"}
//         configuration: {state: "pending", question: "Which receiver, datasource, and settings?"}
//         expected_artifact: "Original .kismet capture and datasource context."
//       }]
//       expected_effects: {state: "pending", question: "Which benign lab change and expected observation?"}
//       observation_window: {state: "pending", question: "Which capture interval and expected delay?"}
//       completion_criteria: ["The expected observation is referenced or the coverage limitation is explicit."]
//       failure_paths: [{
//         condition: "The expected observation is missing."
//         response: "Check coverage and timing; retain an unresolved assessment."
//         disposition: "reassess"
//       }]
//       evaluation: {
//         conditions: {state: "pending", question: "Which conditions will the manual walkthrough exercise?"}
//       }
//     }
//   }
// }
