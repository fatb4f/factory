package cyberwatch

import (
	"list"
	"struct"
	"time"
	core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"
)

#ID:     string & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#URL:    string & =~"^https://[^[:space:]<>]+$"
#RunID:  string & =~"^[0-9]{8}T[0-9]{6}Z$"
#Stream: "global-major-cyber" | "canadian-surveillance"
#Text:   core.#NonEmptyString
#Channel: {url: #URL, role: "primary" | "reporting" | "community"}
#Channels: [#ID]: [#ID]: #Channel

profile: {
	id:          "cyber-incidents"
	task:        "projects.cyber-incidents.upstream-monitor"
	root:        "projects/cyber-incidents"
	publication: "projects/cyber-incidents/upstream-monitor"
	streams: [#Stream]: string
	streams: {
		"global-major-cyber":    "Major incidents, reported exploitation and material downstream outcomes"
		"canadian-surveillance": "Canadian privacy, surveillance, online rights, oversight and public procurement"
	}
	reportTemplate: "projects/cyber-incidents/.agents/report-template.md"
}

#Citation: {
	source:      #ID
	channel:     #ID
	url:         #URL
	record:      #Text
	revision:    #Text
	selector:    #Text
	sourceDate?: string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
}

#Fact: {
	statement:  #Text
	eventAt?:   time.Time
	eventDate?: string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
	basis:      "primary" | "attributed"
	citations: [#Citation, ...#Citation]
}

#Item: {
	stream:       #Stream
	title:        #Text
	delta:        #Text
	disposition:  "material" | "baseline" | "lead"
	status:       #Text
	jurisdiction: #Text
	next:         #Text
	unknowns: [...#Text]
	facts: [#Fact, ...#Fact]
}

#RunEvidence: {
	schema:             "factory.cyber-incidents.upstream-watch/v1"
	profile_id:         profile.id
	run_id:             #RunID
	checkedAt:          time.Time & =~"Z$"
	authority_revision: core.#CommitSHA
	previous_run:       null | #RunID
	// New publishers are qualified by source and channel for this run.
	additionalSources: #Channels
	let catalog = sources & additionalSources
	items: [#ID]: #Item
	coverageGaps: [...{source: #ID, channel: #ID, reason: #Text, next: #Text}]
	for _, item in items {
		for fact in item.facts {
			for ref in fact.citations {
				_resolved: true & list.Contains([for c, _ in catalog[ref.source] {c}], ref.channel)
			}
			if fact.basis == "primary" {
				_primary: true & list.Contains([for ref in fact.citations {catalog[ref.source][ref.channel].role}], "primary")
			}
		}
		if item.disposition != "lead" {
			_evidenced: true & list.Contains([for fact in item.facts {fact.basis}], "primary")
		}
	}
	for gap in coverageGaps {
		_gapResolved: true & list.Contains([for c, _ in catalog[gap.source] {c}], gap.channel)
	}
	if len(coverageGaps) == 0 {items: struct.MinFields(1)}
}

#Manifest: core.#RunBundleManifestV3 & {
	profile_id:     profile.id
	run_id:         #RunID
	terminal_state: "terminal_success" | "coverage_gap"
	// Structural vetting qualifies the bundle shape. External events remain observations.
	qualification_state: "observation_only"
	artifacts: [
		{kind: "report", filename: "report.md", mediaType: "text/markdown"},
		{kind: "summary", filename: "summary.md", mediaType: "text/markdown"},
		{kind: "evidence", filename: "evidence.json", mediaType: "application/json"},
	]
}
#Pointer: core.#LatestRunPointer & {
	profile_id:    profile.id
	run_id:        #RunID
	bundle_path:   "\(profile.publication)/runs/\(run_id)"
	manifest_path: "\(bundle_path)/manifest.json"
}
