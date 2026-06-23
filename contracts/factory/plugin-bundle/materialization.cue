package pluginbundle

#OverwritePolicy: "never" | "if-generated" | "replace-generated"

#MaterializationProvenance: close({
	kind:             "projection"
	sourceProjection: #NonEmptyString
	generatedFrom:    #NonEmptyString
})

#Materialization: close({
	let projectionID = sourceProjection

	id:               #NonEmptyString
	target:           #NonEmptyString
	sourceProjection: #NonEmptyString
	overwrite:        #OverwritePolicy
	provenance:       #MaterializationProvenance & {
		sourceProjection: projectionID
	}
})
