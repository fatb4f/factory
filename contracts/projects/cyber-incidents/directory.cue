package cyberincidents

// One sourced calendar day for browsing. Only the date is known at this precision.
#CatalogDate: {
	day:           string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
	_validDay:     #UTC & "\(day)T00:00:00Z"
	basis:         "observed-impact" | "public-disclosure" | "detection"
	publicClaimID: #ID
}

#CatalogBundle: #IncidentBundle & {
	incident: {
		stream:      watchStreams.primary
		catalogDate: #CatalogDate
	}
	view: mode: "review"

	// Each date in the directory links to the public sources cited by its claim.
	let claim = incident.publicClaims[incident.catalogDate.publicClaimID]
	for citation in claim.citations {
		acquisition: captures: (citation.captureID): {
			locator: =~"^https://[^[:space:]<>]+$"
		}
	}
}
