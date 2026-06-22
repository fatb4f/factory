package factory

#ReflectiveView: close({
	id:        string & !=""
	stage:     "input" | "transform" | "output" | "sensor" | "error-signal" | "control-action" | "next-state" | "loop"
	authority: false
	bounded:   true
	redacted:  bool | *false
	schema:    string & !=""
	source:    string & !=""
	payload:   _
})

#EvidencePacket: close({
	schema:     string & !=""
	view:       string & !=""
	authority: false
	bounded:   true
	provenance: #ReflectionProvenance
	payload:    _
})

#Materialization: close({
	path:          string & !=""
	kind:          "evidence" | "fixture" | "executable-check" | "assertion-instance"
	authority:     false
	generatedFrom: string & !=""
	admittedBy:    string & !=""
	writtenBy:     string & !=""
	schema:        string & !=""
})

#AdapterAction: "export-view" | "materialize" | "check-drift" | "run-check"

#CueTarget: close({
	kind:    "cue-value"
	package: "contracts/factory"
	path:    [string, ...string]
})

#PayloadBinding: close({
	kind:       "json-pointer"
	sourcePath: string & !=""
	pointer:    [string, ...string]
	targetPath: [string, ...string]
	schema:     string & !=""
})

#AdapterCommand: close({
	name:   string & !=""
	action: #AdapterAction

	view?:           string & !=""
	target?:         #CueTarget
	payloadBinding?: #PayloadBinding
	outputs:         [#EvidencePacket, ...#EvidencePacket]
	materializes:    * [] | [...#Materialization]
	requiredInputs?: [...string]
})

#DriftCheck: close({
	id:          string & !=""
	description: string & !=""
	declaredBy:  string & !=""
})

introspection: {
	schema: "factory.introspection.v1"

	sourceSurfaces: reflectionInventory.sourceSurfaces

	views: {
		input: #ReflectiveView & {
			id:        "control.view.input"
			stage:     "input"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.input"
			payload:   validationLoopStages.input.payload
		}
		transform: #ReflectiveView & {
			id:        "control.view.transform"
			stage:     "transform"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.transform"
			payload:   validationLoopStages.transform.payload
		}
		output: #ReflectiveView & {
			id:        "control.view.output"
			stage:     "output"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.output"
			payload:   validationLoopStages.output.payload
		}
		sensor: #ReflectiveView & {
			id:        "control.view.sensor"
			stage:     "sensor"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.sensor"
			payload:   validationLoopStages.sensor.payload
		}
		errorSignal: #ReflectiveView & {
			id:        "control.view.error-signal"
			stage:     "error-signal"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.errorSignal"
			payload:   "generated/evidence/materialization-report.json#/gaps"
		}
		controlAction: #ReflectiveView & {
			id:        "control.view.control-action"
			stage:     "control-action"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.controlAction"
			payload:   validationLoopStages.controlAction.payload
		}
		nextState: #ReflectiveView & {
			id:        "control.view.next-state"
			stage:     "next-state"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-stage-export.v1"
			source:    "validationLoopStages.nextState"
			payload:   validationLoopStages.nextState.payload
		}
		loop: #ReflectiveView & {
			id:        "control.view.loop"
			stage:     "loop"
			authority: false
			bounded:   true
			schema:    "factory.control-loop-export.v1"
			source:    "validationLoopExport"
			payload:   validationLoopExport
		}
	}

	evidencePackets: {
		materializationReport: #EvidencePacket & {
			schema:     "factory.materialization-report.v1"
			view:       "materialization-report"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    "generated/evidence/materialization-report.json"
		}
		controlLoopInput: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "input"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.input.payload
		}
		controlLoopTransform: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "transform"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.transform.payload
		}
		controlLoopOutput: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "output"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.output.payload
		}
		controlLoopSensor: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "sensor"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.sensor.payload
		}
		controlLoopErrorSignal: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "error-signal"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    "generated/evidence/materialization-report.json#/gaps"
		}
		controlLoopControlAction: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "control-action"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.controlAction.payload
		}
		controlLoopNextState: #EvidencePacket & {
			schema:     "factory.control-loop-stage-export.v1"
			view:       "next-state"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    validationLoopStages.nextState.payload
		}
		agentContextHookPacket: #EvidencePacket & {
			schema:     "factory.observed-packet-evidence.v1"
			view:       "runtime-packet"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    "generated/evidence/agent-context-hook.packet.json"
		}
		assertionResults: #EvidencePacket & {
			schema:     "factory.assertion-results.v1"
			view:       "assertion-results"
			authority: false
			bounded:   true
			provenance: injectedProvenance
			payload:    "generated/evidence/assertion-results.json"
		}
	}

	materializations: {
		assertionAgentContextHook: #Materialization & {
			path:          "contracts/factory/assertions/generated/agent_context_hook.cue"
			kind:          "assertion-instance"
			authority:     false
			generatedFrom: "contracts/factory/reflection.cue"
			admittedBy:    "control.export.control-action"
			writtenBy:     "materialize.validation"
			schema:        "factory.admitted-assertion.v1"
		}
		agentContextHookCheck: #Materialization & {
			path:          "generated/checks/agent-context-hook"
			kind:          "executable-check"
			authority:     false
			generatedFrom: "contracts/factory/reflection.cue"
			admittedBy:    "control.export.control-action"
			writtenBy:     "materialize.validation"
			schema:        "factory.validation-projection.v1"
		}
		agentContextHookFixture: #Materialization & {
			path:          "generated/fixtures/agent-context-hook-prompt.json"
			kind:          "fixture"
			authority:     false
			generatedFrom: "contracts/factory/reflection.cue"
			admittedBy:    "control.export.control-action"
			writtenBy:     "materialize.validation"
			schema:        "factory.validation-fixture.v1"
		}
		materializationReport: #Materialization & {
			path:          "generated/evidence/materialization-report.json"
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/reflection.cue"
			admittedBy:    "reflection.check-drift"
			writtenBy:     "materialize.validation"
			schema:        "factory.materialization-report.v1"
		}
		controlLoopInput: #Materialization & {
			path:          validationControlLoop.exports.input.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.input"
			writtenBy:     "control.export.input"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopTransform: #Materialization & {
			path:          validationControlLoop.exports.transform.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.transform"
			writtenBy:     "control.export.transform"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopOutput: #Materialization & {
			path:          validationControlLoop.exports.output.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.output"
			writtenBy:     "control.export.output"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopSensor: #Materialization & {
			path:          validationControlLoop.exports.sensor.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.sensor"
			writtenBy:     "control.export.sensor"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopErrorSignal: #Materialization & {
			path:          validationControlLoop.exports.errorSignal.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.error-signal"
			writtenBy:     "control.export.error-signal"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopControlAction: #Materialization & {
			path:          validationControlLoop.exports.controlAction.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.control-action"
			writtenBy:     "control.export.control-action"
			schema:        "factory.control-loop-stage-export.v1"
		}
		controlLoopNextState: #Materialization & {
			path:          validationControlLoop.exports.nextState.path
			kind:          "evidence"
			authority:     false
			generatedFrom: "contracts/factory/introspection.cue"
			admittedBy:    "control.export.next-state"
			writtenBy:     "control.export.next-state"
			schema:        "factory.control-loop-stage-export.v1"
		}
		agentContextHookPacket: #Materialization & {
			path:          "generated/evidence/agent-context-hook.packet.json"
			kind:          "evidence"
			authority:     false
			generatedFrom: "generated/checks/agent-context-hook"
			admittedBy:    "runtime.agent-context-hook"
			writtenBy:     "runtime.agent-context-hook"
			schema:        "factory.observed-packet-evidence.v1"
		}
		assertionResults: #Materialization & {
			path:          "generated/evidence/assertion-results.json"
			kind:          "evidence"
			authority:     false
			generatedFrom: "generated/checks/agent-context-hook"
			admittedBy:    "runtime.agent-context-hook"
			writtenBy:     "runtime.agent-context-hook"
			schema:        "factory.assertion-results.v1"
		}
	}

	adapterCommands: {
		"control.export.input": #AdapterCommand & {
			name:   "control.export.input"
			action: "export-view"
			view:   "input"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "input"]
			}
			outputs:      [evidencePackets.controlLoopInput]
			materializes: [materializations.controlLoopInput]
		}
		"control.export.transform": #AdapterCommand & {
			name:   "control.export.transform"
			action: "export-view"
			view:   "transform"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "transform"]
			}
			outputs:      [evidencePackets.controlLoopTransform]
			materializes: [materializations.controlLoopTransform]
		}
		"control.export.output": #AdapterCommand & {
			name:   "control.export.output"
			action: "export-view"
			view:   "output"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "output"]
			}
			outputs:      [evidencePackets.controlLoopOutput]
			materializes: [materializations.controlLoopOutput]
		}
		"control.export.sensor": #AdapterCommand & {
			name:   "control.export.sensor"
			action: "export-view"
			view:   "sensor"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "sensor"]
			}
			outputs:      [evidencePackets.controlLoopSensor]
			materializes: [materializations.controlLoopSensor]
		}
		"control.export.error-signal": #AdapterCommand & {
			name:   "control.export.error-signal"
			action: "export-view"
			view:   "error-signal"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "errorSignal"]
			}
			payloadBinding: {
				kind:       "json-pointer"
				sourcePath: "generated/evidence/materialization-report.json"
				pointer:    ["gaps"]
				targetPath: ["payload"]
				schema:     "factory.reflection-gap-report.v1"
			}
			outputs:      [evidencePackets.controlLoopErrorSignal]
			materializes: [materializations.controlLoopErrorSignal]
		}
		"control.export.control-action": #AdapterCommand & {
			name:   "control.export.control-action"
			action: "export-view"
			view:   "control-action"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "controlAction"]
			}
			outputs:      [evidencePackets.controlLoopControlAction]
			materializes: [materializations.controlLoopControlAction]
		}
		"control.export.next-state": #AdapterCommand & {
			name:   "control.export.next-state"
			action: "export-view"
			view:   "next-state"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["validationLoopStages", "nextState"]
			}
			outputs:      [evidencePackets.controlLoopNextState]
			materializes: [materializations.controlLoopNextState]
		}
		"reflection.check-drift": #AdapterCommand & {
			name:   "reflection.check-drift"
			action: "check-drift"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["reflectionInventory"]
			}
			outputs: [evidencePackets.materializationReport]
		}
		"materialize.validation": #AdapterCommand & {
			name:   "materialize.validation"
			action: "materialize"
			target: {
				kind:    "cue-value"
				package: "contracts/factory"
				path:    ["materializationPlan"]
			}
			outputs: [evidencePackets.materializationReport]
			materializes: [
				materializations.assertionAgentContextHook,
				materializations.agentContextHookCheck,
				materializations.agentContextHookFixture,
				materializations.materializationReport,
			]
			requiredInputs: reflectionInventory.sourceSurfaces
		}
		"runtime.agent-context-hook": #AdapterCommand & {
			name:   "runtime.agent-context-hook"
			action: "run-check"
			outputs: [
				evidencePackets.agentContextHookPacket,
				evidencePackets.assertionResults,
			]
			materializes: [
				materializations.agentContextHookPacket,
				materializations.assertionResults,
			]
			requiredInputs: [
				"generated/fixtures/agent-context-hook-prompt.json",
				"contracts/factory/assertions/generated/agent_context_hook.cue",
				".codex/hooks.json",
			]
		}
	}

	controlLoopExportCommands: [
		"control.export.input",
		"control.export.transform",
		"control.export.output",
		"control.export.sensor",
		"control.export.error-signal",
		"control.export.control-action",
		"control.export.next-state",
	]

	allowedGeneratedSubroots: [
		"generated/checks",
		"generated/fixtures",
		"generated/evidence",
	]

	driftAssertions: {
		commandMaterializationWriterEdges: {
			for commandName, command in adapterCommands {
				for _, materialization in command.materializes {
					if materialization.writtenBy != commandName {
						_writerMismatch: _|_
					}
				}
			}
		}
		materializationWriterCommands: {
			for materializationName, materialization in materializations {
				"\(materializationName)": adapterCommands[materialization.writtenBy].name
			}
		}
		materializationAdmitterCommands: {
			for materializationName, materialization in materializations {
				"\(materializationName)": adapterCommands[materialization.admittedBy].name
			}
		}
		adapterCommandOutputs: {
			for commandName, command in adapterCommands {
				"\(commandName)": command.outputs
			}
		}
		generatedSubroots: introspection.allowedGeneratedSubroots
	}

	driftChecks: {
		evidenceFilesDeclared: #DriftCheck & {
			id:          "factory.drift.generated-evidence-declared"
			description: "every generated/evidence file has a matching introspection materialization"
			declaredBy:  "contracts/factory/introspection.cue"
		}
		checkFilesDeclared: #DriftCheck & {
			id:          "factory.drift.generated-checks-declared"
			description: "every generated/checks executable has a matching introspection materialization"
			declaredBy:  "contracts/factory/introspection.cue"
		}
		adapterCommandsDeclared: #DriftCheck & {
			id:          "factory.drift.adapter-commands-declared"
			description: "every executable aperture command has a matching AdapterCommand"
			declaredBy:  "contracts/factory/introspection.cue"
		}
		outputsValidateAsEvidence: #DriftCheck & {
			id:          "factory.drift.adapter-output-evidence"
			description: "every AdapterCommand output validates against EvidencePacket"
			declaredBy:  "contracts/factory/introspection.cue"
		}
		noShellOnlyPaths: #DriftCheck & {
			id:          "factory.drift.no-shell-only-generated-paths"
			description: "no generated file path appears only in shell or just"
			declaredBy:  "contracts/factory/introspection.cue"
		}
	}
}
