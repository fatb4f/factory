package state

#PythonFieldProjection: close({
	name:       #NonEmptyString
	pythonType: #NonEmptyString
	optional?:  bool
})

#PythonTypeProjection: close({
	name:    #NonEmptyString
	cueType: #NonEmptyString
	space:   "semantic" | "context" | "provenance"
	fields:  [#PythonFieldProjection, ...#PythonFieldProjection]
})

#SemanticRuntimeProjection: close({
	apiVersion: "factory.semantic-runtime.projection/v1"
	source:     "contracts/state/semantic-context.cue"
	types:      [#PythonTypeProjection, ...#PythonTypeProjection]
})

semanticRuntimeProjection: #SemanticRuntimeProjection & {
	apiVersion: "factory.semantic-runtime.projection/v1"
	source:     "contracts/state/semantic-context.cue"
	types: [{
		name:    "SemanticAuthorityRef"
		cueType: "#SemanticAuthorityRef"
		space:   "semantic"
		fields: [{name: "id", pythonType: "str"}, {name: "contract", pythonType: "str"}]
	}, {
		name:    "SemanticRef"
		cueType: "#SemanticRef"
		space:   "semantic"
		fields: [{name: "authority", pythonType: "Mapping[str, Any]"}, {name: "subject", pythonType: "str"}, {name: "kind", pythonType: "str | None", optional: true}]
	}, {
		name:    "SourceOccurrence"
		cueType: "#SourceOccurrence"
		space:   "provenance"
		fields: [{name: "id", pythonType: "str"}, {name: "source", pythonType: "Mapping[str, Any]"}, {name: "locator", pythonType: "str"}, {name: "payloadDigest", pythonType: "str"}, {name: "revisionHint", pythonType: "str | None", optional: true}, {name: "acquiredAt", pythonType: "str | None", optional: true}]
	}, {
		name:    "ContextArtifactRef"
		cueType: "#ContextArtifactRef"
		space:   "context"
		fields: [{name: "id", pythonType: "str"}]
	}, {
		name:    "ContextArtifact"
		cueType: "#ContextArtifact"
		space:   "context"
		fields: [{name: "id", pythonType: "str"}, {name: "plane", pythonType: "str"}, {name: "role", pythonType: "str"}, {name: "subjects", pythonType: "tuple[Mapping[str, Any], ...]"}, {name: "occurrence", pythonType: "Mapping[str, Any]"}]
	}]
}
