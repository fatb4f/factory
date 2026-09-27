package ivac

// De-identified normalized evidence/profile fixture. It demonstrates the
// subject-evidence graph without encoding any real claimant facts.
mockClinicalCase: #ValidatedCasePlant & {
	review: mockReviewPlant

	world: {
		id:      "mock-world"
		subject: {id: "claimant"}
		evidence: [{id: "expertReport"}]

		observations: {
			functionalFailure: {
				id:              "functionalFailure"
				kind:            "clinical-observation"
				observationKind: "functional-failure"
				subject:         {id: "claimant"}
				concept:         "sustained structured obligation"
				value:           {kind: "categorical", value: "recurrent-failure"}
				temporal:        {status: "unknown"}
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
			supportDependency: {
				id:              "supportDependency"
				kind:            "clinical-observation"
				observationKind: "support-dependency"
				subject:         {id: "claimant"}
				concept:         "external structure"
				value:           {kind: "categorical", value: "recurring-support-required"}
				temporal:        {status: "unknown"}
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
		}

		episodes: {
			failureEpisode: {
				id:          "failureEpisode"
				kind:        "clinical-episode"
				episodeKind: "mixed"
				subject:     {id: "claimant"}
				label:       "de-identified functional failure episode"
				temporal:    {status: "unknown"}
				members:     [{id: "functionalFailure"}, {id: "supportDependency"}]
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
		}

		interventions: {
			humanSupport: {
				id:               "humanSupport"
				kind:             "clinical-intervention"
				interventionKind: "human-support"
				subject:          {id: "claimant"}
				label:            "de-identified recurring external support"
				state:            "active"
				temporal:         {status: "unknown"}
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
		}

		capacities: {
			structuredObligation: {
				id:       "structuredObligation"
				kind:     "capacity-assessment"
				subject:  {id: "claimant"}
				domain:   "administrative"
				label:    "sustain structured obligations"
				state:    "unreliable"
				temporal: {status: "unknown"}
				support:  [{id: "humanSupport"}]
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
		}

		relations: {
			documentsFailure: {
				id:            "documentsFailure"
				kind:          "clinical-relation"
				subject:       {kind: "evidence-artifact", id: "expertReport"}
				predicate:     "documents"
				object:        {kind: "observation", id: "functionalFailure"}
				assertionMode: "source-documented"
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
			episodeImpairsCapacity: {
				id:            "episodeImpairsCapacity"
				kind:          "clinical-relation"
				subject:       {kind: "episode", id: "failureEpisode"}
				predicate:     "impairs"
				object:        {kind: "capacity", id: "structuredObligation"}
				assertionMode: "clinician-attributed"
				attributedBy:  {id: "independentExpert"}
				provenance: {
					basis:      "clinician-assessment"
					evidence:   [{id: "expertReport"}]
					assertedBy: {id: "independentExpert"}
				}
			}
		}
	}

	profile: {
		id:          "mock-profile"
		kind:        "normalized-subject-profile"
		subject:     {id: "claimant"}
		sourceWorld: {id: "mock-world"}
		asOf:        {value: "fixture", precision: "unknown"}
		projection: {
			state:         "derived"
			deterministic: true
			authority:     "none"
			sourceOfTruth: "evidence-world"
		}
		partitions: {
			conditions:        []
			symptoms:          []
			functionalEvents:  [{id: "functionalFailure"}]
			substanceUse:      []
			sleep:             []
			objectiveTests:    []
			supportDependency: [{id: "supportDependency"}]
			context:           []
		}
		episodes:      [{id: "failureEpisode"}]
		capacities:    [{id: "structuredObligation"}]
		interventions: [{id: "humanSupport"}]
		relations:     [{id: "documentsFailure"}, {id: "episodeImpairsCapacity"}]
		evidence:      [{id: "expertReport"}]
	}
}
