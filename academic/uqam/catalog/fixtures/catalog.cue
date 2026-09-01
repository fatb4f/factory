package uqamcatalogfixtures

import catalog "github.com/fatb4f/factory/contracts/academic/uqam/catalog"

fixture: catalog.#NormalizedSnapshot & {
	task_id:     "academic.uqam.catalog"
	schema:      "uqam-catalog/v1"
	observed_at: "2026-09-01T00:00:00-04:00"
	observations: [
		{
			id:               "obs:student-services"
			source:           "uqam-student-services"
			channel:          "public-web"
			ref:              "https://portailetudiant.uqam.ca/services/"
			observed_surface: "UQAM student services index"
			acquired_at:      "2026-09-01T00:00:00-04:00"
		},
		{
			id:               "obs:student-cafes"
			source:           "uqam-student-cafes"
			channel:          "public-web"
			ref:              "https://portailetudiant.uqam.ca/implication/cafes-etudiants/"
			observed_surface: "Official UQAM student-café directory"
			acquired_at:      "2026-09-01T00:00:00-04:00"
		},
	]
	entities: [
		{
			id:          "uqam:institution"
			kind:        "institution"
			name:        "Université du Québec à Montréal"
			status:      "active"
			primary_url: "https://uqam.ca/"
			evidence:    ["obs:student-services"]
		},
		{
			id:          "uqam:cafe:aquin"
			kind:        "cafe"
			name:        "Café Aquin"
			status:      "active"
			primary_url: "https://portailetudiant.uqam.ca/implication/cafes-etudiants/"
			location: {room: "A-2030"}
			audiences: ["student"]
			evidence: ["obs:student-cafes"]
		},
	]
	relations: []
}
