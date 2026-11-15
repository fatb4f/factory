package ivacworkbench

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

// Narrow acquisition compatibility envelope. Provider content is opaque JSON,
// not another clinical/legal model and never admitted by successful ingestion.
#TimelineEvidence: close({
	source_id: ivac.#ID
	page:      null | (int & >=1)
	text_path: string & !=""
	start:     null | (int & >=0)
	end:       null | (int & >=1)
	quote:     null | string
	review:    "machine_extraction" | "visually_reviewed" | "imported_prior_review" | "derived_timeline"
})
#TimelineSource: close({
	id:         ivac.#ID
	title:      string
	origin:     string
	source_url: null | string
	parent_ids: [...string]
	mime_type:         string & !=""
	raw_path:          null | string
	raw_sha256:        null | (string & =~"^[0-9a-f]{64}$")
	extraction_status: string & !=""
	pages:             null | (int & >=0)
	text_paths: [...string]
	role: string & !=""
	details: [string]: _
})
#TimelineEvent: close({
	id:               ivac.#ID
	date_label:       string
	normalized_start: null | ivac.#RegulatoryDate
	summary:          string
	evidence_status:  string & !=""
	evidence: [...#TimelineEvidence]
	content: [string]: _
})
#TimelineRecord: close({id: ivac.#ID, kind: string & !="", content: [string]: _})
#TimelineExchange: {
	format:    "ivac.complete.evidence.exchange"
	version:   "0.2.0"
	authority: string & !=""
	sources: [...#TimelineSource]
	timeline: [...#TimelineEvent]
	sequelae_vectors: [...#TimelineRecord]
	assessments: [...#TimelineRecord]
	coverage: [string]: _
	gaps: [...string]
	if format != "" {
		_sources: [for i, s in sources {
			_unique: [for j, other in sources if other.id == s.id {j}] & [i]
		}]
		_events: [for i, e in timeline {
			_unique: [for j, other in timeline if other.id == e.id {j}] & [i]
			_evidence: [for a in e.evidence {
				_source: [for s in sources if s.id == a.source_id {s}] & [_, ...]
			}]
		}]
		_records: [for collection in [assessments, sequelae_vectors] {
			_unique: [for i, r in collection {
				_match: [for j, other in collection if other.id == r.id {j}] & [i]
			}]
		}]
	}
}
#TimelinePageDescriptor: close({
	page_id:         ivac.#ID
	source_id:       ivac.#ID
	text_path:       string & !=""
	page:            null | (int & >=1)
	text_sha256:     ivac.#RegulatoryDigest
	character_count: int & >=0
})
#TimelinePayloadDescriptor: close({
	payload_id:      ivac.#ID
	source_id:       ivac.#ID
	text_path:       string & !=""
	text_sha256:     ivac.#RegulatoryDigest
	character_count: int & >=0
})
#TimelineAcquisition: {
	format:     "ivac.timeline-acquisition/v1"
	dataset_id: ivac.#RegulatoryDigest
	exchange:   #TimelineExchange
	pages: [string]: #TimelinePageDescriptor
	semantic_admission: "none"
	payloads: [string]: #TimelinePayloadDescriptor
	if dataset_id != "" {
		_payloads: [for id, p in payloads {
			p & {payload_id: id}
			_source: [for s in exchange.sources if s.id == p.source_id {s}] & [_, ...]
		}]
		_pages: [for id, p in pages {
			p & {page_id: id}
			_source: [for s in exchange.sources if s.id == p.source_id {s}] & [_, ...]
		}]
	}
}

#TimelineDatasetRow: close({
	dataset_id:         ivac.#RegulatoryDigest
	format:             string
	version:            string
	authority:          string
	exchange_sha256:    ivac.#RegulatoryDigest
	semantic_admission: "none"
	coverage_json:      string
	gaps_json:          string
})
#TimelineSourceRow: close({
	dataset_id:        ivac.#RegulatoryDigest
	source_id:         ivac.#ID
	title:             string
	origin:            string
	source_url:        null | string
	mime_type:         string
	raw_path:          null | string
	raw_sha256:        null | string
	extraction_status: string
	byte_verification: "original-verified" | "snapshot-only"
	pages:             null | int
	role:              string
	content_json:      string
})
#TimelinePageRow: close({
	dataset_id:      ivac.#RegulatoryDigest
	page_id:         ivac.#ID
	source_id:       ivac.#ID
	text_path:       string
	page:            null | int
	text_sha256:     ivac.#RegulatoryDigest
	character_count: int & >=0
	text:            string
})
#TimelinePayloadRow: close({
	dataset_id:      ivac.#RegulatoryDigest
	payload_id:      ivac.#ID
	source_id:       ivac.#ID
	text_path:       string
	text_sha256:     ivac.#RegulatoryDigest
	character_count: int & >=0
	text:            string
})
#TimelineEventRow: close({
	dataset_id:       ivac.#RegulatoryDigest
	event_id:         ivac.#ID
	date_label:       string
	normalized_start: null | string
	summary:          string
	evidence_status:  string
	content_json:     string
})
#TimelineAnchorRow: close({
	dataset_id:         ivac.#RegulatoryDigest
	anchor_id:          ivac.#ID
	owner_kind:         "event" | "vector" | "assessment" | "comparison"
	owner_id:           ivac.#ID
	position:           int & >=0
	source_id:          null | string
	original_source_id: null | string
	page:               null | int
	text_path:          null | string
	text_sha256:        null | string
	start:              null | int
	end:                null | int
	quote:              null | string
	review:             string
	integrity:          "exact-verified" | "locator-only" | "unresolved-source"
	content_json:       string
})
#TimelineAssessmentRow: close({
	dataset_id:       ivac.#RegulatoryDigest
	assessment_id:    ivac.#ID
	kind:             string
	source_id:        null | string
	assessment_date:  null | string
	assessor:         null | string
	percentage:       null | (number & >=0 & <=100)
	percentage_state: "recorded" | "unknown" | "opaque"
	class_label:      null | string
	review_status:    null | string
	content_json:     string
})
#TimelineVectorRow: close({
	dataset_id:         ivac.#RegulatoryDigest
	vector_id:          ivac.#ID
	kind:               string
	domain:             null | string
	candidate:          null | string
	status:             null | string
	permanence:         null | string
	causal_nexus:       null | string
	regulatory_unit_id: null | string
	class_label:        null | string
	percentage:         null | (number & >=0 & <=100)
	percentage_state:   "recorded" | "unknown" | "opaque"
	content_json:       string
})
#TimelineAliasRow: close({
	dataset_id: ivac.#RegulatoryDigest
	alias_id:   ivac.#ID
	source_id:  ivac.#ID
	basis:      "original-artifact-digest" | "original-and-text-digests"
})
#TimelineComparisonRow: close({
	dataset_id:          ivac.#RegulatoryDigest
	comparison_id:       ivac.#ID
	topic:               string
	left_assertion:      string
	right_assertion:     string
	difference:          string
	origin_path:         string
	status:              "candidate-unresolved"
	automatic_selection: false
})

// Transport schemas generate Python/Arrow; source text never becomes semantics.
timelineProjectionSchemas: {
	source_payloads:        #TimelinePayloadRow
	datasets:               #TimelineDatasetRow
	sources:                #TimelineSourceRow
	document_pages:         #TimelinePageRow
	events:                 #TimelineEventRow
	evidence_anchors:       #TimelineAnchorRow
	assessments:            #TimelineAssessmentRow
	sequela_vectors:        #TimelineVectorRow
	source_aliases:         #TimelineAliasRow
	assessment_comparisons: #TimelineComparisonRow
}
timelineExchangeSchemas: {source: #TimelineSource, event: #TimelineEvent, evidence: #TimelineEvidence, record: #TimelineRecord}
timelineStoragePolicy: close({
	decimalPrecision:       38
	decimalScale:           18
	excessDecimalPrecision: "reject-never-round"
	bytes:                  "verify-package-manifest-and-available-originals"
	privateDataInGit:       false
	unknownPercentage:      "null-never-zero"
	providerContent:        "lossless-opaque-json"
	interpretation:         "none"
})
