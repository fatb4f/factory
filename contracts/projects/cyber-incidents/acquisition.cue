package cyberincidents

import (
	"list"
	"time"
)

#ID:   string & =~"^[a-z0-9][a-z0-9._-]*$"
#Text: string & !=""
#IDs: [#ID, ...#ID]

// UTC, second precision gives one canonical representation and sortable values.
#UTC: time.Time & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"

#Source: {
	publisher: #Text
	channel:   #Text
	kind:      "official" | "mainstream-media" | "technical" | "archive" | "reference-catalog"
	format:    "stix-2.1" | "stix-2.0" | "misp-json" | "document"
	transport: "file" | "https" | "taxii-2.1"
	locator:   #Text
	if transport == "taxii-2.1" {
		format:       "stix-2.1"
		collectionID: #Text
	}
}

#Capture: {
	sourceID:      #ID
	revision:      #Text
	locator:       #Text
	contentSHA256: string & =~"^[a-f0-9]{64}$"
	retrievedAt:   #UTC
	// Availability concerns this specific revision, not the first article URL.
	availability: {
		state: "documented" | "unknown"
		if state == "documented" {
			at:    #UTC
			basis: #Text
		}
		if state == "unknown" {
			reason: #Text
		}
	}
	lineageKey: #ID
}

#CoverageGap: {
	sourceID: #ID
	reason:   #Text
}

#Acquisition: {
	schema: "factory.cyber-incidents.acquisition/v0.1"
	runID:  #ID
	sources: [#ID]:  #Source
	captures: [#ID]: #Capture
	gaps: [...#CoverageGap]

	let sourceIDs = [for id, _ in sources {id}]
	for _, c in captures {
		_capturesResolve: true & list.Contains(sourceIDs, c.sourceID)
		if c.availability.state == "documented" {
			_availabilityOrder: true & (c.availability.at <= c.retrievedAt)
		}
	}
	for g in gaps {
		_gapsResolve: true & list.Contains(sourceIDs, g.sourceID)
	}
}
