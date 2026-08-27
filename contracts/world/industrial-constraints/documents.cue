package industrialconstraints

#DocumentKind:
	"event-record" |
	"grant-award" |
	"tender" |
	"statistical-record" |
	"energy-record" |
	"patent" |
	"corporate-release" |
	"government-announcement" |
	"regulatory-filing" |
	"source-record"

#Document: close({
	kind:       "document"
	id:         #RecordID
	documentKind: #DocumentKind
	provenance: #Provenance
	uri?:       string
	digest?:    string
	contentType?: string
})
