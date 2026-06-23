package pluginbundle

#FileDigest: close({
	path: #NonEmptyString
	hash: string & =~"^sha256:[0-9a-f]{64}$"
})

#BundleLock: close({
	apiVersion: "contract.cuemod/plugin-bundle/v0"
	kind:       "BundleLock"

	bundle: close({
		id:      #NonEmptyString
		version: #NonEmptyString
		hash:    string & =~"^sha256:[0-9a-f]{64}$"
	})

	selectedComponents: [#NonEmptyString, ...#NonEmptyString]
	materializedFiles:  [...#FileDigest]
	generatedArtifacts: [...#FileDigest]
	gates: [#NonEmptyString]: close({
		required: bool
		result:   "pass" | "fail"
	})

	authority: false
})
