package ivac

#PortabilityProfileID: #ID
#ArtifactEnvelopeID: #ID
#DerivativePackageID: #ID
#ReuseSeedID: #ID

#ReuseConsumerProfileRef: close({id: #PortabilityProfileID})
#ArtifactEnvelopeRef: close({id: #ArtifactEnvelopeID})
#DerivativePackageRef: close({id: #DerivativePackageID})

#ForumKind:
	"criminal" |
	"civil" |
	"administrative-benefits" |
	"insurance-disability" |
	"capacity-protective" |
	"employment-human-rights" |
	"family" |
	"other"

#ArtifactLayer:
	"source-record" |
	"clinical-expert-opinion" |
	"filed-legal-material" |
	"privileged-legal-work-product"

#ReusePurpose:
	"fact-corroboration" |
	"clinical-interpretation" |
	"causation" |
	"functional-capacity" |
	"legal-qualification" |
	"statutory-assessment-support" |
	"damages" |
	"accommodation" |
	"capacity-assessment" |
	"litigation-strategy" |
	"other"

#DisclosureGate:
	"purpose-scope" |
	"clinical-scope" |
	"forum-requalification" |
	"counsel-protection-review"

#PortabilityDisposition:
	"direct-candidate" |
	"supporting-candidate" |
	"requires-requalification" |
	"withhold-by-default" |
	"excluded"

#PotentialProtection:
	"health-confidentiality" |
	"solicitor-client-privilege" |
	"litigation-privilege" |
	"other"

#GateState: "pending" | "cleared" | "not-applicable" | "blocked"
#SelectionDecision: "include" | "exclude" | "defer"
#DerivativePackageState: "candidate" | "counsel-reviewed" | "released"

#ArtifactEnvelope: close({
	id:                 #ArtifactEnvelopeID
	artifact:           #EvidenceArtifactRef
	layer:              #ArtifactLayer
	defaultDisposition: #PortabilityDisposition
	requiredGates:      [#DisclosureGate, ...#DisclosureGate]
	potentialProtections?: [...#PotentialProtection]
	authorityPreserved: true
	note?:              string
})

#ArtifactPortabilityRule: close({
	layer:         #ArtifactLayer
	disposition:   #PortabilityDisposition
	requiredGates: [#DisclosureGate, ...#DisclosureGate]
	note?:         string
})

#ReuseConsumerProfile: close({
	id:                    #PortabilityProfileID
	forum:                 #ForumKind
	purposes:              [#ReusePurpose, ...#ReusePurpose]
	rules:                 [#ArtifactPortabilityRule, ...#ArtifactPortabilityRule]
	selectionMode:         "purpose-bound-subset"
	wholeCorpusByDefault:  false
	admissibility:         "not-determined"
	authority:             "consumer-specific-qualification"
	requiresPurposeRecord: true
	note?:                 string
})

#ArtifactGateDecision: close({
	scopeReview:       #GateState
	clinicalScope:     #GateState
	forumQualification:#GateState
	protectionReview:  #GateState
})

#DerivativeArtifactSelection: close({
	artifact:    #EvidenceArtifactRef
	envelope:    #ArtifactEnvelopeRef
	disposition: #PortabilityDisposition
	decision:    #SelectionDecision
	gates:       #ArtifactGateDecision
	rationale:   string & !=""

	if decision == "include" {
		gates: {
			scopeReview:        "cleared"
			clinicalScope:      "cleared" | "not-applicable"
			forumQualification: "cleared" | "not-applicable"
			protectionReview:   "cleared" | "not-applicable"
		}
	}
})

#DerivativePackage: close({
	id:              #DerivativePackageID
	consumerProfile: #ReuseConsumerProfileRef
	sourceWorld:     #EvidenceWorldRef
	sourceProfile:   #SubjectProfileRef
	purpose:         #ReusePurpose
	selectionMode:   "purpose-bound-subset"
	authority:       "derived-non-authoritative"
	state:           #DerivativePackageState
	artifacts:       [#DerivativeArtifactSelection, ...#DerivativeArtifactSelection]
	findings?:       [...#FindingRef]
	relations?:      [...#ClinicalRelationRef]
	note?:           string
})

#ReuseSeed: close({
	id:              #ReuseSeedID
	consumerProfile: #ReuseConsumerProfileRef
	purpose:         #ReusePurpose
	candidateLayers: [#ArtifactLayer, ...#ArtifactLayer]
	note:            string & !=""
})

reuseProfiles: close({
	"criminal-defence": #ReuseConsumerProfile & {
		id:      "criminal-defence"
		forum:   "criminal"
		purposes: ["fact-corroboration", "clinical-interpretation", "functional-capacity", "statutory-assessment-support", "litigation-strategy"]
		rules: [
			{layer: "source-record", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification"]},
			{layer: "clinical-expert-opinion", disposition: "requires-requalification", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
		note: "A private psychiatric expertise may support defence analysis or an application for a forum-specific assessment; this profile never treats it as a substitute for a statutory court-ordered assessment."
	}
	"civil-litigation": #ReuseConsumerProfile & {
		id:      "civil-litigation"
		forum:   "civil"
		purposes: ["fact-corroboration", "clinical-interpretation", "causation", "functional-capacity", "damages", "litigation-strategy"]
		rules: [
			{layer: "source-record", disposition: "direct-candidate", requiredGates: ["purpose-scope", "forum-requalification"]},
			{layer: "clinical-expert-opinion", disposition: "requires-requalification", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
	}
	"administrative-benefits": #ReuseConsumerProfile & {
		id:      "administrative-benefits"
		forum:   "administrative-benefits"
		purposes: ["fact-corroboration", "clinical-interpretation", "functional-capacity", "legal-qualification", "accommodation"]
		rules: [
			{layer: "source-record", disposition: "direct-candidate", requiredGates: ["purpose-scope"]},
			{layer: "clinical-expert-opinion", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
	}
	"insurance-disability": #ReuseConsumerProfile & {
		id:      "insurance-disability"
		forum:   "insurance-disability"
		purposes: ["fact-corroboration", "clinical-interpretation", "functional-capacity", "causation"]
		rules: [
			{layer: "source-record", disposition: "direct-candidate", requiredGates: ["purpose-scope"]},
			{layer: "clinical-expert-opinion", disposition: "requires-requalification", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
	}
	"capacity-protective": #ReuseConsumerProfile & {
		id:      "capacity-protective"
		forum:   "capacity-protective"
		purposes: ["fact-corroboration", "clinical-interpretation", "functional-capacity", "capacity-assessment"]
		rules: [
			{layer: "source-record", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification"]},
			{layer: "clinical-expert-opinion", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
		note: "Prior expertise may provide longitudinal baseline evidence; this profile does not treat it as the statutory medical or psychosocial assessment required by a separate protective regime."
	}
	"employment-human-rights": #ReuseConsumerProfile & {
		id:      "employment-human-rights"
		forum:   "employment-human-rights"
		purposes: ["fact-corroboration", "functional-capacity", "accommodation", "legal-qualification"]
		rules: [
			{layer: "source-record", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification"]},
			{layer: "clinical-expert-opinion", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
	}
	"family": #ReuseConsumerProfile & {
		id:      "family"
		forum:   "family"
		purposes: ["fact-corroboration", "clinical-interpretation", "functional-capacity"]
		rules: [
			{layer: "source-record", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification"]},
			{layer: "clinical-expert-opinion", disposition: "requires-requalification", requiredGates: ["purpose-scope", "clinical-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "filed-legal-material", disposition: "supporting-candidate", requiredGates: ["purpose-scope", "forum-requalification", "counsel-protection-review"]},
			{layer: "privileged-legal-work-product", disposition: "withhold-by-default", requiredGates: ["purpose-scope", "counsel-protection-review"]},
		]
		selectionMode:         "purpose-bound-subset"
		wholeCorpusByDefault: false
		admissibility:        "not-determined"
		authority:            "consumer-specific-qualification"
		requiresPurposeRecord: true
	}
})

#PortabilityCase: close({
	case:      #ValidatedCasePlant
	envelopes: [string]: #ArtifactEnvelope
	packages:  [string]: #DerivativePackage
})

#ValidatedPortabilityCase: close({
	case:      #ValidatedCasePlant
	envelopes: [string]: #ArtifactEnvelope
	packages:  [string]: #DerivativePackage

	_envelopeIntegrity: [for id, envelope in envelopes {
		_value:    envelope & {id: id}
		_artifact: case.review.evidence[envelope.artifact.id]
	}]

	_packageIntegrity: [for id, pkg in packages {
		_value:   pkg & {id: id}
		_world:   pkg.sourceWorld & {id: case.world.id}
		_profile: pkg.sourceProfile & {id: case.profile.id}

		_consumerMatches: [for profileID, consumer in reuseProfiles if profileID == pkg.consumerProfile.id {
			consumer & {id: profileID}
		}] & [_, ...]
		_consumer: _consumerMatches[0]

		_purposeMatches: [for purpose in _consumer.purposes if purpose == pkg.purpose {
			purpose
		}] & [_, ...]

		_artifacts: [for selected in pkg.artifacts {
			_artifact: case.review.evidence[selected.artifact.id]
			_envelopeMatches: [for envelopeID, envelope in envelopes if envelopeID == selected.envelope.id {
				envelope & {id: envelopeID, artifact: selected.artifact}
			}] & [_, ...]
			_envelope: _envelopeMatches[0]

			_ruleMatches: [for rule in _consumer.rules if rule.layer == _envelope.layer {
				rule
			}] & [_, ...]
			_rule: _ruleMatches[0]
			_disposition: selected.disposition & _rule.disposition

			if selected.decision == "include" {
				_eligible: _rule & {
					disposition: "direct-candidate" | "supporting-candidate" | "requires-requalification"
				}
			}
		}]

		if pkg.findings != _|_ {
			_findings: [for ref in pkg.findings {
				_finding: case.review.findings[ref.id]
			}]
		}

		if pkg.relations != _|_ {
			_relations: [for ref in pkg.relations {
				_relation: case.world.relations[ref.id]
			}]
		}
	}]
})
