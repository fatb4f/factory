package uqamcatalogfixtures

import catalog "github.com/fatb4f/factory/contracts/academic/uqam/catalog"

fixtureObservations: catalog.#ObservationSet & {
	observations: [{
		id:               "obs:student-services"
		source:           "uqam-student-services"
		channel:          "public-web"
		ref:              "https://portailetudiant.uqam.ca/services/"
		observed_surface: "UQAM student services index"
		acquired_at:      "2026-09-01T00:00:00-04:00"
	}]
}

fixtureEntities: catalog.#EntitySet & {
	entities: [{
		id:          "uqam:institution"
		kind:        "institution"
		name:        "Université du Québec à Montréal"
		status:      "active"
		primary_url: "https://uqam.ca/"
		evidence:    ["obs:student-services"]
	}]
}

fixtureRelations: catalog.#RelationSet & {relations: []}

fixtureIndex: catalog.#NormalizedSnapshot & {
	task_id:     "academic.uqam.catalog"
	schema:      "uqam-catalog/v1"
	observed_at: "2026-09-01T00:00:00-04:00"
	observations: {
		kind:   "observations"
		path:   "observations.json"
		digest: "sha256:0000000000000000000000000000000000000000000000000000000000000000"
		rows:   1
	}
	entity_shards: [{
		kind:   "entities"
		path:   "entities/core.json"
		digest: "sha256:1111111111111111111111111111111111111111111111111111111111111111"
		rows:   1
	}]
	relation_shards: []
}
