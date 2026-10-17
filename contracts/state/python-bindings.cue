package state

import unit "github.com/fatb4f/factory/contracts:unit"

// External API declarations are evidence, never domain/admission authority.
#PythonAPISource: close({
	repository: "https://github.com/python/typeshed"
	revision:   string & =~"^[0-9a-f]{40}$"
	targetPython: close({major: 3, minor: int & >=11})
	files: [string]: close({path: #NonEmptyString, digest: #SHA256})
	license: close({path: #NonEmptyString, digest: #SHA256})
	requests: [string]: close({module: #NonEmptyString, symbol: #NonEmptyString})
})

#PythonAPIParameter: close({
	name:       #NonEmptyString
	kind:       "positional-only" | "positional-or-keyword" | "keyword-only" | "var-positional" | "var-keyword"
	annotation: string
	required:   bool
})

#PythonAPIFact: close({
	module:       #NonEmptyString
	symbol:       #NonEmptyString
	kind:         "class" | "function" | "annotated-value"
	sourceDigest: #SHA256
	declarations: [close({
		lineStart:  int & >=1
		lineEnd:    int & >=lineStart
		textDigest: #SHA256
		guards: [...string]
		parameters: [...#PythonAPIParameter]
		returns: string
	}), ...]
})

#PythonAPIFacts: close({
	apiVersion: "factory.python-api-facts/v1"
	producer:   "typeshed-ast/v1"
	authority:  "external-api-declarations-only"
	source:     #PythonAPISource
	symbols: [string]: #PythonAPIFact
	behavior: "not-qualified"
})

#NativeElement:
	close({kind: "api", api: #NonEmptyString}) |
	close({kind: "local", name: #NonEmptyString})

#NativeAnnotation:
	#NativeElement |
	close({kind: "tuple", item: #NativeElement}) |
	close({kind: "literal", values: [#NonEmptyString, ...#NonEmptyString]})

#NativePythonProjection: close({
	id:           #NonEmptyString
	apiVersion:   "factory.native-python-projection/v1"
	source:       unit.#RepositoryPath & =~"^contracts/.*\\.cue$"
	cuePackage:   #NonEmptyString
	sourceDigest: #SHA256
	apiSource:    #PythonAPISource
	decorator: close({api: #NonEmptyString, keywords: {frozen: true, slots: true, kw_only: true}})
	tupleAPI:               #NonEmptyString
	literalAPI:             #NonEmptyString
	optionalRepresentation: "unset-sentinel"
	constraintPolicy:       "all-values-revalidate-in-cue"
	admission:              "not-determined"
	types: [close({
		name:    #NonEmptyString
		cueType: string & =~"^#[A-Za-z][A-Za-z0-9]*$"
		space:   "semantic" | "context" | "provenance"
		fields: [close({name: #NonEmptyString, annotation: #NativeAnnotation, optional: bool}), ...]
		cueRequired: [#NonEmptyString, ...#NonEmptyString]
	}), ...]
})

// Qualification binds API declarations to projection intent; it does not prove
// runtime behavior, instance validity, or domain admission.
#NativePythonBinding: {
	plan:    #NativePythonProjection
	facts:   #PythonAPIFacts
	_source: facts.source & plan.apiSource
	if plan.id != "" {
		_decorator: [for id, f in facts.symbols if id == plan.decorator.api {f & {kind: "function"}}] & [_, ...]
		_tuple: [for id, f in facts.symbols if id == plan.tupleAPI {f & {kind: "class"}}] & [_, ...]
		_literal: [for id, f in facts.symbols if id == plan.literalAPI {f & {kind: "annotated-value"}}] & [_, ...]
		_references: [for i, t in plan.types {
			_uniqueType: [for j, other in plan.types if other.name == t.name {j}] & [i]
			_uniqueCueType: [for j, other in plan.types if other.cueType == t.cueType {j}] & [i]
			_fields: [for k, field in t.fields {
				_uniqueField: [for l, other in t.fields if other.name == field.name {l}] & [k]
				if field.annotation.kind == "local" {
					_matches: [for other in plan.types if other.name == field.annotation.name {other}] & [_, ...]
				}
				if field.annotation.kind == "api" {
					_matches: [for id, f in facts.symbols if id == field.annotation.api {f & {kind: "class"}}] & [_, ...]
				}
				if field.annotation.kind == "tuple" {
					if field.annotation.item.kind == "local" {
						_matches: [for other in plan.types if other.name == field.annotation.item.name {other}] & [_, ...]
					}
					if field.annotation.item.kind == "api" {
						_matches: [for id, f in facts.symbols if id == field.annotation.item.api {f & {kind: "class"}}] & [_, ...]
					}
				}
			}]
		}]
	}
}
