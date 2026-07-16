package factoryprofile

let selectedOperational = operational
let selectedChannels = channels
let selectedWorkflow = workflow
let selectedPublicationAdmission = publicationAdmission
let selectedForbiddenAttractors = forbiddenAttractors
let selectedValidationAssertions = validationAssertions
let selectedValidationPlan = validationPlan

publicContract: close({
	apiVersion:  "factory.upstream-monitor.codex/v1"
	kind:        "CodexContractSurfaceMonitor"
	operational: bool
	signal:      #AcceptedSignal
	authority:   _
	channels:    _
	actuator:    _
	workflow:    _
	surfaces: [...#Surface]
	classification:       _
	reportTemplate:       _
	publicationPlan:      _
	publicationAdmission: _
	forbiddenAttractors: [...string]
	validationAssertions: _
	validationPlan:       _
}) & {
	apiVersion:           "factory.upstream-monitor.codex/v1"
	kind:                 "CodexContractSurfaceMonitor"
	operational:          selectedOperational
	signal:               acceptedSignal
	authority:            authorityModel
	channels:             selectedChannels
	actuator:             chatgptActuator
	workflow:             selectedWorkflow
	surfaces:             surfaceCatalogue
	classification:       classificationPolicy
	reportTemplate:       upstreamCodexImpactReportTemplate
	publicationPlan:      upstreamCodexPublicationPlan
	publicationAdmission: selectedPublicationAdmission
	forbiddenAttractors:  selectedForbiddenAttractors
	validationAssertions: selectedValidationAssertions
	validationPlan:       selectedValidationPlan
}
