package cyberincidents

import "list"

// Both streams use #Acquisition as input to #IncidentBundle. Their original
// project brief is in projects/cyber-incidents/README.md.
watchStreams: {
	primary:   "global-major-cyber"
	secondary: "canadian-surveillance"
}

#EvidenceCitation: {
	captureID: #ID
	selector:  #Text // Page, paragraph, JSON pointer, or stable object locator.
}

#ExternalRef: {
	catalog: "stix" | "misp" | "mitre-attack" | "disarm"
	id:      #Text
	version: #Text
}

#Assertion: {
	summary:  #Text
	knownAt:  #UTC
	eventAt?: #UTC
	citations: [#EvidenceCitation, ...#EvidenceCitation]
	references?: [...#ExternalRef]
}

#PublicClaim: {
	#Assertion
	rail:      "public"
	claimKind: "reporting" | "official-statement" | "correction"
}

#TechnicalObservation: {
	#Assertion
	rail:        "technical"
	findingKind: "detection" | "indicator" | "impact" | "containment" | "forensic-finding"
}

#Hypothesis: {
	rail:        "strategic"
	proposition: #Text
	category:    "objective" | "actor" | "sponsorship" | "playbook-resemblance"
	assessedAt:  #UTC
	state:       "candidate" | "disputed" | "insufficient-evidence"
	evidence: [...{
		rail:        "public" | "technical"
		assertionID: #ID
		relation:    "supports" | "contradicts" | "context"
	}]
	nextEvidence: [#Text, ...#Text]
}

#Unknown: {
	state:  "unknown" | "not-publicly-disclosed" | "under-investigation"
	reason: #Text
}

#Incident: {
	id:           #ID
	stream:       watchStreams.primary | watchStreams.secondary
	title:        #Text
	catalogDate?: #CatalogDate
	publicClaims: [#ID]:          #PublicClaim
	technicalObservations: [#ID]: #TechnicalObservation
	hypotheses: [#ID]:            #Hypothesis
	openQuestions: [#ID]:         #Unknown
}

#IncidentBundle: {
	schema:      "factory.cyber-incidents.bundle/v0.1"
	acquisition: #Acquisition
	incident:    #Incident
	view: {
		mode: "review" | "historical-replay"
		if mode == "historical-replay" {
			asOf: #UTC
		}
	}
	let assertions = list.Concat([
		[for _, a in incident.publicClaims {a}],
		[for _, a in incident.technicalObservations {a}],
	])
	let captureIDs = [for id, _ in acquisition.captures {id}]
	let publicIDs = [for id, _ in incident.publicClaims {id}]
	if incident.catalogDate != _|_ {
		_catalogClaimResolves: true & list.Contains(publicIDs, incident.catalogDate.publicClaimID)
	}
	let technicalIDs = [for id, _ in incident.technicalObservations {id}]
	for a in assertions {
		for ref in a.citations {
			let capture = acquisition.captures[ref.captureID]
			_citationsResolve: true & list.Contains(captureIDs, ref.captureID)
			if capture.availability.state == "documented" {
				_claimOrder: true & (capture.availability.at <= a.knownAt)
			}
			if view.mode == "historical-replay" {
				_citationDated: true & (capture.availability.state == "documented")
			}
		}
		if view.mode == "historical-replay" {
			_replayCutoff: true & (a.knownAt <= view.asOf)
		}
	}
	for _, h in incident.hypotheses {
		if view.mode == "historical-replay" {
			_replayAssessmentCutoff: true & (h.assessedAt <= view.asOf)
		}
		for link in h.evidence {
			if link.rail == "public" {
				_hypothesisPublicRef: true & list.Contains(publicIDs, link.assertionID)
				let claim = incident.publicClaims[link.assertionID]
				_hypothesisPublicOrder: true & (claim.knownAt <= h.assessedAt)
			}
			if link.rail == "technical" {
				_hypothesisTechnicalRef: true & list.Contains(technicalIDs, link.assertionID)
				let observation = incident.technicalObservations[link.assertionID]
				_hypothesisTechnicalOrder: true & (observation.knownAt <= h.assessedAt)
			}
		}
	}
}
