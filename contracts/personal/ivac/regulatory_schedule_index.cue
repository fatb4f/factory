package ivac

// A source navigation index. Occurrences are not classes, percentages are not
// awards, and an "ou" occurrence does not establish the scope of an alternative.
#RegulatoryScheduleIndex: {
	format: "ivac.regulatory-schedule-index/v1"
	status: "candidate"
	acquisition: #RegulatoryAcquisition & {publicationKind: "enacted-regulation"}
	semantics:         "pending-review"
	caseApplicability: "unresolved"
	globalRules: [#RegulatorySourceSpan, ...#RegulatorySourceSpan]
	sections: [close({
		number: string & !=""
		// Ordered, contiguous pieces partition the entire source section.
		pieces: [close({
			id:   #ID
			role: "section-context" | "unit-body" | "shared-schedule"
			unitNumbers: [string & !="", ...(string & !="")]
			citation: #RegulatorySourceSpan
		}), ...]
	}), ...]
	units: [close({
		number:  string & !=""
		kind:    "functional" | "aesthetic"
		label:   #RegulatorySourceSpan
		section: string & !=""
		pieceIDs: [#ID, ...#ID]
	}), ...]
	occurrences: [...close({
		id:       #ID
		pieceID:  #ID
		kind:     "severity" | "percentage" | "alternative" | "evaluation-rules"
		citation: #RegulatorySourceSpan
	})]
	if acquisition.id != "" {
		_unitCount: len(units) & 48
		_functional: len([for u in units if u.kind == "functional" {u}]) & 40
		_aesthetic: len([for u in units if u.kind == "aesthetic" {u}]) & 8
		_sectionCount: len(sections) & 25
		_versions: [for s in sections for p in s.pieces {p.citation & {sourceVersion: acquisition.id}}]
		_globalVersions: [for r in globalRules {r & {sourceVersion: acquisition.id}}]
		_labels: [for u in units {u.label & {sourceVersion: acquisition.id}}]
		_occurrences: [for o in occurrences {
			_version: o.citation & {sourceVersion: acquisition.id}
			_matches: [for s in sections for p in s.pieces if p.id == o.pieceID {p}] & [_, ...]
		}]
		_references: [for u in units for ref in u.pieceIDs {
			_matches: [for s in sections for p in s.pieces if p.id == ref {p}] & [_, ...]
		}]
	}
}

#RegulatoryScheduleOccurrenceRow: close({
	sourceVersion: #ID
	unitNumber:    string & !=""
	unitKind:      "functional" | "aesthetic"
	occurrenceID:  #ID
	pieceID:       #ID
	kind:          "severity" | "percentage" | "alternative" | "evaluation-rules"
	semantics:     "pending-review"
	locator:       string & !=""
	start:         int & >=0
	end:           int & >=1
	exactText:     string & !=""
})

regulatoryRowSchemas: scheduleOccurrence: #RegulatoryScheduleOccurrenceRow
