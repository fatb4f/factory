package cuestrapprofile

let selectedChannels = channels

publicContract: close({
	apiVersion:  "factory.upstream-monitor.codex.cuestrap/v1"
	kind:        "CuestrapCodexContractSurfaceMonitor"
	operational: bool
	signal:      #CuestrapAcceptedSignal
	authority:   _
	context:     _
	channels:    _
	actuator:    _
	workflow:    _
	surfaces: [...#CuestrapSurface]
	classification:       _
	reportTemplate:       _
	summaryTemplate:      _
	publicationPlan:      _
	publicationAdmission: _
	forbiddenAttractors: [...string]
	validationAssertions: _
	validationPlan:       _
}) & {
	apiVersion:           "factory.upstream-monitor.codex.cuestrap/v1"
	kind:                 "CuestrapCodexContractSurfaceMonitor"
	operational:          cuestrapOperational
	signal:               cuestrapAcceptedSignal
	authority:            cuestrapAuthorityModel
	context:              cuestrapContext
	channels:             selectedChannels
	actuator:             chatgptActuator
	workflow:             cuestrapWorkflow
	surfaces:             cuestrapSurfaceCatalogue
	classification:       cuestrapClassificationPolicy
	reportTemplate:       cuestrapCodexImpactReportTemplate
	summaryTemplate:      cuestrapRunSummaryTemplate
	publicationPlan:      cuestrapPublicationPlan
	publicationAdmission: cuestrapPublicationAdmission
	forbiddenAttractors:  cuestrapForbiddenAttractors
	validationAssertions: cuestrapValidationAssertions
	validationPlan:       cuestrapValidationPlan
}
