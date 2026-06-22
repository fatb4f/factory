package factory

#ReflectionProvenance: close({
	origin:          "reflection"
	reflector:       string & !=""
	sourceDigest:    string & =~"^sha256:[0-9a-f]{64}$"
	inventoryDigest: string & =~"^sha256:[0-9a-f]{64}$"
	materializedAt:  string & =~"^run:[0-9a-f]{16,64}$"
})

#LoopStage: close({
	id:          string & !=""
	kind:        string & !=""
	authority:   bool
	schema:      string & !=""
	source?:     string
	producedBy?: string
	consumes?:   [...string]
	produces?:   [...string]
})

#ExportSurface: close({
	path:          string & !=""
	schema:        string & !=""
	stage:         string & !=""
	authority:     false
	bounded:       true
	redacted:      bool
	generatedFrom: string & !=""
	provenance:    #ReflectionProvenance
})

#ControlLoop: close({
	id:         string & !=""
	controller: string & !=""

	input:         #LoopStage
	transform:     #LoopStage
	output:        #LoopStage
	sensor:        #LoopStage
	errorSignal:   #LoopStage
	controlAction: #LoopStage
	nextState:     #LoopStage

	exports: {
		input?:         #ExportSurface
		transform?:     #ExportSurface
		output?:        #ExportSurface
		sensor?:        #ExportSurface
		errorSignal?:   #ExportSurface
		controlAction?: #ExportSurface
		nextState?:     #ExportSurface
	}
})

#SourceStage: close({
	id:               string & !=""
	kind:             string & !=""
	schema:           string & !=""
	sourceAuthority?: bool
	source?:          string
	producedBy?:      string
	consumes?:        [...string]
	produces?:        [...string]
})

#StageExport: close({
	schema:        "factory.control-loop-stage-export.v1"
	loopID:        string & !=""
	stage:         string & !=""
	authority:     false
	bounded:       true
	sourceStage:   #SourceStage
	exportSurface: #ExportSurface
	provenance:    exportSurface.provenance
	payload:       _
})

#ErrorSignalExport: #StageExport & {
	stage: "error-signal"
	payload: {
		schema:                          "factory.reflection-gap-report.v1"
		status:                          "closed" | "open"
		missingAssertions:               [...string]
		missingRequiredValues:           [...string]
		uncoveredProjectionPaths:        [...string]
		unbackedExecutableChecks:        [...string]
		unbackedFixtures:                [...string]
		unbackedEvidence:                [...string]
		nonReproducibleGeneratedOutputs: [...string]
		runtimeAssertionFailures:        [...string]
	}
}

#ControlActionExport: #StageExport & {
	stage: "control-action"
	payload: {
		decisionID:          string & !=""
		action:              "admit" | "reject" | "defer" | "materialize" | "block"
		reason:              string & !=""
		errorSignal:         string & !=""
		materializationPlan: string & !=""
		nextState?:          string & !=""
	}
}

#LoopExport: close({
	schema:     "factory.control-loop-export.v1"
	loop:       #ControlLoop
	stages:     [string]: #StageExport
	provenance: injectedProvenance
})

injectedProvenance: #ReflectionProvenance & {
	origin:          "reflection"
	reflector:       "factory.validation-reflector.v1"
	sourceDigest:    string @tag(sourceDigest)
	inventoryDigest: string @tag(inventoryDigest)
	materializedAt:  string @tag(materializedAt)
}

validationControlLoop: #ControlLoop & {
	id:         "factory.validation.control-loop"
	controller: "factory.validation-reflector.v1"

	input: {
		id:        "factory.validation.loop.input"
		kind:      "contract-source-adapter-surface-generated-state"
		authority: true
		schema:    "factory.loop-stage.input.v1"
		source:    "contracts/factory/reflection.cue"
		produces: [
			"contracts/factory/assertions/schema.cue",
			"contracts/factory/control.cue",
			"contracts/factory/introspection.cue",
			"contracts/factory/reflection.cue",
			".codex/hooks.json",
			"contracts/agent-context-resolver/generated/route_inventory.json",
			"generated/checks",
			"generated/fixtures",
			"generated/evidence",
		]
	}
	transform: {
		id:        "factory.validation.loop.transform"
		kind:      "reflective-introspection-inventory-generation"
		authority: true
		schema:    "factory.reflection-inventory.v1"
		source:    "contracts/factory/reflection.cue"
		consumes:  validationControlLoop.input.produces
		produces: [
			"reflectionInventory",
			"generated/evidence/control-loop/transform.json",
		]
	}
	output: {
		id:        "factory.validation.loop.output"
		kind:      "contract-extension-assertion-fixture-check-plan"
		authority: true
		schema:    "factory.validation-materialization-plan.v1"
		source:    "contracts/factory/reflection.cue"
		consumes: [
			"reflectionInventory",
		]
		produces: [
			"contractExtensionProposals",
			"contracts/factory/assertions/generated/agent_context_hook.cue",
			"generated/fixtures/agent-context-hook-prompt.json",
			"generated/checks/agent-context-hook",
		]
	}
	sensor: {
		id:        "factory.validation.loop.sensor"
		kind:      "coverage-gap-reproducibility-runtime-validation"
		authority: false
		schema:    "factory.loop-stage.sensor.v1"
		producedBy: "generated/checks/agent-context-hook"
		consumes: [
			"contracts/factory/assertions/generated/agent_context_hook.cue",
			"generated/fixtures/agent-context-hook-prompt.json",
			"generated/evidence/materialization-report.json",
		]
		produces: [
			"generated/evidence/agent-context-hook.packet.json",
			"generated/evidence/assertion-results.json",
		]
	}
	errorSignal: {
		id:        "factory.validation.loop.error-signal"
		kind:      "reflection-gap-runtime-failure-signal"
		authority: true
		schema:    "factory.reflection-gap-report.v1"
		source:    "contracts/factory/reflection.cue"
		consumes: [
			"reflectionInventory",
			"generated/checks",
			"generated/fixtures",
			"generated/evidence",
		]
		produces: [
			"missingAssertions",
			"missingRequiredValues",
			"uncoveredProjectionPaths",
			"unbackedExecutableChecks",
			"unbackedFixtures",
			"unbackedEvidence",
			"nonReproducibleGeneratedOutputs",
			"runtimeAssertionFailures",
		]
	}
	controlAction: {
		id:        "factory.validation.loop.control-action"
		kind:      "admit-materialize-regenerate-block-or-remove-stale"
		authority: true
		schema:    "factory.loop-stage.control-action.v1"
		source:    "contracts/factory/reflection.cue"
		consumes: [
			"contractExtensionProposals",
			"generated/evidence/materialization-report.json",
			"generated/evidence/control-loop/error-signal.json",
		]
		produces: [
			"admit proposal",
			"materialize generated assertions",
			"generate checks and fixtures",
			"block admission",
			"request new reflected value",
			"remove stale generated output",
		]
	}
	nextState: {
		id:        "factory.validation.loop.next-state"
		kind:      "admitted-assertion-generated-projections-exported-evidence"
		authority: false
		schema:    "factory.loop-stage.next-state.v1"
		producedBy: "contracts/factory/reflection/scripts/generate-validation"
		consumes: [
			"generated/evidence/materialization-report.json",
			"generated/evidence/agent-context-hook.packet.json",
			"generated/evidence/assertion-results.json",
		]
		produces: [
			"contracts/factory/assertions/generated/agent_context_hook.cue",
			"generated/checks/agent-context-hook",
			"generated/fixtures/agent-context-hook-prompt.json",
			"generated/evidence/materialization-report.json",
			"generated/evidence/agent-context-hook.packet.json",
			"generated/evidence/assertion-results.json",
		]
	}

	exports: {
		input:         #stageExportSurface & {stage: "input", path: "generated/evidence/control-loop/input.json"}
		transform:     #stageExportSurface & {stage: "transform", path: "generated/evidence/control-loop/transform.json"}
		output:        #stageExportSurface & {stage: "output", path: "generated/evidence/control-loop/output.json"}
		sensor:        #stageExportSurface & {stage: "sensor", path: "generated/evidence/control-loop/sensor.json", redacted: false}
		errorSignal:   #stageExportSurface & {stage: "error-signal", path: "generated/evidence/control-loop/error-signal.json"}
		controlAction: #stageExportSurface & {stage: "control-action", path: "generated/evidence/control-loop/control-action.json"}
		nextState:     #stageExportSurface & {stage: "next-state", path: "generated/evidence/control-loop/next-state.json"}
	}
}

#stageExportSurface: #ExportSurface & {
	schema:        "factory.control-loop-stage-export.v1"
	authority:     false
	bounded:       true
	redacted:      true | *false
	generatedFrom: "contracts/factory/control.cue"
	provenance:    injectedProvenance
}

validationLoopStages: {
	input: #StageExport & {
		loopID: validationControlLoop.id
		stage:  "input"
		sourceStage: {
			id:              validationControlLoop.input.id
			kind:            validationControlLoop.input.kind
			schema:          validationControlLoop.input.schema
			sourceAuthority: validationControlLoop.input.authority
			source:          validationControlLoop.input.source
			produces:        validationControlLoop.input.produces
		}
		exportSurface: validationControlLoop.exports.input
		payload: {
			surfaces: validationControlLoop.input.produces
		}
	}
	transform: #StageExport & {
		loopID: validationControlLoop.id
		stage:  "transform"
		sourceStage: {
			id:              validationControlLoop.transform.id
			kind:            validationControlLoop.transform.kind
			schema:          validationControlLoop.transform.schema
			sourceAuthority: validationControlLoop.transform.authority
			source:          validationControlLoop.transform.source
			consumes:        validationControlLoop.transform.consumes
			produces:        validationControlLoop.transform.produces
		}
		exportSurface: validationControlLoop.exports.transform
		payload: {
			inventory: "generated/evidence/materialization-report.json#/inventory"
		}
	}
	output: #StageExport & {
		loopID: validationControlLoop.id
		stage:  "output"
		sourceStage: {
			id:              validationControlLoop.output.id
			kind:            validationControlLoop.output.kind
			schema:          validationControlLoop.output.schema
			sourceAuthority: validationControlLoop.output.authority
			source:          validationControlLoop.output.source
			consumes:        validationControlLoop.output.consumes
			produces:        validationControlLoop.output.produces
		}
		exportSurface: validationControlLoop.exports.output
		payload: {
			materializationPlan: "generated/evidence/materialization-report.json#/materializationPlan"
		}
	}
	sensor: #StageExport & {
		loopID: validationControlLoop.id
		stage:  "sensor"
		sourceStage: {
			id:              validationControlLoop.sensor.id
			kind:            validationControlLoop.sensor.kind
			schema:          validationControlLoop.sensor.schema
			sourceAuthority: validationControlLoop.sensor.authority
			producedBy:      validationControlLoop.sensor.producedBy
			consumes:        validationControlLoop.sensor.consumes
			produces:        validationControlLoop.sensor.produces
		}
		exportSurface: validationControlLoop.exports.sensor
		payload: {
			runtimeEvidence: [
				"generated/evidence/agent-context-hook.packet.json",
				"generated/evidence/assertion-results.json",
			]
		}
	}
	errorSignal: #ErrorSignalExport & {
		loopID: validationControlLoop.id
		sourceStage: {
			id:              validationControlLoop.errorSignal.id
			kind:            validationControlLoop.errorSignal.kind
			schema:          validationControlLoop.errorSignal.schema
			sourceAuthority: validationControlLoop.errorSignal.authority
			source:          validationControlLoop.errorSignal.source
			consumes:        validationControlLoop.errorSignal.consumes
			produces:        validationControlLoop.errorSignal.produces
		}
		exportSurface: validationControlLoop.exports.errorSignal
		payload: {
			schema:                          "factory.reflection-gap-report.v1"
			status:                          "closed"
			missingAssertions:               []
			missingRequiredValues:           []
			uncoveredProjectionPaths:        []
			unbackedExecutableChecks:        []
			unbackedFixtures:                []
			unbackedEvidence:                []
			nonReproducibleGeneratedOutputs: []
			runtimeAssertionFailures:        []
		}
	}
	controlAction: #ControlActionExport & {
		loopID: validationControlLoop.id
		sourceStage: {
			id:              validationControlLoop.controlAction.id
			kind:            validationControlLoop.controlAction.kind
			schema:          validationControlLoop.controlAction.schema
			sourceAuthority: validationControlLoop.controlAction.authority
			source:          validationControlLoop.controlAction.source
			consumes:        validationControlLoop.controlAction.consumes
			produces:        validationControlLoop.controlAction.produces
		}
		exportSurface: validationControlLoop.exports.controlAction
		payload: {
			decisionID:          "factory.validation.agent-context-hook"
			action:              "admit"
			reason:              "reflection gaps are closed and assertion-backed generated projections are reproducible"
			errorSignal:         "generated/evidence/control-loop/error-signal.json"
			materializationPlan: "generated/evidence/materialization-report.json"
			nextState:           "generated/evidence/control-loop/next-state.json"
		}
	}
	nextState: #StageExport & {
		loopID: validationControlLoop.id
		stage:  "next-state"
		sourceStage: {
			id:              validationControlLoop.nextState.id
			kind:            validationControlLoop.nextState.kind
			schema:          validationControlLoop.nextState.schema
			sourceAuthority: validationControlLoop.nextState.authority
			producedBy:      validationControlLoop.nextState.producedBy
			consumes:        validationControlLoop.nextState.consumes
			produces:        validationControlLoop.nextState.produces
		}
		exportSurface: validationControlLoop.exports.nextState
		payload: {
			admittedAssertions: ["contracts/factory/assertions/generated/agent_context_hook.cue"]
			generatedChecks:    ["generated/checks/agent-context-hook"]
			generatedFixtures:  ["generated/fixtures/agent-context-hook-prompt.json"]
			exportedEvidence: [
				"generated/evidence/materialization-report.json",
				"generated/evidence/control-loop/error-signal.json",
				"generated/evidence/control-loop/control-action.json",
				"generated/evidence/control-loop/next-state.json",
				"generated/evidence/agent-context-hook.packet.json",
				"generated/evidence/assertion-results.json",
			]
		}
	}
}

validationLoopExport: #LoopExport & {
	loop:   validationControlLoop
	stages: validationLoopStages
}
