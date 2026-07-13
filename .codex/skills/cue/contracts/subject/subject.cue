package subject

import (
	"list"
	"strings"

	"github.com/fatb4f/factory/cue-skill/canonical"
	kernel "github.com/fatb4f/factory/cue-skill/kernel"
)

#Digest:            canonical.#SHA256
#RelativePOSIXPath: string & strings.MinRunes(1) & !~"^/" & !~"(^|/)\\.\\.?(/|$)" & !~"\\\\"

#Source: close({
	path:   #RelativePOSIXPath
	digest: #Digest
})

#BuildOptions: close({
	tags: [...kernel.#KebabIdentifier]
	allCUEFiles: bool
	dataFiles:   bool
	tools:       bool
})

#Coordinates: close({
	package: string & strings.MinRunes(1)
	value:   kernel.#CueSelectorExpr
	operands: {[kernel.#KebabIdentifier]: kernel.#CueSelectorExpr}
})

#ProbeSubject: close({
	kernel: close({
		packageID: kernel.#KebabIdentifier
		version:   string & strings.MinRunes(1)
	})
	candidate: close({
		id:    kernel.#KebabIdentifier
		class: kernel.#KebabIdentifier
	})
	module: close({
		path:            string & strings.MinRunes(1)
		languageVersion: string & strings.MinRunes(1)
		manifestDigest:  #Digest
	})
	sources: [...#Source] & [_, ...]
	probeSpecVersion: string & strings.MinRunes(1)
	operation:        "unify" | "validate" | "validate-concrete" | "project" | "ingress-reject" | "no-widening" | "negative-fixture-conflict"
	coordinates:      #Coordinates
	inputs: {[kernel.#KebabIdentifier]: canonical.#CanonicalSubjectValue}
	build: #BuildOptions
	runner: close({
		protocol:       string & strings.MinRunes(1)
		semanticEngine: string & strings.MinRunes(1)
	})

	_sourceOrder: !list.Contains([for i, _ in sources if i > 0 {sources[i-1].path < sources[i].path}], false)
})

#SubjectProjection: close({
	subject:       #ProbeSubject
	canonicalJSON: string & strings.MinRunes(1)
	digest:        #Digest
})
