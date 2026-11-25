package upstream

// Availability describes the proposed route, not the absence of other mirrors.
#BigQueryAccess: {
	availability: "native-public" | "third-party-public" | "indirect" | "requires-ingestion" | "not-applicable" | "unverified"
	if availability == "native-public" || availability == "third-party-public" {
		dataset:             string & !=""
		verification_source: string & !=""
	}
	read_only: true
}

// These are requirements for future adapters, not evidence of enforcement.
bigqueryPolicy: {
	read_only:            true
	partition_filter:     "required when the selected table is partitioned; inspect schema first"
	query_budget:         "set a maximum bytes billed and bounded time or scope before execution"
	capture:              "retain immutable results with a content digest"
	provenance:           "record source, dataset, table, query, parameters, execution time, billing project, schema and capture digest"
	live_access_verified: false
}

bigqueryResources: {
	gdelt: {
		dataset:              "gdelt-bq.gdeltv2"
		tables:               ["events_partitioned", "eventmentions_partitioned", "gkg_partitioned", "gdg_partitioned"]
		verification_sources: ["https://blog.gdeltproject.org/announcing-partitioned-gdelt-bigquery-tables/", "https://blog.gdeltproject.org/announcing-the-gdelt-global-difference-graph-gdg-planetary-scale-change-detection-for-the-global-news-media/"]
	}
	openalex: {
		dataset:              "multiobs.publicdb_openalex_2026_09_rm"
		verification_sources: ["https://www.multiobs.org/infrastructure/updates/openalex-2026-09"]
	}
}
