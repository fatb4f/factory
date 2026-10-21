package ivac

import "time"

// Acquisition and serialization are evidence about source bytes, not statutory
// qualification. Only #RegulatoryCompendium owns normalized regulatory meaning.
#RegulatoryAcquisition: close({
	id:               #ID
	url:              string & =~"^https://www\\.(publicationsduquebec|legisquebec)\\.gouv\\.qc\\.ca/"
	retrievedAt:      time.Time
	publicationDate:  #RegulatoryDate
	publicationKind:  "enacted-regulation" | "enacted-act" | "proposal"
	artifactPath:     string & !=""
	artifactDigest:   #RegulatoryDigest
	artifactBytes:    int & >0
	mediaType:        "application/pdf"
	textPath:         string & !=""
	textDigest:       #RegulatoryDigest
	conversion:       "pdftotext -layout -enc UTF-8"
	converterVersion: string & !=""
	legalEffect:      "initial-enactment" | "not-established"
	if publicationKind == "proposal" {legalEffect: "not-established"}
})

#RegulatorySourceSpan: #RegulatoryCitation

#RegulatorySourceSection: close({
	number:  string & !=""
	heading: #RegulatorySourceSpan
	text:    #RegulatorySourceSpan
})

#RegulatoryLeafInventory: close({
	number:  string & !=""
	kind:    "functional" | "aesthetic"
	label:   #RegulatorySourceSpan
	section: string & !=""
})

#RegulatoryHistoryAudit: {
	format: "ivac.regulatory-history-audit/v1"
	status: "incomplete"
	asOf:   #RegulatoryDate
	artifacts: [string]: #RegulatoryAcquisition
	findings: [close({
		id:             #ID
		kind:           "commencement" | "transitional-provision" | "proposal"
		citation:       #RegulatorySourceSpan
		interpretation: string & !=""
		legalEffect:    "initial-text-only" | "not-established"
		if kind == "proposal" {legalEffect: "not-established"}
	}), ...]
	unresolved: [string & !="", ...(string & !="")]
	caseApplicability: "unresolved"
	if asOf != "" {
		_date: time.Parse("2006-01-02", asOf)
		_references: [for f in findings {
			_matches: [for id, a in artifacts if id == f.citation.sourceVersion {a}] & [_, ...]
		}]
		_identities: [for id, a in artifacts {
			let expectedID = id
			a & {id: expectedID}
		}]
	}
}

// A complete byte/text inventory does NOT assert complete semantic mapping.
// This deliberately cannot be passed to #RegulatoryQualification as a compendium.
#RegulatorySerializationCandidate: {
	format: "ivac.regulatory-serialization/v1"
	status: "candidate"
	acquisition: #RegulatoryAcquisition & {publicationKind: "enacted-regulation"}
	annex:    #RegulatorySourceSpan
	contents: #RegulatorySourceSpan
	sections: [#RegulatorySourceSection, ...#RegulatorySourceSection]
	units: [#RegulatoryLeafInventory, ...#RegulatoryLeafInventory]
	globalRules: [#RegulatorySourceSpan, ...#RegulatorySourceSpan]
	// Lexical occurrences, not interpreted conditions, rates, or class rows.
	markers: [...close({
		kind:     "severity" | "percentage" | "alternative" | "evaluation-rules"
		citation: #RegulatorySourceSpan
	})]
	coverage: close({
		text:              "complete-annex-partition"
		semantics:         "pending-review"
		amendmentHistory:  "incomplete"
		caseApplicability: "unresolved"
	})
	blockers: [string & !="", ...(string & !="")]
	if acquisition.id != "" {
		_unitCount: len(units) & (regulatorySourceInventory.functionalUnits + regulatorySourceInventory.aestheticUnits)
		_functionalCount: len([for u in units if u.kind == "functional" {u}]) & regulatorySourceInventory.functionalUnits
		_aestheticCount: len([for u in units if u.kind == "aesthetic" {u}]) & regulatorySourceInventory.aestheticUnits
		_sectionCount: len(sections) & (regulatorySourceInventory.functionalHeadings + 1)
		_annexVersion: annex & {sourceVersion: acquisition.id}
		_contentsVersion: contents & {sourceVersion: acquisition.id}
		_sectionVersions: [for s in sections {
			_heading: s.heading & {sourceVersion: acquisition.id}
			_text: s.text & {sourceVersion: acquisition.id}
		}]
		_unitVersions: [for u in units {u.label & {sourceVersion: acquisition.id}}]
		_globalVersions: [for s in globalRules {s & {sourceVersion: acquisition.id}}]
		_markerVersions: [for m in markers {m.citation & {sourceVersion: acquisition.id}}]
	}
}
