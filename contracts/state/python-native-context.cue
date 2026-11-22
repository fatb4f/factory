package state

// Pinned external declarations; no runtime behavior or admission is inferred.
pythonAPISource: #PythonAPISource & {
	"repository": "https://github.com/python/typeshed"
	"revision":   "e75a39fec6f375f5002d54c5607b44bedc025a4b"
	"targetPython": {
		"major": 3
		"minor": 12
	}
	"files": {
		"builtins": {
			"path":   "state/python-api/typeshed/stdlib/builtins.pyi"
			"digest": "sha256:115e4ecfbbc94d11e8d602ed26efc4cb1994add4994277a2cb9634340e477703"
		}
		"dataclasses": {
			"path":   "state/python-api/typeshed/stdlib/dataclasses.pyi"
			"digest": "sha256:7bf3761f6af1321bff9de1b5522d9d0071a45db197d0531d6f2a6c28685205c7"
		}
		"typing": {
			"path":   "state/python-api/typeshed/stdlib/typing.pyi"
			"digest": "sha256:edb6fcd5ba33fe423235a86f5f21a05188996fa7fbc867699622de4c8502691e"
		}
	}
	"license": {
		"path":   "state/python-api/typeshed/LICENSE"
		"digest": "sha256:295f8538c94ae5c3043301cf7cff1c852dab6a786a8ddee471e061b40d5ecabe"
	}
	"requests": {
		"dataclass": {
			"module": "dataclasses"
			"symbol": "dataclass"
		}
		"str": {
			"module": "builtins"
			"symbol": "str"
		}
		"int": {
			"module": "builtins"
			"symbol": "int"
		}
		"tuple": {
			"module": "builtins"
			"symbol": "tuple"
		}
		"literal": {
			"module": "typing"
			"symbol": "Literal"
		}
	}
}

// Explicit CUE-owned binding slice, not a general CUE-to-Python compiler.
nativePythonProjection: #NativePythonProjection & {
	id:         "semantic-context-native-v1"
	cuePackage: "state"
	apiSource:  pythonAPISource

	"apiVersion":   "factory.native-python-projection/v1"
	"source":       "contracts/state/semantic-context.cue"
	"sourceDigest": "sha256:6326c3e37ad1fe8ea70511d2ea5c2e8eb2cb8f5546740cb36b3324324006ac28"
	"decorator": {
		"api": "dataclass"
		"keywords": {
			"frozen":  true
			"slots":   true
			"kw_only": true
		}
	}
	"tupleAPI":               "tuple"
	"literalAPI":             "literal"
	"optionalRepresentation": "unset-sentinel"
	"constraintPolicy":       "all-values-revalidate-in-cue"
	"admission":              "not-determined"
	"types": [
		{
			"name":    "SemanticAuthorityRef"
			"cueType": "#SemanticAuthorityRef"
			"space":   "semantic"
			"fields": [
				{
					"name": "id"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "contract"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
			]
			"cueRequired": [
				"nonempty identity",
				"repository path constraints",
			]
		},
		{
			"name":    "SemanticRef"
			"cueType": "#SemanticRef"
			"space":   "semantic"
			"fields": [
				{
					"name": "authority"
					"annotation": {
						"kind": "local"
						"name": "SemanticAuthorityRef"
					}
					"optional": false
				},
				{
					"name": "subject"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "kind"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": true
				},
			]
			"cueRequired": [
				"nonempty subject and optional kind",
				"authority qualification remains external",
			]
		},
		{
			"name":    "SourceIdentity"
			"cueType": "#SourceIdentity"
			"space":   "provenance"
			"fields": [
				{
					"name": "kind"
					"annotation": {
						"kind": "literal"
						"values": [
							"repository",
							"document",
							"github-issue",
							"run",
							"evidence",
							"other",
						]
					}
					"optional": false
				},
				{
					"name": "id"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
			]
			"cueRequired": [
				"source-kind enum and nonempty identity",
			]
		},
		{
			"name":    "SourceOccurrence"
			"cueType": "#SourceOccurrence"
			"space":   "provenance"
			"fields": [
				{
					"name": "id"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "source"
					"annotation": {
						"kind": "local"
						"name": "SourceIdentity"
					}
					"optional": false
				},
				{
					"name": "locator"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "payloadDigest"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "revisionHint"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": true
				},
				{
					"name": "acquiredAt"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": true
				},
				{
					"name": "lineStart"
					"annotation": {
						"kind": "api"
						"api":  "int"
					}
					"optional": true
				},
				{
					"name": "lineEnd"
					"annotation": {
						"kind": "api"
						"api":  "int"
					}
					"optional": true
				},
				{
					"name": "byteStart"
					"annotation": {
						"kind": "api"
						"api":  "int"
					}
					"optional": true
				},
				{
					"name": "byteEnd"
					"annotation": {
						"kind": "api"
						"api":  "int"
					}
					"optional": true
				},
			]
			"cueRequired": [
				"SHA-256 pattern",
				"nonempty identity and locator",
				"line minima 1 and byte minima 0",
			]
		},
		{
			"name":    "ContextArtifactRef"
			"cueType": "#ContextArtifactRef"
			"space":   "context"
			"fields": [
				{
					"name": "id"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
			]
			"cueRequired": [
				"nonempty identity",
			]
		},
		{
			"name":    "ContextArtifact"
			"cueType": "#ContextArtifact"
			"space":   "context"
			"fields": [
				{
					"name": "id"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "plane"
					"annotation": {
						"kind": "literal"
						"values": [
							"documentary",
							"operational",
							"structural",
							"evidential",
						]
					}
					"optional": false
				},
				{
					"name": "role"
					"annotation": {
						"kind": "api"
						"api":  "str"
					}
					"optional": false
				},
				{
					"name": "subjects"
					"annotation": {
						"kind": "tuple"
						"item": {
							"kind": "local"
							"name": "SemanticRef"
						}
					}
					"optional": false
				},
				{
					"name": "occurrence"
					"annotation": {
						"kind": "local"
						"name": "SourceOccurrence"
					}
					"optional": false
				},
			]
			"cueRequired": [
				"nonempty subjects",
				"nonempty identity and role",
				"context-only plane; no semantic admission",
			]
		},
	]

}
