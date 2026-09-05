package industrialconstraints

#SourceID:
	"gdelt" |
	"google-bigquery" |
	"gc-grants" |
	"canadabuys" |
	"statcan" |
	"quebec-enterprise-register" |
	"hydro-quebec" |
	"institutional-web" |
	"operator-supplier-web"

#AcquisitionMode: "bigquery" | "http" | "bulk" | "api"

#AuthorityRole:
	"discovery" |
	"primary-record" |
	"measurement" |
	"asserted-event"

#RecordIdentitySemantics:
	"stable-source-id" |
	"composite-source-key"

#RevisionSemantics:
	"source-version" |
	"dataset-snapshot" |
	"publication-date" |
	"record-update-time" |
	"query-window"

#CursorSemantics:
	"none" |
	"source-cursor" |
	"modified-since" |
	"date-window" |
	"snapshot-diff"

#Channel: close({
	id:             #ChannelID
	dataset:        string
	authorityRole:  #AuthorityRole
	expectedRecords: [...#RecordKind] & [_, ...]
	recordIdentity: #RecordIdentitySemantics
	revision:       #RevisionSemantics
	cursor:         #CursorSemantics
})

#Source: close({
	id:          #SourceID
	acquisition: close({
		modes: [...#AcquisitionMode] & [_, ...]
		provider?: string
	})
	channels: [string]: #Channel
})

sources: close({
	gdelt: #Source & {
		id: "gdelt"
		acquisition: {
			modes: ["bigquery"]
			provider: "google-bigquery"
		}
		channels: {
			events: {
				id: "events"
				dataset: "gdelt-bq.gdeltv2.events"
				authorityRole: "discovery"
				expectedRecords: ["document", "event"]
				recordIdentity: "composite-source-key"
				revision: "query-window"
				cursor: "date-window"
			}
		}
	}

	"google-bigquery": #Source & {
		id: "google-bigquery"
		acquisition: {modes: ["bigquery"]}
		channels: {
			"google-patents": {
				id: "google-patents"
				dataset: "patents-public-data.patents.publications"
				authorityRole: "primary-record"
				expectedRecords: ["document", "entity", "relation"]
				recordIdentity: "stable-source-id"
				revision: "dataset-snapshot"
				cursor: "snapshot-diff"
			}
		}
	}

	"gc-grants": #Source & {
		id: "gc-grants"
		acquisition: {modes: ["bulk", "http"]}
		channels: {
			awards: {
				id: "awards"
				dataset: "Government of Canada Grants and Contributions"
				authorityRole: "primary-record"
				expectedRecords: ["document", "event", "relation"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
		}
	}

	canadabuys: #Source & {
		id: "canadabuys"
		acquisition: {modes: ["bulk", "api"]}
		channels: {
			procurement: {
				id: "procurement"
				dataset: "CanadaBuys tenders awards and contracts"
				authorityRole: "primary-record"
				expectedRecords: ["document", "event", "relation"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
		}
	}

	statcan: #Source & {
		id: "statcan"
		acquisition: {modes: ["api", "bulk"]}
		channels: {
			tables: {
				id: "tables"
				dataset: "Statistics Canada data tables"
				authorityRole: "measurement"
				expectedRecords: ["document", "measurement"]
				recordIdentity: "composite-source-key"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	"quebec-enterprise-register": #Source & {
		id: "quebec-enterprise-register"
		acquisition: {modes: ["bulk"]}
		channels: {
			enterprises: {
				id: "enterprises"
				dataset: "Registraire des entreprises open data"
				authorityRole: "primary-record"
				expectedRecords: ["document", "entity", "relation"]
				recordIdentity: "stable-source-id"
				revision: "dataset-snapshot"
				cursor: "snapshot-diff"
			}
		}
	}

	"hydro-quebec": #Source & {
		id: "hydro-quebec"
		acquisition: {modes: ["api", "bulk", "http"]}
		channels: {
			"open-data": {
				id: "open-data"
				dataset: "Hydro-Quebec open data"
				authorityRole: "measurement"
				expectedRecords: ["document", "measurement", "event"]
				recordIdentity: "composite-source-key"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	"institutional-web": #Source & {
		id: "institutional-web"
		acquisition: {modes: ["http"]}
		channels: {
			"official-publication": {
				id: "official-publication"
				dataset: "Official public institutional publications"
				authorityRole: "asserted-event"
				expectedRecords: ["document", "event-observation"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
		}
	}

	"operator-supplier-web": #Source & {
		id: "operator-supplier-web"
		acquisition: {modes: ["http"]}
		channels: {
			"official-publication": {
				id: "official-publication"
				dataset: "Official operator and supplier publications"
				authorityRole: "asserted-event"
				expectedRecords: ["document", "event-observation"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
		}
	}
})

_sourceIdentity: [for id, source in sources {
	_value: source & {id: id}
	_channelIdentity: [for channelID, channel in source.channels {
		_value: channel & {id: channelID}
	}]
}]
