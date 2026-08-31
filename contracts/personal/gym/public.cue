package gym

// Bind package-owned values outside the convenience namespace. Inside `public`,
// fields such as `chains: chains` otherwise resolve to their own incomplete
// field rather than the canonical package registry.
_publicContract:           gymContract
_publicBody:               bodyRegions
_publicChains:             chains
_publicRelations:          chainRelations
_publicMetrics:            metrics
_publicMetricLineage:      metricLineage
_publicEquilibriumMetrics: equilibriumMetrics
_publicProtocols:          protocols
_publicExercises:          exerciseProfiles
_publicMappings:           exerciseMappings
_publicPrograms:           programs
_publicProgramTargets:     ankleKneePelvisTargets
_publicCompositeTargets:   ankleKneePelvisCompositeTargets
_publicProgramEquilibrium: ankleKneePelvisEquilibrium
_publicDataRequirements:   ankleKneePelvisDataRequirements
_publicProjections:        projectionRelations
_publicProjectionPolicy:   projectionPolicy
_publicRecoveryPolicy:     defaultRecoveryPolicy
_publicSessionAdmission:   defaultSessionAdmissionPolicy

// Convenience export namespace. Domain registries and contracts own their own
// closure; this is a deterministic projection of those canonical values.
public: {
	contract:           _publicContract
	body:               _publicBody
	chains:             _publicChains
	relations:          _publicRelations
	metrics:            _publicMetrics
	metricLineage:      _publicMetricLineage
	equilibriumMetrics: _publicEquilibriumMetrics
	protocols:          _publicProtocols
	exercises:          _publicExercises
	mappings:           _publicMappings
	programs:           _publicPrograms
	programTargets:     _publicProgramTargets
	compositeTargets:   _publicCompositeTargets
	programEquilibrium: _publicProgramEquilibrium
	dataRequirements:   _publicDataRequirements
	projections:        _publicProjections
	projectionPolicy:   _publicProjectionPolicy
	policies: close({
		recovery:         _publicRecoveryPolicy
		sessionAdmission: _publicSessionAdmission
	})
}
