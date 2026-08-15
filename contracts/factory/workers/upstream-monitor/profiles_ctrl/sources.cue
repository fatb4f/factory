package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

ctrlSources: [string]: core.#UpstreamSource

ctrlSources: {
	codex: {
		id: "codex"
		repository: "openai/codex"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "active-baseline", required: true}
			"latest-alpha-cli": {id: "latest-alpha-cli", ref: "latest-alpha-cli", mode: "forecast", required: true}
		}
	}
	cpython: {
		id: "cpython"
		repository: "python/cpython"
		role: "upstream_evidence_only"
		channels: {
			"3.14": {id: "3.14", ref: "3.14", mode: "active-baseline", required: true}
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"astral-python": {
		id: "astral-python"
		repository: "astral-sh/ruff"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"otel-python-core": {
		id: "otel-python-core"
		repository: "open-telemetry/opentelemetry-python"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"otel-python-contrib": {
		id: "otel-python-contrib"
		repository: "open-telemetry/opentelemetry-python-contrib"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"otel-genai-semconv": {
		id: "otel-genai-semconv"
		repository: "open-telemetry/semantic-conventions-genai"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"otel-python-genai": {
		id: "otel-python-genai"
		repository: "open-telemetry/opentelemetry-python-genai"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	"otel-arrow": {
		id: "otel-arrow"
		repository: "open-telemetry/otel-arrow"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	dlt: {
		id: "dlt"
		repository: "dlt-hub/dlt"
		role: "upstream_evidence_only"
		channels: {
			devel: {id: "devel", ref: "devel", mode: "release-watch", required: false}
		}
	}
	cue: {
		id: "cue"
		repository: "cue-lang/cue"
		role: "pinned_external_semantics"
		channels: {
			pinned: {id: "pinned", ref: "806821e40fae070318600a264d311517e596353b", mode: "pinned-authority", required: true}
			master: {id: "master", ref: "master", mode: "forecast", required: true}
		}
	}
	uv: {
		id: "uv"
		repository: "astral-sh/uv"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "release-watch", required: false}
		}
	}
	jj: {
		id: "jj"
		repository: "jj-vcs/jj"
		role: "upstream_evidence_only"
		channels: {
			main: {id: "main", ref: "main", mode: "release-watch", required: false}
		}
	}
}

ctrlSourcePolicy: close({
	requireSourceQualifiedObservations: true
	activeRuntimeSource: "cpython/3.14"
	cpythonForecastSource: "cpython/main"
	astralStaticSource: "astral-python/main"
	astralInstalledBaselineSource: "fatb4f/ctrl@main uv.lock"
	telemetryCoreSource: "otel-python-core/main"
	telemetryProviderSource: "otel-python-contrib/main"
	genaiSemanticSource: "otel-genai-semconv/main"
	genaiPythonRealizationSource: "otel-python-genai/main"
	columnarTelemetrySource: "otel-arrow/main"
	externalFactAcquisitionSource: "dlt/devel"
	codexChannelsDistinct: true
	cpythonChannelsDistinct: true
	cuePinnedDistinctFromForecast: true
	astralAnalyzerIsEvidenceOnly: true
	otelTelemetryIsObservationOnly: true
	otelArrowPreservesOTLPOTAPDistinction: true
	dltFactsDistinctFromRuntimeObservations: true
	optionalSatellitesCannotBlockWithoutLocalConsumer: true
})
