package ivaceval

evaluationContracts: close({
	"permanent-sequela":                   permanentSequelaContract
	"gp-addendum":                         gpAddendumContract
	"neuroscience-expertise":              neuroscienceExpertiseContract
	"neuropsychological-reassessment":     neuropsychologicalReassessmentContract
	"speech-language-assessment":          speechLanguageAssessmentContract
	"psychological-dissociation-assessment": psychologicalDissociationAssessmentContract
	"legal-review":                        legalReviewContract
	"downstream-reuse":                     downstreamReuseContract
})

public: close({
	contracts: evaluationContracts
})
