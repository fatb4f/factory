package ivac

import "time"

#RegulatoryDigest: string & =~"^sha256:[0-9a-f]{64}$"
#RegulatoryDate:   string & =~"^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"
#RegulatoryInterval: close({
	from:   #RegulatoryDate
	end:    "unknown" | "open" | "bounded"
	until?: #RegulatoryDate
	if end == "bounded" {
		until: #RegulatoryDate & >from
	}
	if end != "bounded" {until?: _|_}
})

// A snapshot identity is distinct from the provision's commencement and from
// a case-specific choice of applicable law. Unknown end is not repeal.
#RegulatorySourceVersion: {
	id:               #ID
	instrument:       string & !=""
	jurisdiction:     "CA-QC"
	language:         "fr"
	publisher:        string & !=""
	url:              string & =~"^https://"
	consolidatedAsOf: #RegulatoryDate
	retrievedAt:      time.Time
	contentKind:      "official" | "synthetic"
	mediaType:        "text/plain; charset=utf-8"
	snapshotDigest:   #RegulatoryDigest
	// Exact UTF-8 input; HTML/PDF conversion must be separately retained.
	snapshotPath: string & !=""
	origin: close({
		digest:     #RegulatoryDigest
		path:       string & !=""
		mediaType:  string & !=""
		conversion: string & !=""
	})
	provision: string & !=""
	effective: #RegulatoryInterval

	// Guard concrete instances; definitions remain usable for projection.
	if id != "" {
		_consolidatedDate: time.Parse("2006-01-02", consolidatedAsOf)
		_effectiveDate:    time.Parse("2006-01-02", effective.from)
		if effective.end == "bounded" {
			_endDate: time.Parse("2006-01-02", effective.until)
		}
	}
}

#RegulatoryCitation: close({
	sourceVersion: #ID
	locator:       string & !=""
	// Half-open Unicode code-point offsets in the pinned UTF-8 snapshot.
	start:     int & >=0
	end:       int & >start
	exactText: string & !=""
})

#RegulatoryCriterion: close({
	id:       #ID
	citation: #RegulatoryCitation
})

#RegulatoryAlternative: close({
	id: #ID
	// All criteria in an alternative are required; alternatives are OR paths.
	operator: "all-of"
	criteria: [#RegulatoryCriterion, ...#RegulatoryCriterion]
})

#RegulatoryPercentage:
	close({kind: "fixed", value: number & >=0 & <=100}) |
	close({kind: "range", minimum: number & >=0 & <=100, maximum: number & >=minimum & <=100}) |
	close({kind: "not-specified", reason: string & !=""})

#RegulatorySeverityClass: close({
	id:         #ID
	label:      string & !=""
	citation:   #RegulatoryCitation
	percentage: #RegulatoryPercentage
	// A percentage is a schedule value, never an award or an automatic finding.
	qualification: close({
		operator: "any-of"
		alternatives: [#RegulatoryAlternative, ...#RegulatoryAlternative]
	})
})

#RegulatoryUnit: close({
	id:            #ID
	number:        string & !=""
	label:         string & !=""
	kind:          "functional" | "aesthetic"
	parentNumber?: string & !=""
	citation:      #RegulatoryCitation
	// Rules are retained independently of qualifying paths.
	evaluationRules: [...#RegulatoryCitation]
	classes: [string]: #RegulatorySeverityClass
})

#RegulatoryCompendium: close({
	id:           #ID
	source:       #RegulatorySourceVersion
	coverage:     "partial" | "complete"
	coverageNote: string & !=""
	review: close({
		state:     "candidate" | "reviewed"
		reviewer?: string & !=""
		rationale: string & !=""
		if state == "reviewed" {reviewer: string & !=""}
	})
	units: [string]: #RegulatoryUnit
	// Explicit matches prove existence even for open CUE dictionaries.
	_unitIntegrity: [for id, u in units {
		let expectedUnitID = id
		_identity: u & {id: expectedUnitID}
		_citation: u.citation & {sourceVersion: source.id}
		_rules: [for c in u.evaluationRules {c & {sourceVersion: source.id}}]
		_classes: [for cid, c in u.classes {
			let expectedClassID = cid
			_identity: c & {id: expectedClassID}
			_citation: c.citation & {sourceVersion: source.id}
			_alternatives: [for i, a in c.qualification.alternatives {
				_unique: [for j, b in c.qualification.alternatives if a.id == b.id {j}] & [i]
				_criteria: [for k, criterion in a.criteria {
					_citation: criterion.citation & {sourceVersion: source.id}
					_unique: [for l, other in a.criteria if criterion.id == other.id {l}] & [k]
				}]
			}]
		}]
	}]
})

// Extraction produces candidates only. Admission is a separate, reviewed input.
#RegulatoryExtraction: close({
	format:       "ivac.regulatory-extraction/v1"
	status:       "candidate"
	sourceDigest: #RegulatoryDigest
	adapter:      "utf8-spans/v1"
	spans: [#RegulatoryCitation, ...#RegulatoryCitation]
})

regulatoryContract: close({
	id:           "personal.ivac.regulatory"
	version:      "1.0.0"
	extends:      "personal.ivac@0.4.0"
	authority:    "cue"
	sourceStatus: "identified-not-ingested"
	canonicalRoots: ["#RegulatorySourceVersion", "#RegulatoryCompendium"]
	qualificationRoot: "ivaceval.#RegulatoryQualification"
	projectionTargets: ["json-schema", "pydantic-v2", "relational", "ibis"]
})
