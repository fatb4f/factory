package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

epistemicPlantSources: [string]: core.#UpstreamSource

epistemicPlantSources: {
	guac: {
		id: "guac"
		repository: "guacsec/guac"
		role: "upstream_evidence_only"
		channels: {
			pinned: {id: "pinned", ref: "v1.1.0", mode: "active-baseline", required: true}
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	gemara: {
		id: "gemara"
		repository: "gemaraproj/gemara"
		role: "pinned_external_semantics"
		channels: {
			pinned: {id: "pinned", ref: "4822ce0071b1f2ff478f8a9eece35c4636ba0c0b", mode: "pinned-authority", required: true}
			main: {id: "main", ref: "main", mode: "forecast", required: true}
		}
	}
	cue: {
		id: "cue"
		repository: "cue-lang/cue"
		role: "pinned_external_semantics"
		channels: {
			pinned: {id: "pinned", ref: "fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3", mode: "pinned-authority", required: true}
			master: {id: "master", ref: "master", mode: "forecast", required: true}
		}
	}
	cyclonedx: {
		id: "cyclonedx"
		repository: "CycloneDX/specification"
		role: "upstream_evidence_only"
		channels: {
			master: {id: "master", ref: "master", mode: "release-watch", required: false}
		}
	}
	golang: {
		id: "golang"
		repository: "golang/go"
		role: "upstream_evidence_only"
		channels: {
			pinned: {id: "pinned", ref: "go1.25.0", mode: "active-baseline", required: true}
			master: {id: "master", ref: "master", mode: "forecast", required: false}
		}
	}
	uv: {
		id: "uv"
		repository: "astral-sh/uv"
		role: "upstream_evidence_only"
		channels: {
			pinned: {id: "pinned", ref: "b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e", mode: "active-baseline", required: true}
			main: {id: "main", ref: "main", mode: "release-watch", required: false}
		}
	}
}

epistemicPlantSourcePolicy: close({
	requireSourceQualifiedObservations: true
	guacPinnedVersion: "v1.1.0"
	guacPinnedCommit: "a399a54801bfbffc36bc8748dd97d2d2b3bea378"
	gemaraPinnedVersion: "v1.4.1"
	gemaraPinnedCommit: "4822ce0071b1f2ff478f8a9eece35c4636ba0c0b"
	cuePinnedVersion: "v0.17.1"
	cuePinnedCommit: "fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3"
	goPinnedVersion: "1.25.0"
	uvPinnedVersion: "0.12.0"
	uvPinnedCommit: "b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e"
	guacIsObservationOnly: true
	guacPinnedAndForecastDistinct: true
	gemaraPinnedAndForecastDistinct: true
	cuePinnedAndForecastDistinct: true
	cyclonedxCurrentSpecCannotRewritePinnedFixtureMeaning: true
	optionalToolchainForecastCannotBlockWithoutLocalConsumerImpact: true
})
