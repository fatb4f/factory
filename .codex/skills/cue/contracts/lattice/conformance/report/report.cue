package report

import (
	catalog "github.com/fatb4f/factory/cue-skill/lattice/conformance/catalog"
	upstream "github.com/fatb4f/factory/cue-skill/lattice/conformance/upstream"
)

report: close({
	id:     "issue-107-s01-s02-v1"
	matrix: catalog.matrix
	directRequirements: ["UA-01", "UA-02", "UA-03", "UA-04"]
	authorityID:              upstream.authority.id
	authorityRevision:        upstream.authority.revision
	artifactCount:            len(upstream.authority.artifacts)
	conceptCatalogID:         catalog.catalog.id
	conceptCount:             len(catalog.catalog.concepts)
	sourceInventoryCount:     len(catalog.sourceInventory)
	authorityPinned:          upstream.authorityPinned
	conceptCatalogComplete:   catalog.catalogComplete
	closureComplete:          catalog.closureComplete
	directCoverageComplete:   catalog.directCoverageComplete
	negativeFixturesComplete: upstream.negativeFixtureEvaluationComplete && catalog.negativeFixtureEvaluationComplete
	structuralGatesComplete:  catalog.structuralGatesComplete
	implementationComplete:   catalog.sliceComplete
	sliceAdmission:           catalog.sliceAdmission
	downstreamHandoff: close({
		publicationBinding: "exact-git-commit-required"
		consumers: ["S03", "S04"]
	})
})
