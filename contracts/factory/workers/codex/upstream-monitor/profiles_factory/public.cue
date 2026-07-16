package factoryprofile

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
	operational:          operational
	signal:               acceptedSignal
	authority:            authorityModel
	channels:             channels
	actuator:             chatgptActuator
	workflow:             workflow
	surfaces:             surfaceCatalogue
	classification:       classificationPolicy
	reportTemplate:       upstreamCodexImpactReportTemplate
	publicationPlan:      upstreamCodexPublicationPlan
	publicationAdmission: publicationAdmission
	forbiddenAttractors:  forbiddenAttractors
	validationAssertions: validationAssertions
	validationPlan:       validationPlan
}
