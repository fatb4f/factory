package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CorrelationIdentity: close({
	qualification_run_id: core.#NonEmptyString
	repository_revision: core.#CommitSHA
	operation_id: core.#NonEmptyString
	probe_id?: core.#NonEmptyString
	symbol_id?: core.#NonEmptyString
	source_occurrence_id?: core.#NonEmptyString
	evidence_id?: core.#NonEmptyString
})

#BaggageDisposition: "allowed" | "conditional" | "forbidden"

#TelemetryCarrierRule: close({
	id: core.#NonEmptyString
	span_attributes: bool
	event_attributes: bool
	baggage: #BaggageDisposition
	resource_attributes: bool
	constraints: [...core.#NonEmptyString]
})

ctrlTelemetryCarrierPolicy: close({
	defaultBaggageDisposition: "forbidden"
	bulkSemanticIdentityProjectionToBaggage: false
	rules: {
		qualification_run_id: #TelemetryCarrierRule & {
			id: "qualification_run_id"
			span_attributes: true
			event_attributes: true
			baggage: "allowed"
			resource_attributes: false
			constraints: ["propagate only the opaque identifier, never qualification payloads"]
		}
		repository_revision: #TelemetryCarrierRule & {
			id: "repository_revision"
			span_attributes: true
			event_attributes: true
			baggage: "conditional"
			resource_attributes: false
			constraints: ["use baggage only when a downstream process requires revision correlation"]
		}
		operation_id: #TelemetryCarrierRule & {
			id: "operation_id"
			span_attributes: true
			event_attributes: true
			baggage: "forbidden"
			resource_attributes: false
			constraints: []
		}
		probe_id: #TelemetryCarrierRule & {
			id: "probe_id"
			span_attributes: true
			event_attributes: true
			baggage: "forbidden"
			resource_attributes: false
			constraints: []
		}
		symbol_id: #TelemetryCarrierRule & {
			id: "symbol_id"
			span_attributes: true
			event_attributes: true
			baggage: "forbidden"
			resource_attributes: false
			constraints: ["symbol identity remains a ctrl semantic join key, not distributed request metadata"]
		}
		source_occurrence_id: #TelemetryCarrierRule & {
			id: "source_occurrence_id"
			span_attributes: true
			event_attributes: true
			baggage: "forbidden"
			resource_attributes: false
			constraints: []
		}
		evidence_id: #TelemetryCarrierRule & {
			id: "evidence_id"
			span_attributes: true
			event_attributes: true
			baggage: "forbidden"
			resource_attributes: false
			constraints: ["carry identity only; evidence payload remains out-of-band"]
		}
		source_text: #TelemetryCarrierRule & {
			id: "source_text"
			span_attributes: false
			event_attributes: false
			baggage: "forbidden"
			resource_attributes: false
			constraints: ["source text is forbidden from telemetry correlation carriers"]
		}
		credentials: #TelemetryCarrierRule & {
			id: "credentials"
			span_attributes: false
			event_attributes: false
			baggage: "forbidden"
			resource_attributes: false
			constraints: ["credentials and secrets are forbidden from all telemetry carriers"]
		}
		large_evidence_payload: #TelemetryCarrierRule & {
			id: "large_evidence_payload"
			span_attributes: false
			event_attributes: false
			baggage: "forbidden"
			resource_attributes: false
			constraints: ["large evidence remains content-addressed/out-of-band and is joined by evidence_id"]
		}
	}
})

ctrlCorrelationContract: close({
	identitySchema: #CorrelationIdentity
	carrierPolicy: ctrlTelemetryCarrierPolicy
	semanticIdentityDistinctFromTraceIdentity: true
	traceIdentityAnswersCausalityOnly: true
	semanticIdentityAnswersSubjectIdentity: true
	baggageDenyByDefault: true
	forbidBulkSemanticIdentityBaggageProjection: true
	forbidSensitiveOrLargePayloadCarriers: true
	missingSemanticIdentityCannotBeManufacturedByTelemetry: true
})
