package ivaceval

evaluationContracts: close({
	"permanent-sequela":      permanentSequelaContract
	"gp-addendum":            gpAddendumContract
	"neuroscience-expertise": neuroscienceExpertiseContract
	"legal-review":            legalReviewContract
})

public: close({
	contracts: evaluationContracts
})
