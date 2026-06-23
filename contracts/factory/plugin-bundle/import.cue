package pluginbundle

#BundleSource: close({
	repo: #NonEmptyString
	ref:  #NonEmptyString
	path: #NonEmptyString
})

#BundleTarget: close({
	repo: #NonEmptyString
	path: #NonEmptyString
})

#BundleMount: close({
	path: #NonEmptyString
	mode: "read-only" | "materialize"
})

#BundleSelection: close({
	components: [#NonEmptyString, ...#NonEmptyString]
})

#BundleOverlay: close({
	enabled: false
})

#ImportLock: close({
	path:             #NonEmptyString
	evidenceRequired: true
})

#BundleImport: close({
	source:  #BundleSource
	target:  #BundleTarget
	mount:   #BundleMount
	select:  #BundleSelection
	overlay: #BundleOverlay
	lock:    #ImportLock
})
