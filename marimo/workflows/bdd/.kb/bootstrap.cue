package bdd

implementationUnitID:  "kg://repository/factory/implementation-unit/uv-bd-bootstrap/v1"
_implementationUnitID: implementationUnitID

requirementsSource: #SourceIdentity & {
	uri: "https://github.com/fatb4f/factory/issues/103"
	transport: {
		revision:   "2026-07-12T21:12:55Z"
		bodyDigest: "sha256:005d6c97fa23106624e8149bcdd91614e194d294a255a6fb2936147003e99d81"
	}
	requirementSnapshot: {
		schema: "factory.requirements-snapshot.v1"
		digest: "sha256:d6999947ab802a8918a89a994818f02e27b127701fef9e0f265054d8a36680d4"
	}
}
_requirementsSource: requirementsSource

bootstrapRequirements: {
	"UV-01": true, "UV-02": true, "UV-03": true, "UV-04": true
	"BD-01": true, "BD-02": true, "BD-03": true, "BD-04": true
	"BD-05": true, "BD-06": true, "BD-07": true, "BD-08": true
}

#BootstrapPhase: "candidate-identities" | "minimal-verification" | "bounded-provisional-use" | "self-conformance" | "admitted-identities" | "provisional-retired"

#BootstrapState: close({
	implementationUnitID:     _implementationUnitID
	phase:                    #BootstrapPhase
	provisionalEligible:      bool
	selfConformanceEvidence?: #NonEmptyString
	retirementEvidence?:      #NonEmptyString
})

#MinimalBootstrapValidator: close({
	identity: #ContractIdentity
	soleUnit: _implementationUnitID
	mayEstablish: [
		"package closure and required exports",
		"positive fixture acceptance",
		"negative fixture rejection",
		"project and lock identity",
		"locked exact execution",
		"claimant boolean rejection",
	]
	excludedClaims: [
		"canonical BDD self-conformance",
		"final implementation-unit admission",
		"provisional-admission retirement",
	]
})

minimalBootstrapValidator: #MinimalBootstrapValidator & {
	identity: {
		uri:              "kg://repository/factory/contract/bdd-bootstrap-minimal/v1"
		version:          "factory.bdd-bootstrap-minimal.v1"
		canonicalization: "CUE value unified from the vetted bdd package and exported as canonical JSON."
		digestSubject: [
			"minimal validator identity and bounded claims",
			"bootstrap implementation-unit identity",
			"candidate project and lock identity checks",
			"positive and negative fixture expectations",
		]
	}
}

bootstrapDeclaration: close({
	implementationUnitID: _implementationUnitID
	requirementsSource:   _requirementsSource
	satisfies:            bootstrapRequirements
	dependencyClosure:    bootstrapRequirements
	workbookIdentity:     bootstrapWorkbookIdentity
	contract:             bddContract
	minimalValidator:     minimalBootstrapValidator
	initialState: #BootstrapState & {
		implementationUnitID: _implementationUnitID
		phase:                "candidate-identities"
		provisionalEligible:  true
	}
})
