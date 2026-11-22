package ivac

// Demonstrated gap: a compendium records a selected decomposition, not competing
// legal readings, counterauthority or unresolved scope. These are research
// annotations only; they cannot be supplied as #RegulatoryCompendium or as a
// clinical/adjudicative finding. None of the proposed legal readings is admitted.
#InterpretationSourceAnchor: close({
	artifactID:         #ID
	artifactDigest:     #RegulatoryDigest
	citation:           #RegulatoryCitation
	versionDescription: string & !=""
})
#InterpretationAuthorityReference: close({
	id:              #ID
	url:             string & =~"^https://"
	citation:        string & !=""
	kind:            "statute" | "regulation" | "decision" | "administrative-policy" | "unverified-lead"
	weight:          "binding-text-subject-to-applicability" | "persuasive-not-binding" | "policy-only" | "not-relied-on"
	verification:    "original-bytes-inspected" | "lead-only"
	artifactDigest?: #RegulatoryDigest
	notes:           string & !=""
	if verification == "original-bytes-inspected" {artifactDigest: #RegulatoryDigest}
	if verification == "lead-only" {weight: "not-relied-on"}
})
#RegulatoryInterpretationOpportunity: close({
	opportunityID: #ID
	priority:      "p1" | "p2" | "p3"
	legalSource: [#InterpretationSourceAnchor, ...#InterpretationSourceAnchor]
	semanticIssue:      string & !=""
	claimantReading:    string & !=""
	restrictiveReading: string & !=""
	legalSupport: [string & !="", ...(string & !="")]
	counterAuthority: [string & !="", ...(string & !="")]
	clinicalPrerequisites: [string & !="", ...(string & !="")]
	evidenceRequired: [string & !="", ...(string & !="")]
	coverageGaps: [string & !="", ...(string & !="")]
	potentialImpact:    string & !=""
	confidence:         "supported" | "plausible" | "speculative" | "contradicted"
	clinicalConfidence: "not-assessed"
	reviewStatus:       "candidate" | "unresolved" | "rejected"
	adjudication:       "not-determined"
	prioritization: close({
		legalSupport:                 "express-text" | "textual-inference" | "unverified"
		evidentiaryFeasibility:       "professional-records" | "historical-records" | "specialist-comparison"
		materiality:                  "classification" | "calculation" | "process" | "applicability"
		counterargumentVulnerability: "low" | "medium" | "high"
	})
})
#RegulatoryInterpretationScenario: close({
	scenarioID:    #ID
	opportunityID: #ID
	facts: [string & !="", ...(string & !="")]
	claimantOutput:     string & !=""
	restrictiveOutput:  string & !=""
	divergence:         string & !=""
	resolutionEvidence: string & !=""
	decisionBoundary:   "unresolved-no-automatic-selection"
	synthetic:          true
	adjudication:       "not-determined"
})
#RegulatoryInterpretationResearch: {
	format:    "ivac.regulatory-interpretation-research/v1"
	status:    "candidate-partial"
	authority: "none"
	sourceArtifacts: [string]: close({
		artifactDigest:   #RegulatoryDigest
		snapshotDigest:   #RegulatoryDigest
		coordinateSystem: "unicode-codepoints-in-pinned-utf8-snapshot"
	})
	authorities: [string]: #InterpretationAuthorityReference
	opportunities: [#RegulatoryInterpretationOpportunity, ...#RegulatoryInterpretationOpportunity]
	scenarios: [#RegulatoryInterpretationScenario, ...#RegulatoryInterpretationScenario]
	coverage: close({
		functionalUnitLabels:      40
		aestheticUnitLabels:       8
		rubricSourceAnchors:       25
		exhaustiveClassPathReview: false
		independentLegalReview:    false
		jurisprudenceCoverage:     "partial"
	})
	if opportunities[0].opportunityID != "" {
		_opportunities: [for i, o in opportunities {
			_unique: [for j, other in opportunities if other.opportunityID == o.opportunityID {j}] & [i]
			_sources: [for s in o.legalSource {
				_matches: [for id, a in sourceArtifacts if id == s.artifactID {
					a & {artifactDigest: s.artifactDigest}
				}] & [_, ...]
				_version: s.citation & {sourceVersion: s.artifactID}
			}]
		}]
		_scenarios: [for i, s in scenarios {
			_unique: [for j, other in scenarios if other.scenarioID == s.scenarioID {j}] & [i]
			_matches: [for o in opportunities if o.opportunityID == s.opportunityID {o}] & [_, ...]
		}]
	}
}

// Qualified implementation of these mechanical stages is downstream of legal
// version selection, clinical classification, exclusions and baseline review.
regulatoryArithmeticPolicy: close({
	id:                                "ivac-article-26-initial-text-candidate"
	status:                            "candidate-not-admitted"
	percentageBase:                    100
	bilateralDivisor:                  8
	bilateralMinimum:                  0.5
	bilateralFirstDecimal:             "truncate"
	bilateralResult:                   "raise-first-decimal-to-next-half-or-integer"
	bilateralCap:                      "less-affected-side-total"
	bilateralCapRoundingOrder:         "unresolved-require-explicit-selection"
	residualOrder:                     "descending"
	residualContributionDecimalPlaces: 2
	residualContributionRounding:      "half-up"
	globalRoundingWhenMultipleRates:   "ceiling-integer"
	unknownBaseline:                   "unresolved-never-zero"
	negativeDifference:                "unresolved-never-clamp"
	moneyCalculation:                  "not-implemented"
})

#InterpretationComparisonRow: close({
	sourceVersion:        #ID
	scenarioID:           #ID
	opportunityID:        #ID
	claimantCandidate:    bool
	restrictiveCandidate: bool
	comparisonKind:       "genuine-scope-dispute" | "overrestriction-regression"
	decisionBoundary:     "unresolved-no-automatic-selection"
})

// Projected research transport only; still no admitted interpretation or result.
regulatoryRowSchemas: {
	interpretationScenario:   #RegulatoryInterpretationScenario
	interpretationComparison: #InterpretationComparisonRow
}

// These expressions are explicit candidate readings or intentionally invalid
// overrestriction regressions, never production legal-selection predicates.
regulatoryInterpretationScenarioPrograms: [
	{
		scenarioID:     "synthetic-psychiatric-or-cognitive"
		opportunityID:  "ivac-interpretation-psychiatric-or-cognitive"
		comparisonKind: "genuine-scope-dispute"
		facts: {psychiatric: true, cognitive: false, support: false}
		claimantExpression:    "psychiatric or (cognitive and support)"
		restrictiveExpression: "(psychiatric or cognitive) and support"
	},
	{
		scenarioID:     "synthetic-cognitive-support-necessity"
		opportunityID:  "ivac-interpretation-cognitive-support-necessity"
		comparisonKind: "overrestriction-regression"
		facts: {substantial: true, assistanceJustifiable: true, assistanceReceived: false}
		claimantExpression:    "substantial and assistanceJustifiable"
		restrictiveExpression: "substantial and assistanceReceived"
	},
	{
		scenarioID:     "synthetic-medication-independent-path"
		opportunityID:  "ivac-interpretation-medication-independent-path"
		comparisonKind: "overrestriction-regression"
		facts: {permanentNecessaryRelatedMedication: true, symptomatic: false}
		claimantExpression:    "permanentNecessaryRelatedMedication"
		restrictiveExpression: "permanentNecessaryRelatedMedication and symptomatic"
	},
	{
		scenarioID:     "synthetic-separate-sensory-hand"
		opportunityID:  "ivac-interpretation-separate-sensory-hand"
		comparisonKind: "overrestriction-regression"
		facts: {independentSensory: true, independentDexterity: true, sameDiagnosis: true, excluded: false}
		claimantExpression:    "independentSensory and independentDexterity and not excluded"
		restrictiveExpression: "independentSensory and independentDexterity and not excluded and not sameDiagnosis"
	},
	{
		scenarioID:     "synthetic-restriction-vs-motion"
		opportunityID:  "ivac-interpretation-restriction-vs-motion"
		comparisonKind: "overrestriction-regression"
		facts: {weightedRoute: false, prescribedRestrictionRoute: true}
		claimantExpression:    "weightedRoute or prescribedRestrictionRoute"
		restrictiveExpression: "weightedRoute"
	},
	{
		scenarioID:     "synthetic-covered-static-scar"
		opportunityID:  "ivac-interpretation-covered-static-scar"
		comparisonKind: "overrestriction-regression"
		facts: {apparentAt50cm: true, covered: true, dynamic: false}
		claimantExpression:    "apparentAt50cm and not dynamic"
		restrictiveExpression: "apparentAt50cm and not dynamic and not covered"
	},
	{
		scenarioID:     "synthetic-endocrine-preventive-alternative"
		opportunityID:  "ivac-interpretation-endocrine-preventive-alternative"
		comparisonKind: "overrestriction-regression"
		facts: {necessaryPermanentPrevention: true, medication: false}
		claimantExpression:    "necessaryPermanentPrevention or medication"
		restrictiveExpression: "necessaryPermanentPrevention and medication"
	},
	{
		scenarioID:     "synthetic-clinical-objectivity-not-imaging"
		opportunityID:  "ivac-interpretation-clinical-objectivity-not-imaging"
		comparisonKind: "overrestriction-regression"
		facts: {recognizedObjectiveClinicalFindings: true, abnormalImaging: false}
		claimantExpression:    "recognizedObjectiveClinicalFindings"
		restrictiveExpression: "recognizedObjectiveClinicalFindings and abnormalImaging"
	},
]
