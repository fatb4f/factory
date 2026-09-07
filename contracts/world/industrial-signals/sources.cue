package industrialsignals

#IndustrialSourceID:
	"gdelt" |
	"google-bigquery" |
	"gc-grants" |
	"canadabuys" |
	"statcan" |
	"quebec-enterprise-register" |
	"hydro-quebec" |
	"nserc" |
	"openalex" |
	"ror" |
	"cipo" |
	"ati-atip" |
	"institutional-web" |
	"operator-supplier-web" |
	"regulatory-standards-web"

#IndustrialAcquisitionMode:
	"browser" |
	"bigquery" |
	"http" |
	"bulk" |
	"api" |
	"request" |
	"released-package"

#IndustrialSourceRole:
	"discovery" |
	"primary-record" |
	"measurement" |
	"asserted-event" |
	"identity-support" |
	"funding-accountability" |
	"follow-through" |
	"access-recovery"

#IndustrialAdmissionUse: "discovery-only" | "source-qualified-candidate"

#IndustrialRecordIdentitySemantics:
	"stable-source-id" |
	"composite-source-key"

#IndustrialRevisionSemantics:
	"source-version" |
	"dataset-snapshot" |
	"publication-date" |
	"record-update-time" |
	"query-window" |
	"request-package-version"

#IndustrialCursorSemantics:
	"none" |
	"source-cursor" |
	"modified-since" |
	"date-window" |
	"snapshot-diff" |
	"request-follow-up"

#IndustrialWatchDetailKind:
	"signal" |
	"action" |
	"funding-award" |
	"funding-flow" |
	"project-milestone" |
	"innovation-exposure" |
	"outcome"

#IndustrialSourceChannel: close({
	id:              string
	dataset:         string
	roles:           [...#IndustrialSourceRole] & [_, ...]
	admissionUse:    #IndustrialAdmissionUse
	expectedDetails?: [...#IndustrialWatchDetailKind]
	recordIdentity:  #IndustrialRecordIdentitySemantics
	revision:        #IndustrialRevisionSemantics
	cursor:          #IndustrialCursorSemantics
	notes?:          string
})

#IndustrialSource: close({
	id: #IndustrialSourceID
	acquisition: close({
		modes:     [...#IndustrialAcquisitionMode] & [_, ...]
		provider?: string
	})
	channels: [string]: #IndustrialSourceChannel
})

#IndustrialAcquisitionOutcome:
	"record-acquired" |
	"record-acquired-identity-unresolved" |
	"record-acquired-evidence-insufficient" |
	"source-unavailable" |
	"source-inaccessible" |
	"source-machine-unreadable" |
	"expected-follow-through-unavailable"

#IndustrialCoverageGapKind:
	"source-unavailable" |
	"source-inaccessible" |
	"machine-unreadable" |
	"identity-unresolved" |
	"relationship-unresolved" |
	"follow-through-missing" |
	"historically-incomplete" |
	"other"

#IndustrialFollowThroughStage:
	"award" |
	"disbursement" |
	"expenditure" |
	"milestone" |
	"commissioning-production" |
	"outcome" |
	"commercialization" |
	"pilot" |
	"qualification" |
	"deployment" |
	"other"

#IndustrialAcquisitionAttempt: close({
	source:             #IndustrialSourceID
	channel:            string
	mode:               #IndustrialAcquisitionMode
	outcome:            #IndustrialAcquisitionOutcome
	acquiredAt:         #Timestamp
	recordID?:          string
	revision?:          string
	observedSurface?:   string
	payloadDigest?:     #Digest
	gapKind?:           #IndustrialCoverageGapKind
	followThroughStage?: #IndustrialFollowThroughStage
	note?:              string
})

industrialSources: close({
	gdelt: #IndustrialSource & {
		id: "gdelt"
		acquisition: {
			modes: ["bigquery"]
			provider: "google-bigquery"
		}
		channels: {
			events: {
				id: "events"
				dataset: "gdelt-bq.gdeltv2.events"
				roles: ["discovery"]
				admissionUse: "discovery-only"
				expectedDetails: ["signal", "action", "project-milestone"]
				recordIdentity: "composite-source-key"
				revision: "query-window"
				cursor: "date-window"
				notes: "GDELT is a discovery surface. A GDELT event does not substitute for primary industrial evidence."
			}
		}
	}

	"google-bigquery": #IndustrialSource & {
		id: "google-bigquery"
		acquisition: {modes: ["bigquery"]}
		channels: {
			"google-patents": {
				id: "google-patents"
				dataset: "patents-public-data.patents.publications"
				roles: ["primary-record", "identity-support"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["innovation-exposure", "action"]
				recordIdentity: "stable-source-id"
				revision: "dataset-snapshot"
				cursor: "snapshot-diff"
				notes: "Google BigQuery is also the acquisition provider for the GDELT events channel."
			}
		}
	}

	"gc-grants": #IndustrialSource & {
		id: "gc-grants"
		acquisition: {modes: ["bulk", "http", "browser"]}
		channels: {
			awards: {
				id: "awards"
				dataset: "Government of Canada Grants and Contributions"
				roles: ["primary-record", "funding-accountability", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["funding-award", "funding-flow", "project-milestone"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
		}
	}

	canadabuys: #IndustrialSource & {
		id: "canadabuys"
		acquisition: {modes: ["bulk", "api", "http", "browser"]}
		channels: {
			procurement: {
				id: "procurement"
				dataset: "CanadaBuys tenders awards and contracts"
				roles: ["primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "funding-flow", "project-milestone"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
		}
	}

	statcan: #IndustrialSource & {
		id: "statcan"
		acquisition: {modes: ["api", "bulk", "http", "browser"]}
		channels: {
			tables: {
				id: "tables"
				dataset: "Statistics Canada data tables"
				roles: ["measurement"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	"quebec-enterprise-register": #IndustrialSource & {
		id: "quebec-enterprise-register"
		acquisition: {modes: ["bulk", "http", "browser"]}
		channels: {
			enterprises: {
				id: "enterprises"
				dataset: "Registraire des entreprises open data"
				roles: ["primary-record", "identity-support"]
				admissionUse: "source-qualified-candidate"
				recordIdentity: "stable-source-id"
				revision: "dataset-snapshot"
				cursor: "snapshot-diff"
			}
		}
	}

	"hydro-quebec": #IndustrialSource & {
		id: "hydro-quebec"
		acquisition: {modes: ["api", "bulk", "http", "browser"]}
		channels: {
			"open-data": {
				id: "open-data"
				dataset: "Hydro-Quebec open data"
				roles: ["measurement", "asserted-event"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	nserc: #IndustrialSource & {
		id: "nserc"
		acquisition: {modes: ["bulk", "http", "browser"]}
		channels: {
			"awards-partnerships": {
				id: "awards-partnerships"
				dataset: "NSERC awards and partnership records"
				roles: ["primary-record", "funding-accountability", "follow-through", "identity-support"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["funding-award", "action", "innovation-exposure", "project-milestone"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
		}
	}

	openalex: #IndustrialSource & {
		id: "openalex"
		acquisition: {modes: ["api", "bulk", "http"]}
		channels: {
			"works-organizations": {
				id: "works-organizations"
				dataset: "OpenAlex works and organization metadata"
				roles: ["discovery", "identity-support"]
				admissionUse: "discovery-only"
				expectedDetails: ["innovation-exposure"]
				recordIdentity: "stable-source-id"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	ror: #IndustrialSource & {
		id: "ror"
		acquisition: {modes: ["api", "bulk", "http"]}
		channels: {
			organizations: {
				id: "organizations"
				dataset: "Research Organization Registry"
				roles: ["identity-support"]
				admissionUse: "source-qualified-candidate"
				recordIdentity: "stable-source-id"
				revision: "source-version"
				cursor: "modified-since"
			}
		}
	}

	cipo: #IndustrialSource & {
		id: "cipo"
		acquisition: {modes: ["bulk", "http", "browser"]}
		channels: {
			"ip-horizons": {
				id: "ip-horizons"
				dataset: "CIPO / IP Horizons patent data"
				roles: ["primary-record", "identity-support"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["innovation-exposure", "action"]
				recordIdentity: "stable-source-id"
				revision: "dataset-snapshot"
				cursor: "snapshot-diff"
			}
		}
	}

	"ati-atip": #IndustrialSource & {
		id: "ati-atip"
		acquisition: {modes: ["bulk", "http", "browser", "request", "released-package"]}
		channels: {
			"completed-request-summaries": {
				id: "completed-request-summaries"
				dataset: "Government of Canada completed Access to Information request summaries"
				roles: ["discovery", "access-recovery"]
				admissionUse: "discovery-only"
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
			"released-packages": {
				id: "released-packages"
				dataset: "Previously released ATI/ATIP record packages"
				roles: ["primary-record", "access-recovery", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["funding-flow", "project-milestone", "action", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "request-package-version"
				cursor: "request-follow-up"
			}
			"targeted-requests": {
				id: "targeted-requests"
				dataset: "Institution-specific ATI/ATIP requests"
				roles: ["access-recovery", "follow-through"]
				admissionUse: "source-qualified-candidate"
				recordIdentity: "composite-source-key"
				revision: "request-package-version"
				cursor: "request-follow-up"
			}
		}
	}

	"institutional-web": #IndustrialSource & {
		id: "institutional-web"
		acquisition: {modes: ["http", "browser"]}
		channels: {
			"government-of-canada": {
				id: "government-of-canada"
				dataset: "Official Government of Canada institutional publications"
				roles: ["asserted-event", "primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["funding-award", "funding-flow", "action", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			"government-of-quebec": {
				id: "government-of-quebec"
				dataset: "Official Government of Quebec institutional publications"
				roles: ["asserted-event", "primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["funding-award", "funding-flow", "action", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			nrc: {
				id: "nrc"
				dataset: "National Research Council Canada official publications and program/project records"
				roles: ["asserted-event", "primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["action", "innovation-exposure", "funding-award", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			ised: {
				id: "ised"
				dataset: "Innovation Science and Economic Development Canada official publications and program/project records"
				roles: ["asserted-event", "primary-record", "funding-accountability", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "funding-award", "funding-flow", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			nrcan: {
				id: "nrcan"
				dataset: "Natural Resources Canada official publications and program/project records"
				roles: ["asserted-event", "primary-record", "funding-accountability", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "funding-award", "funding-flow", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			c2mi: {
				id: "c2mi"
				dataset: "C2MI official publications and project/technology-transfer records"
				roles: ["asserted-event", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["action", "innovation-exposure", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			cmc: {
				id: "cmc"
				dataset: "CMC Microsystems official publications and project/technology-transfer records"
				roles: ["asserted-event", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["action", "innovation-exposure", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
			"selected-universities": {
				id: "selected-universities"
				dataset: "Selected university, college, institute, research-network and technology-transfer publications"
				roles: ["asserted-event", "identity-support", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["action", "innovation-exposure", "funding-award", "project-milestone", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
		}
	}

	"operator-supplier-web": #IndustrialSource & {
		id: "operator-supplier-web"
		acquisition: {modes: ["http", "browser"]}
		channels: {
			"official-publication": {
				id: "official-publication"
				dataset: "Official operator, supplier, customer, project-proponent and facility publications"
				roles: ["asserted-event", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "funding-flow", "project-milestone", "innovation-exposure", "outcome"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
		}
	}

	"regulatory-standards-web": #IndustrialSource & {
		id: "regulatory-standards-web"
		acquisition: {modes: ["http", "browser", "api", "bulk"]}
		channels: {
			"regulatory-filings": {
				id: "regulatory-filings"
				dataset: "Official regulatory filings and operational disclosures"
				roles: ["primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "funding-flow", "project-milestone", "outcome"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
			"permits-approvals": {
				id: "permits-approvals"
				dataset: "Official permit, approval and authorization records"
				roles: ["primary-record", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["action", "project-milestone"]
				recordIdentity: "stable-source-id"
				revision: "record-update-time"
				cursor: "modified-since"
			}
			"standards-participation": {
				id: "standards-participation"
				dataset: "Official standards-body participation, qualification and standards-change records"
				roles: ["primary-record", "asserted-event", "follow-through"]
				admissionUse: "source-qualified-candidate"
				expectedDetails: ["signal", "action", "innovation-exposure", "project-milestone"]
				recordIdentity: "composite-source-key"
				revision: "publication-date"
				cursor: "date-window"
			}
		}
	}
})

_sourceIdentity: [for sourceID, source in industrialSources {
	_value: source & {id: sourceID}
	_channelIdentity: [for channelID, channel in source.channels {
		_value: channel & {id: channelID}
	}]
}]
