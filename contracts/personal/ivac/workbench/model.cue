package ivacworkbench

import (
	"time"
	ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"
	ivaceval "github.com/fatb4f/factory/contracts/personal/ivac/evaluations:ivaceval"
)

// Workbench owns assembly, traceability and coverage, not new clinical/legal
// qualification semantics. Existing domain objects are embedded without copying.
#DateObservation: close({state: "unknown", reason: string & !=""}) | close({
	state: "recorded"
	value: ivac.#RegulatoryDate
})

#CorpusVersion: {
	source:          ivac.#RegulatorySourceVersion
	publicationKind: "enacted-act" | "enacted-regulation" | "proposal" | "unknown"
	publicationDate: #DateObservation
	// Publisher provision-version label, distinct from publication/consolidation.
	provisionVersion: close({state: "unknown", reason: string & !=""}) | close({state: "recorded", value: string & !=""})
	let boundSource = source
	compendium?: ivac.#RegulatoryCompendium & {source: boundSource}
}

#CorpusTarget: close({
	id:         ivac.#ID
	instrument: string & !=""
	scope: [string & !="", ...(string & !="")]
	sourceVersionIDs: [...ivac.#ID]
	coverage: "missing" | "inventory-only" | "partial"
	gaps: [string & !="", ...(string & !="")]
	if coverage == "missing" {sourceVersionIDs: []}
	if coverage != "missing" {sourceVersionIDs: [ivac.#ID, ...ivac.#ID]}
})

// Demonstrated gap: #EvidenceArtifact.source alone cannot anchor a particular
// page and text slice. Offsets address pinned UTF-8 page text, never PDF bytes.
#EvidenceTextAnchor: close({
	id:             ivac.#ID
	evidence:       ivac.#EvidenceArtifactRef
	artifactDigest: ivac.#RegulatoryDigest
	textDigest:     ivac.#RegulatoryDigest
	page:           int & >=1
	start:          int & >=0
	end:            int & >start
	exactText:      string & !=""
	transcription:  "machine-unreviewed" | "image-checked"
})

#RecordKind: "filing" | "clinical-evaluation" | "internal-opinion" | "formal-decision" | "supplement" | "review"
#CaseSnapshot: close({
	id:                  ivac.#ID
	caseID:              ivac.#ID
	stage:               "initial" | "supplement" | "reassessment"
	recordedAt:          time.Time
	ordinal:             int & >=0
	previousSnapshotID?: ivac.#ID
	if stage == "initial" {ordinal: 0, previousSnapshotID?: _|_}
	if stage != "initial" {ordinal: int & >=1, previousSnapshotID: ivac.#ID & !=id}
})

#CaseRecord: close({
	id:         ivac.#ID
	snapshotID: ivac.#ID
	kind:       #RecordKind
	evidence:   ivac.#EvidenceArtifactRef
	anchorIDs: [ivac.#ID, ...ivac.#ID]
	authored:     ivac.#TemporalExtent
	submitted:    ivac.#TemporalExtent
	received:     ivac.#TemporalExtent
	communicated: ivac.#TemporalExtent
	// Declared document links, not inferred chronology or causal links.
	refersToRecordIDs: [...ivac.#ID]
})

#ReportedClass: close({state: "unknown", reason: string & !=""}) | close({
	state: "recorded"
	label: string & !=""
})
#ReportedPercentage: close({state: "unknown", reason: string & !=""}) | close({
	state:      "recorded"
	percentage: ivac.#RegulatoryPercentage
})
#ReportedLegalBasis: close({state: "unknown", reason: string & !=""}) | close({
	state:         "cited"
	sourceVersion: ivac.#ID
	unitID:        ivac.#ID
	// A record may cite a proposal; it never becomes selected applicable law here.
})

// A statement preserves what a document asserts, even when disputed or wrong.
// It is NOT #Finding, #CriterionAssessment, or #RegulatoryQualification.
#AssessmentStatement: close({
	id:       ivac.#ID
	recordID: ivac.#ID
	anchorIDs: [ivac.#ID, ...ivac.#ID]
	subject:            ivac.#ActorRef
	topic:              "classification" | "assistance" | "causation" | "baseline" | "permanence" | "calculation" | "procedure" | "other"
	assertion:          string & !=""
	reportedClass:      #ReportedClass
	reportedPercentage: #ReportedPercentage
	legalBasis:         #ReportedLegalBasis
	status:             "attributed-source-statement"
})

#StatementComparison: close({
	id:               ivac.#ID
	leftStatementID:  ivac.#ID
	rightStatementID: ivac.#ID & !=leftStatementID
	question:         string & !=""
	status:           "candidate-unresolved"
	// A difference does not mean contradiction, error, or a legal entitlement.
	automaticSelection: false
})

#RuleDependency: close({
	id:               ivac.#ID
	from:             ivac.#RegulatoryCitation
	to:               ivac.#RegulatoryCitation
	relation:         "references" | "requires" | "excludes" | "overrides" | "analogy" | "calculation-stage"
	status:           "candidate" | "source-explicit"
	rationale:        string & !=""
	opposingReading?: string & !=""
	if status == "candidate" {opposingReading: string & !=""}
})

#RegulatoryWorkbench: {
	apiVersion: "ivac.regulatory-workbench/v1"
	kind:       "RegulatoryWorkbench"
	id:         ivac.#ID
	usage:      "synthetic-test" | "private-assessment"
	caseID:     ivac.#ID
	subject:    ivac.#ActorRef
	axes: [string]:             ivac.#ClaimAxis
	corpusTargets: [string]:    #CorpusTarget
	corpusVersions: [string]:   #CorpusVersion
	actors: [string]:           ivac.#Actor
	evidence: [string]:         ivac.#EvidenceArtifact
	anchors: [string]:          #EvidenceTextAnchor
	snapshots: [string]:        #CaseSnapshot
	records: [string]:          #CaseRecord
	statements: [string]:       #AssessmentStatement
	comparisons: [string]:      #StatementComparison
	ruleDependencies: [string]: #RuleDependency
	// These remain separately authored authority-gated inputs, not inferred from
	// reported classifications. No new admission route is introduced.
	qualifications: [string]: ivaceval.#RegulatoryQualification
	reviewDrafts: [string]:   ivaceval.#MedicoLegalReviewDraft
	coverage: "partial"
	coverageGaps: [string & !="", ...(string & !="")]
	disclosure:   "not-authorized"
	adjudication: "not-determined"

	if id != "" {
		let currentCaseID = caseID
		let currentSubject = subject
		_subject: [for key, a in actors if key == subject.id {a & {kind: "claimant"}}] & [_, ...]
		_axes: [for key, a in axes {a & {id: key}}]
		_targets: [for key, t in corpusTargets {
			t & {id: key}
			_versions: [for ref in t.sourceVersionIDs {
				_match: [for key, v in corpusVersions if key == ref {v}] & [_, ...]
			}]
		}]
		_versions: [for key, v in corpusVersions {
			v.source & {id: key}
			if usage == "synthetic-test" {v.source & {contentKind: "synthetic"}}
		}]
		_actors: [for key, a in actors {a & {id: key}}]
		_evidence: [for key, e in evidence {
			e & {id: key}
			_producer: [for key, a in actors if key == e.producer.id {a}] & [_, ...]
			_axes: [for ref in e.axes {
				_match: [for key, a in axes if key == ref.id {a}] & [_, ...]
			}]
		}]
		_anchors: [for key, a in anchors {
			a & {id: key}
			_evidence: [for key, e in evidence if key == a.evidence.id {e}] & [_, ...]
		}]
		_snapshots: [for key, s in snapshots {
			s & {id: key, caseID: currentCaseID}
			if s.stage != "initial" {
				_previous: [for key, previous in snapshots if key == s.previousSnapshotID {
					previous & {caseID: s.caseID, ordinal: <s.ordinal}
				}] & [_, ...]
			}
		}]
		_records: [for key, r in records {
			r & {id: key}
			_snapshot: [for key, s in snapshots if key == r.snapshotID {s}] & [_, ...]
			_evidence: [for key, e in evidence if key == r.evidence.id {e}] & [_, ...]
			_anchors: [for ref in r.anchorIDs {
				_match: [for key, a in anchors if key == ref {a & {evidence: r.evidence}}] & [_, ...]
			}]
			_links: [for ref in r.refersToRecordIDs {
				_match: [for key, other in records if key == ref {other & {id: !=r.id}}] & [_, ...]
			}]
		}]
		_statements: [for key, s in statements {
			s & {id: key, subject: currentSubject}
			_subject: [for key, a in actors if key == s.subject.id {a}] & [_, ...]
			_record: [for key, r in records if key == s.recordID {r}] & [_, ...]
			_anchors: [for ref in s.anchorIDs {
				_match: [for key, a in anchors if key == ref {a & {evidence: _record[0].evidence}}] & [_, ...]
				_inRecord: [for id in _record[0].anchorIDs if id == ref {id}] & [_, ...]
			}]
			if s.legalBasis.state == "cited" {
				_version: [for key, v in corpusVersions if key == s.legalBasis.sourceVersion {v}] & [_, ...]
			}
		}]
		_comparisons: [for key, c in comparisons {
			c & {id: key}
			_left: [for key, s in statements if key == c.leftStatementID {s}] & [_, ...]
			_right: [for key, s in statements if key == c.rightStatementID {s}] & [_, ...]
			_subject: _left[0].subject & _right[0].subject
			_topic:   _left[0].topic & _right[0].topic
		}]
		_rules: [for key, d in ruleDependencies {
			d & {id: key}
			_citations: [for c in [d.from, d.to] {
				_match: [for key, v in corpusVersions if key == c.sourceVersion {v}] & [_, ...]
			}]
		}]
		_qualifications: [for _, q in qualifications {
			_subject: q.case.world.subject & currentSubject
			_version: [for key, v in corpusVersions if key == q.compendium.source.id {
				v & {publicationKind: "enacted-act" | "enacted-regulation"}
				_sameSource: v.source & q.compendium.source
			}] & [_, ...]
		}]
		_reviews: [for _, draft in reviewDrafts {
			_subject: draft.case.world.subject & currentSubject
		}]
	}
}

workbenchContract: close({
	id:        "personal.ivac.regulatory-workbench"
	version:   "0.1.0"
	authority: "cue"
	root:      "#RegulatoryWorkbench"
	extends:   "personal.ivac@0.4.0"
	scope:     "partial-corpus-and-case-assembly"
	projections: ["json-schema", "pydantic-v2", "factory.analytics-ir/v1", "ibis"]
	admission: "existing-ivac-authority-only"
})
