package uqameventsfixtures

import events "github.com/fatb4f/factory/contracts/academic/uqam/events"

communityEvent: events.#NormalizedEvent & {
	identity: {
		key:             "https://portailetudiant.uqam.ca/nouvelle/implicationetudiante/le-rendez-vous-de-la-vie-etudiante/"
		basis:           "primary-url"
		organizer:       "Services à la réussite et à la vie étudiante — UQAM"
		canonical_title: "Le Rendez-vous de la vie étudiante"
		primary_url:     "https://portailetudiant.uqam.ca/nouvelle/implicationetudiante/le-rendez-vous-de-la-vie-etudiante/"
	}
	kind:                "student-group"
	title:               "Le Rendez-vous de la vie étudiante"
	starts_at:           "2026-09-22T12:30:00-04:00"
	ends_at:             "2026-09-23T14:00:00-04:00"
	location:            "Agora du pavillon Judith-Jasmin"
	scope:               "Student-group discovery fair and campus involvement"
	registration_status: "not-required"
	organizer_entity_id: "uqam:administrative-unit:srve"
	primary_url:         "https://portailetudiant.uqam.ca/nouvelle/implicationetudiante/le-rendez-vous-de-la-vie-etudiante/"
	evidence: [{
		source:           "uqam-student-life"
		channel:          "public-web"
		ref:              "https://portailetudiant.uqam.ca/nouvelle/implicationetudiante/le-rendez-vous-de-la-vie-etudiante/"
		observed_surface: "Official Portail étudiant announcement for the September 22-23 student-group fair"
		acquired_at:      "2026-09-01T16:00:00-04:00"
		content_digest:   "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}]
	content_digest: "sha256:1111111111111111111111111111111111111111111111111111111111111111"
}
