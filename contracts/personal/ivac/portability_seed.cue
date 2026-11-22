package ivac

// Public, de-identified reuse seeds. These configure downstream qualification
// surfaces only; they contain no claimant facts and do not establish
// admissibility, privilege, waiver, or forum-specific entitlement.
reuseSeeds: close({
	"criminal-defence": #ValidatedReuseSeed & {
		id:              "criminal-defence"
		consumerProfile: {id: "criminal-defence"}
		purpose:         "statutory-assessment-support"
		candidateLayers: ["source-record", "clinical-expert-opinion"]
		note:            "Seed defence review from source records and private expert material while preserving the boundary to any court-ordered statutory assessment."
	}
	"civil-litigation": #ValidatedReuseSeed & {
		id:              "civil-litigation"
		consumerProfile: {id: "civil-litigation"}
		purpose:         "functional-capacity"
		candidateLayers: ["source-record", "clinical-expert-opinion", "filed-legal-material"]
		note:            "Seed a purpose-bound civil package; expert scope and forum qualification remain explicit gates."
	}
	"administrative-benefits": #ValidatedReuseSeed & {
		id:              "administrative-benefits"
		consumerProfile: {id: "administrative-benefits"}
		purpose:         "legal-qualification"
		candidateLayers: ["source-record", "clinical-expert-opinion", "filed-legal-material"]
		note:            "Seed reuse for a new administrative or benefits test without treating the IVAC legal test as portable."
	}
	"insurance-disability": #ValidatedReuseSeed & {
		id:              "insurance-disability"
		consumerProfile: {id: "insurance-disability"}
		purpose:         "functional-capacity"
		candidateLayers: ["source-record", "clinical-expert-opinion"]
		note:            "Seed disability or insurance qualification from the admitted clinical record while retaining contract-specific requalification."
	}
	"capacity-protective": #ValidatedReuseSeed & {
		id:              "capacity-protective"
		consumerProfile: {id: "capacity-protective"}
		purpose:         "capacity-assessment"
		candidateLayers: ["source-record", "clinical-expert-opinion"]
		note:            "Seed longitudinal baseline evidence without substituting prior expertise for a distinct statutory medical or psychosocial assessment."
	}
	"employment-human-rights": #ValidatedReuseSeed & {
		id:              "employment-human-rights"
		consumerProfile: {id: "employment-human-rights"}
		purpose:         "accommodation"
		candidateLayers: ["source-record", "clinical-expert-opinion"]
		note:            "Seed a narrow functional/accommodation package rather than exposing the master legal-medical corpus."
	}
	"family": #ValidatedReuseSeed & {
		id:              "family"
		consumerProfile: {id: "family"}
		purpose:         "functional-capacity"
		candidateLayers: ["source-record", "clinical-expert-opinion"]
		note:            "Seed a narrowly scoped family-law qualification with clinical and protection review before disclosure."
	}
})

portabilitySeed: #ValidatedPortabilityCase & {
	case: mockClinicalCase

	envelopes: {
		sourceRecord: {
			id:                 "sourceRecord"
			artifact:           {id: "sourceRecord"}
			layer:              "source-record"
			defaultDisposition: "direct-candidate"
			requiredGates:      ["purpose-scope", "forum-requalification"]
			potentialProtections: ["health-confidentiality"]
			authorityPreserved: true
		}
		expertReport: {
			id:                 "expertReport"
			artifact:           {id: "expertReport"}
			layer:              "clinical-expert-opinion"
			defaultDisposition: "requires-requalification"
			requiredGates:      ["purpose-scope", "clinical-scope", "forum-requalification", "counsel-protection-review"]
			potentialProtections: ["health-confidentiality", "litigation-privilege"]
			authorityPreserved: true
		}
		legalSubmission: {
			id:                 "legalSubmission"
			artifact:           {id: "legalSubmission"}
			layer:              "filed-legal-material"
			defaultDisposition: "supporting-candidate"
			requiredGates:      ["purpose-scope", "forum-requalification", "counsel-protection-review"]
			authorityPreserved: true
		}
		legalWorkProduct: {
			id:                 "legalWorkProduct"
			artifact:           {id: "legalWorkProduct"}
			layer:              "legal-work-product"
			defaultDisposition: "withhold-by-default"
			requiredGates:      ["purpose-scope", "counsel-protection-review"]
			potentialProtections: ["solicitor-client-privilege", "litigation-privilege"]
			authorityPreserved: true
		}
	}

	packages: {
		civilFunctionalCapacity: {
			id:              "civilFunctionalCapacity"
			consumerProfile: {id: "civil-litigation"}
			sourceWorld:     {id: "mock-world"}
			sourceProfile:   {id: "mock-profile"}
			purpose:         "functional-capacity"
			selectionMode:   "purpose-bound-subset"
			authority:       "derived-non-authoritative"
			state:           "counsel-reviewed"
			artifacts: [
				{
					artifact:    {id: "sourceRecord"}
					envelope:    {id: "sourceRecord"}
					disposition: "direct-candidate"
					decision:    "include"
					gates: {
						scopeReview:        "cleared"
						clinicalScope:      "not-applicable"
						forumQualification: "cleared"
						protectionReview:   "cleared"
					}
					rationale: "De-identified fixture: source record selected as primary factual support for the declared purpose."
				},
				{
					artifact:    {id: "expertReport"}
					envelope:    {id: "expertReport"}
					disposition: "requires-requalification"
					decision:    "include"
					gates: {
						scopeReview:        "cleared"
						clinicalScope:      "cleared"
						forumQualification: "cleared"
						protectionReview:   "cleared"
					}
					rationale: "De-identified fixture: expert material selected only after explicit scope, forum, and protection gates."
				},
				{
					artifact:    {id: "legalWorkProduct"}
					envelope:    {id: "legalWorkProduct"}
					disposition: "withhold-by-default"
					decision:    "exclude"
					gates: {
						scopeReview:        "cleared"
						clinicalScope:      "not-applicable"
						forumQualification: "not-applicable"
						protectionReview:   "blocked"
					}
					rationale: "De-identified fixture: counsel work product remains outside the derivative disclosure package."
				},
			]
			findings:  [{id: "primaryFunctional"}]
			relations: [{id: "episodeImpairsCapacity"}]
			note:      "Structural fixture showing asymmetric portability and explicit exclusion of legal work product."
		}
	}
}
