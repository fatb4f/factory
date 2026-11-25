package upstream

#Source: {
	name:        string & !=""
	acquisition: string & !=""
	bigquery:    #BigQueryAccess
}

sources: [string]: #Source
sources: {
	gdelt:      {name: "GDELT", acquisition: "gdelt-bq", bigquery: {availability: "native-public", dataset: bigqueryResources.gdelt.dataset, verification_source: bigqueryResources.gdelt.verification_sources[0], read_only: true}}
	cameo:      {name: "CAMEO", acquisition: "GDELT event classifications; standalone vocabulary import", bigquery: {availability: "indirect", read_only: true}}
	eurepoc:    {name: "EuRepoC", acquisition: "CSV, JSON, XLSX", bigquery: {availability: "requires-ingestion", read_only: true}}
	hdcycon:    {name: "HD-CY.CON", acquisition: "CSV, XLSX", bigquery: {availability: "requires-ingestion", read_only: true}}
	iiss:       {name: "IISS Cyber Power Matrix", acquisition: "Published research and datasets", bigquery: {availability: "requires-ingestion", read_only: true}}
	dcid:       {name: "DCID 2.0", acquisition: "Harvard Dataverse", bigquery: {availability: "requires-ingestion", read_only: true}}
	guardint:   {name: "GUARD//INT", acquisition: "Uwazi repository", bigquery: {availability: "requires-ingestion", read_only: true}}
	spyware:    {name: "Commercial Spyware Inventory", acquisition: "Published research dataset", bigquery: {availability: "requires-ingestion", read_only: true}}
	misp:       {name: "MISP Galaxy and Taxonomies", acquisition: "JSON", bigquery: {availability: "requires-ingestion", read_only: true}}
	attack:     {name: "MITRE ATT&CK", acquisition: "STIX JSON, TAXII", bigquery: {availability: "requires-ingestion", read_only: true}}
	disarm:     {name: "DISARM", acquisition: "Structured repository", bigquery: {availability: "requires-ingestion", read_only: true}}
	cco:        {name: "CCO / IAO-Intel", acquisition: "OWL/RDF where available", bigquery: {availability: "requires-ingestion", read_only: true}}
	attackflow: {name: "Attack Flow", acquisition: "JSON/STIX", bigquery: {availability: "requires-ingestion", read_only: true}}
	cacao:      {name: "CACAO", acquisition: "JSON", bigquery: {availability: "requires-ingestion", read_only: true}}
	provo:      {name: "PROV-O / SKOS", acquisition: "RDF", bigquery: {availability: "requires-ingestion", read_only: true}}
	scor:       {name: "SCOR", acquisition: "MISP galaxies", bigquery: {availability: "indirect", read_only: true}}
	canada:     {name: "Canadian intelligence oversight", acquisition: "Official documents and records", bigquery: {availability: "requires-ingestion", read_only: true}}
	openalex:   {name: "OpenAlex", acquisition: "MultiOBS public BigQuery mirror", bigquery: {availability: "third-party-public", dataset: bigqueryResources.openalex.dataset, verification_source: bigqueryResources.openalex.verification_sources[0], read_only: true}}
}
