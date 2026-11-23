// First implementation of a root phase. Array order is the manual procedure order.
package opsec

// Installed versions and run evidence are supplied during a walkthrough.
let installedTool = {
	name:    #Text
	version: *{state: "pending", question: "Which installed version of \(name) was used?"} | {state: "specified", value: #Text}
}
let manualActivity = {
	evaluation: conditions: *{state: "pending", question: "Under which recorded conditions was this activity exercised?"} | {state: "specified", value: #Text}
	process: state:         "documented"
}

operation: phases: observe: {
	branch_order: ["wireless_capture", "wireless_inspection"]
	additional_requirements: [
		"Use the policy and decision question established in Frame. Record which owned or authorized lab assets, time window and evidence destination they cover.",
		"Preserve the original capture. Link derived observations and coverage records to the same source and distinguish source event time from processing time.",
	]
	branches: {
		wireless_capture: {
			status:     "documented"
			objective:  "Collect evidence of a known wireless lab event and register the original artifact with its coverage limits."
			leaf_order: ["preflight", "capture", "register_artifacts"]
			leaves: {
				preflight: manualActivity & {
					objective:     "Determine whether the selected receiver can observe the predicted lab event within the agreed window."
					inputs:        ["policy", "assessment"]
					outputs:       ["coverage"]
					prerequisites: ["The operator has the applicable policy and the decision question from Frame."]
					tools: [installedTool & {
						name:              "Xonsh"
						role:              "inspect"
						configuration:     {state: "pending", question: "Which operator environment and receiver are available?"}
						expected_artifact: "Preflight record with receiver, driver, Kismet datasource and helper, installed versions, clock basis, and evidence destination."
					}]
					process: manual_steps: [
						"Identify the expected event on an authorized lab device. Record its predicted observable effect, time window and stop conditions.",
						"From Xonsh, inspect the receiver, driver and installed Kismet datasource support. Record channel coverage, filters, clock basis and any interface state that would need restoration.",
						"Check that the evidence destination is writable and has room for the planned interval. Record the result of each check and release or hold the capture.",
					]
					expected_effects:    {state: "specified", value: "A recorded decision on capture readiness and the limits of the proposed observation."}
					observation_window:  {state: "specified", value: "Before capture, while the documented receiver, permissions and destination are current."}
					completion_criteria: ["Receiver support, scope, timing and destination checks each have a result. A missing prerequisite has a recorded hold reason."]
					failure_paths:       [{condition: "The policy, receiver support, clock basis or destination cannot be verified.", response: "Record the unresolved prerequisite and its release condition. Leave capture pending.", disposition: "hold"}]
				}
				capture: manualActivity & {
					objective:     "Record the bounded lab interval and the receiver's actual coverage."
					inputs:        ["policy", "assessment", "coverage"]
					outputs:       ["observation", "coverage"]
					prerequisites: ["Preflight released this receiver, datasource and destination for the selected interval."]
					tools: [installedTool & {
						name:              "Kismet"
						role:              "capture"
						configuration:     {state: "pending", question: "Which verified datasource, channel settings, filters and interval apply to this run?"}
						expected_artifact: "Closed native .kismet file, datasource status and capture interval."
					}]
					process: manual_steps: [
						"Start the approved capture manually from the operator session. Record the effective datasource, settings and start time.",
						"Mark the known lab event and its reference time. Record datasource interruptions and periods outside the relevant channel.",
						"Stop at the planned end or stop condition. Record the actual end time, close the native file and restore any temporary receiver settings.",
					]
					expected_effects:    {state: "pending", question: "What change should this particular lab event produce at the receiver?"}
					observation_window:  {state: "pending", question: "What start, stop and expected event delay did preflight approve?"}
					completion_criteria: ["The original file or collection failure is accounted for. Coverage records include actual timing, gaps and restoration status."]
					failure_paths:       [{condition: "The datasource drops or the receiver leaves the approved settings.", response: "Stop the collection, preserve any partial file and record the affected interval and restoration status.", disposition: "hold"}]
				}
				register_artifacts: manualActivity & {
					objective:     "Give the original evidence a stable reference before projecting it."
					inputs:        ["observation", "coverage"]
					outputs:       ["observation", "coverage"]
					prerequisites: ["Capture has stopped and the original artifact is closed. Partial captures are explicitly identified."]
					tools: [installedTool & {
						name:              "Python / Pydantic v2"
						role:              "validate"
						configuration:     {state: "pending", question: "Which adapter version and CUE-derived exchange model apply?"}
						expected_artifact: "Validated artifact manifest linked to the capture and coverage records."
					}]
					process: manual_steps: [
						"Invoke the Python registration adapter manually. Record the source reference, byte count and SHA-256 of the closed file along with the effective datasource, interval and gaps.",
						"Validate the manifest at the generated Pydantic boundary and record the schema version. Retain the native file as original evidence.",
						"Verify the recorded reference and digest before releasing this input to inspection.",
					]
					expected_effects:    {state: "specified", value: "A reviewer can identify the exact bytes used and recover their collection context."}
					observation_window:  {state: "specified", value: "After file closure and before the first projection."}
					completion_criteria: ["The manifest resolves to the closed artifact, its size and digest verify, and it references the coverage record."]
					failure_paths:       [{condition: "The file is missing, the digest differs, or a required manifest field fails validation.", response: "Retain the available bytes and discrepancy record. Hold projection until registration is resolved.", disposition: "hold"}]
				}
			}
		}
		wireless_inspection: {
			status:     "documented"
			objective:  "Inspect a reproducible projection of registered evidence and hand observations and coverage to Reconcile Quality."
			leaf_order: ["project_capture", "inspect_projection"]
			leaves: {
				project_capture: manualActivity & {
					objective:     "Derive a queryable view of the selected evidence while preserving source lineage."
					inputs:        ["observation", "coverage"]
					outputs:       ["observation", "coverage"]
					prerequisites: ["The capture manifest and source digest verify, including for a previously registered capture."]
					tools: [installedTool & {
						name:              "Python / Pydantic v2"
						role:              "validate"
						configuration:     {state: "pending", question: "Which adapter and generated model match the input format?"}
						expected_artifact: "Validated projection metadata with capture digest, adapter version, rejected records and reasons."
					}, installedTool & {
						name:              "Ibis / DuckDB"
						role:              "analyze"
						configuration:     {state: "pending", question: "Which Ibis expressions, parameters, and DuckDB destination define this projection?"}
						expected_artifact: "Derived relations and a record of the filters, row counts, transformations and source references."
					}]
					process: manual_steps: [
						"Open the registered input read-only. Select the subset relevant to the framed question and record the adapter version and selection criteria.",
						"Use the Python adapter and generated Pydantic models at the exchange boundary. Compose the relational projection in Ibis and execute it with DuckDB in a separate destination.",
						"Record input, included and rejected counts at the appropriate relation grain, reasons for exclusions, and the original reference for each derived record.",
					]
					expected_effects:    {state: "specified", value: "The reviewer can reproduce the selected rows from the registered input and identify excluded evidence."}
					observation_window:  {state: "specified", value: "Offline, after manifest verification; retain the original event window on every projection."}
					completion_criteria: ["Projection metadata identifies the input digest, versions, filters, counts and limitations. The original digest still verifies."]
					failure_paths:       [{condition: "The input format is unsupported, lineage is lost or counts cannot be explained.", response: "Record the affected relation and discrepancy. Withhold it from review until resolved.", disposition: "hold"}]
				}
				inspect_projection: manualActivity & {
					objective:     "Determine what the projection shows about the predicted lab event and what coverage leaves unresolved."
					inputs:        ["assessment", "observation", "coverage"]
					outputs:       ["observation", "coverage"]
					prerequisites: ["A checked projection, its source manifest and the recorded prediction are available."]
					tools: [installedTool & {
						name:              "Marimo"
						role:              "inspect"
						configuration:     {state: "pending", question: "Which notebook revision, projection reference, filters and event window did the reviewer select?"}
						expected_artifact: "Review record linking the prediction, selected rows, source digest, query parameters and limits."
					}]
					process: manual_steps: [
						"Open the derived relations for read-only inspection in Marimo. Record the notebook revision, filters and time window.",
						"Compare the known event with the rows and the receiver's coverage at that time. Preserve conflicts and distinguish an empty selection from a collection gap.",
						"Hand the observations, coverage limits and outstanding questions to Reconcile Quality with references back to the registered file.",
					]
					expected_effects:    {state: "specified", value: "Each reported observation can be traced to the selected rows and their coverage."}
					observation_window:  {state: "specified", value: "Inspect the predeclared event window within the capture's actual coverage."}
					completion_criteria: ["The handoff links the prediction, result, underlying rows and coverage, or states why the comparison is inconclusive."]
					failure_paths:       [{condition: "The expected event is missing or timing and coverage do not support comparison.", response: "Record the result as unresolved and carry the timing or coverage question into Reconcile Quality.", disposition: "reassess"}]
				}
			}
		}
	}
}
