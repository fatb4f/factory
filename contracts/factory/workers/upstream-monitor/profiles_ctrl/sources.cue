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
	codexChannelsDistinct: true
	cpythonChannelsDistinct: true
	cuePinnedDistinctFromForecast: true
	astralAnalyzerIsEvidenceOnly: true
	optionalSatellitesCannotBlockWithoutLocalConsumer: true
})
