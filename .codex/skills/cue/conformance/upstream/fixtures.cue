package upstream

// Raw negative inputs remain separate from their target schemas. The validation
// commands conjoin one selected value with its declared target and require bottom.
negativeFixtures: close({
	mutableRevision: {
		target: "authority"
		value: {
			id: "cue-upstream-authority-v1", repository: "https://github.com/cue-lang/cue"
			revision: "master", pinnedAt: "2026-07-13T17:30:00Z"
			retrieval: "github-contents-at-commit", movingTarget: true
		}
	}
	mismatchedArtifactRevision: {
		target: "authority.artifacts[\"language-specification\"]"
		value: {
			id: "language-specification", class: "normative-specification", role: "normative"
			repository: authority.repository, revision: "1111111111111111111111111111111111111111"
			path: "doc/ref/spec.md", digest: {algorithm: "git-blob-sha1", value: "6a6e6fd631d96e7025e0e16cc9b54eaa6a5baa6a"}
			retrieval: "github-contents-at-commit", mutable: false
		}
	}
	mutablePathIdentity: {
		target: "#ArtifactIdentity"
		value: {
			id: "language-specification", class: "normative-specification", role: "normative"
			repository: authority.repository, revision: authority.revision
			path: "refs/heads/master", digest: {algorithm: "git-blob-sha1", value: "6a6e6fd631d96e7025e0e16cc9b54eaa6a5baa6a"}
			retrieval: "github-contents-at-commit", mutable: false
		}
	}
	unknownSourceClass: {
		target: "#ClassPolicy"
		value: {id: "blog-post", role: "normative", mayDefineConcepts: true, requiredForAdmission: true}
	}
	unpinnedModuleVersion: {
		target: "authority.engine.goModule"
		value: {path: "cuelang.org/go", version: "cuelang.org/go@master", revision: authority.revision}
	}
})

positiveFixtures: close({
	exactRepository:  authority.repository == "https://github.com/cue-lang/cue"
	exactRevision:    authority.revision == "0c547ba896a57afc8990e69217d0743eb8d366c8"
	artifactIdentity: authority.artifacts["language-specification"].digest.value == "6a6e6fd631d96e7025e0e16cc9b54eaa6a5baa6a"
	engineLanguage:   authority.engine.languageVersion == "v0.18.0"
})

invariantFixtures: close({
	classesRemainDistinct: authority.boundary["normative-specification"].role == "normative" &&
		authority.boundary["explanatory-documentation"].role == "context-only" &&
		authority.boundary["executable-test"].mayDefineConcepts == false
	movingTargetsRejected: !authority.movingTarget
	allArtifactsPinned:    artifactSetComplete
	engineBoundToSource:   engineIdentityComplete
})

authorityFixtureSatisfaction: positiveFixtures.exactRepository && positiveFixtures.exactRevision &&
	positiveFixtures.artifactIdentity && positiveFixtures.engineLanguage &&
	invariantFixtures.classesRemainDistinct && invariantFixtures.movingTargetsRejected &&
	invariantFixtures.allArtifactsPinned && invariantFixtures.engineBoundToSource
