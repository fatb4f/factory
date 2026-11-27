package biowear

import (
	"list"
	"struct"
	"time"
	core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"
)

#ID:    string & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#URL:   string & =~"^https://[^[:space:]<>]+$"
#Text:  core.#NonEmptyString
#RunID: string & =~"^[0-9]{8}T[0-9]{6}Z$"
#SourceChannel: {source: #ID, channel: #ID}

profile: {
	id:             "biochemical-wearables"
	task:           "projects.biochemical-wearables.upstream-monitor"
	publication:    "projects/biochemical-wearables/upstream-monitor"
	reportTemplate: "projects/biochemical-wearables/.agents/report-template.md"
	focus:          "Non-invasive wearable biochemical sensing, especially sweat collection and wearable microfluidics"
	streams: ["trending", "emerging", "market"]
}

// A record identifies an original study, SKU listing, manual or interface specification.
// origin groups a paper, sponsor release and syndicated copies when they repeat one finding.
#Record: {
	#SourceChannel
	url:      #URL
	record:   #Text // DOI, SKU/market, manual identifier or equivalent
	origin:   #ID
	revision: #Text // dated version, archived revision or content fingerprint
	selector: #Text // table, figure, section, offer or method
	offerScope?: {models: [#Text, ...#Text], regions: [string & =~"^[A-Z]{2}$", ...string & =~"^[A-Z]{2}$"]}
	sourceDate?: string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
	if sourceDate != _|_ {_validDate: time.Parse("2006-01-02", sourceDate)}
}

#Quantity: "sweat-rate" | "fluid-loss" | "sodium" | "potassium" | "chloride" |
	"electrolyte-loss" | "glucose" | "lactate" | "skin-temperature" | "heat-strain" |
	"hydration-status" | "cortisol" | "stress" | "fatigue" | "workload" | "urea" | "uric-acid" | "cytokine" | "other-biochemical"

#Measurement: {
	quantity: #Quantity
	name?:    #Text
	if quantity == "cytokine" || quantity == "other-biochemical" {name: #Text}
	basis:  "measured" | "estimated" | "inferred" | "undisclosed"
	target: "local-sweat" | "skin" | "whole-body" | "blood-equivalent"
	unit:   #Text // use "unreported" when undisclosed
	ref:    #ID
	if target == "blood-equivalent" || target == "whole-body" {basis: "estimated" | "inferred"}
	if quantity == "fatigue" || quantity == "stress" || quantity == "heat-strain" || quantity == "workload" {
		basis: "inferred"
		inputs: [#Text, ...#Text]
	}
	if quantity == "fatigue" {inputs: [#Text, #Text, ...#Text] & list.UniqueItems()}
	if quantity == "skin-temperature" {target: "skin"}
	if target == "blood-equivalent" {validation: #StudyComparison & {matrix: "blood"}}
	if quantity == "hydration-status" {target: "whole-body", validation: #StudyComparison}
}

#StudyComparison: {
	ref:         #ID
	comparator:  #Text
	matrix?:     "blood" | "sweat" | "body-mass" | "other"
	sampleSize?: int & >0
	funding?:    #Text
	population:  #Text
	conditions:  #Text
	result:      #Text // units and reported agreement, uncertainty or limitations
}

// Distinguish explicit limits and unknowns. A file of calculated values can be
// accessible while the device's raw signal and wire protocol remain unknown.
#AccessEvidence: {
	status: "documented" | "tested" | "explicitly-unavailable" | "restricted"
	detail: #Text
	ref:    #ID
}
#Capability: "unknown" | #AccessEvidence

#CadenceEvidence: "unknown" | {
	#AccessEvidence
	status: _
	if status == "documented" || status == "tested" {
		// Neutral channel identifiers also allow a file row or a device-wide clock.
		channels: struct.MinFields(1) & {[#ID]: {
			mode: "periodic" | "variable" | "event-driven" | "undisclosed"
			if mode == "periodic" {
				minSeconds: number & >0
				maxSeconds: number & >=minSeconds
			}
		}}
	}
}

#Telemetry: {
	rawSamples:      #Capability
	bleProtocolDocs: #Capability
	csvExport:       #Capability
	otherFileExport: #Capability
	api:             #Capability
	android:         #Capability
	liveStream:      #Capability
	// Identify the channel, units and interval or variable-rate conditions for each known cadence.
	nativeSampling: #CadenceEvidence
	displayRefresh: #CadenceEvidence
	exportInterval: #CadenceEvidence
}

#Offer: {
	region: string & =~"^[A-Z]{2}$" // ISO 3166-1 alpha-2 market of the evidence
	status: "orderable" | "preorder" | "out-of-stock" | "contact-only" | "discontinued" | "unknown"
	if status != "unknown" {ref: #ID}

	shipping?: #Capability // fulfillment to the named market; omission means unverified
	price?: {amount: number & >=0, currency: string & =~"^[A-Z]{3}$", basis: #Text, ref: #ID}
}

#Device: {
	model:         #Text // include hardware revision, distinguish a research build from a retail successor
	collection:    "exercise-sweat" | "passive-sweat" | "induced-sweat" | "multiple" | "other-noninvasive" | "unknown"
	microfluidics: "documented" | "explicitly-absent" | "unknown"
	operatingLimits: [#Text, ...#Text] // onset, fresh sweat, inlet lag, wear duration, gaps or unknowns
	ref:                               #ID
	measurements: [#Measurement, ...#Measurement]
	comparisons?: [#StudyComparison, ...#StudyComparison]
}

#Item: {
	stream:      "market" | "emerging" | "trending"
	title:       #Text
	delta:       #Text
	disposition: "baseline" | "changed" | "lead"
	if stream == "market" {
		device:    #Device
		telemetry: #Telemetry
		// Always assess Canada, including when the only known offer is elsewhere.
		offers: {CA: #Offer & {region: "CA"}, [code=string]: #Offer & {region: code}}
		if disposition != "lead" {
			_hasMarketEvidence: true & list.Contains([for _, o in offers {o.status != "unknown"}], true)
		}
	}
	if stream == "emerging" {
		device: #Device
		stage:  "announced" | "bench" | "on-body-pilot" | "validation-study"
		if stage == "validation-study" {device: comparisons: [#StudyComparison, ...#StudyComparison]}
	}
	if stream == "trending" {
		disposition: "baseline" | "changed"
		trend: {indicator: #Text, earlier: #ID, later: #ID, change: #Text}
	}
}

#RunEvidence: {
	schema:             "factory.biochemical-wearables.upstream-watch/v1"
	profile_id:         profile.id
	run_id:             #RunID
	checkedAt:          time.Time & =~"Z$"
	authority_revision: core.#CommitSHA
	previous_run:       null | #RunID
	additionalSources:  #Channels
	let catalog = sources & additionalSources
	records: [#ID]: #Record
	items: [#ID]:   #Item
	coverageGaps: [...{#SourceChannel, reason: #Text, next: #Text}]
	if len(coverageGaps) == 0 {items: struct.MinFields(1)}
	let roles = {for id, r in records {"\(id)": catalog[r.source][r.channel].role}}
	let ids = [for id, _ in records {id}]
	for _, r in records {
		_sourceExists: true & list.Contains([for ch, _ in catalog[r.source] {ch}], r.channel)
	}
	for g in coverageGaps {
		_gapExists: true & list.Contains([for ch, _ in catalog[g.source] {ch}], g.channel)
	}
	for _, item in items {
		if item.stream == "trending" {
			let t = item.trend
			let a = records[t.earlier]
			let b = records[t.later]
			for ref in [t.earlier, t.later] {
				_exists: true & list.Contains(ids, ref)
				_sourceDatePresent: true & list.Contains([for field, _ in records[ref] {field}], "sourceDate")
			}
			_chronological: true & (a.sourceDate < b.sourceDate)
			_independent:   true & (a.origin != b.origin) & (a.record != b.record)
			for ref in [t.earlier, t.later] {_primary: true & (roles[ref] != "discovery")}
		}
		if item.stream != "trending" {
			let d = item.device

			// Companion temperature and workload channels alone cannot admit a wearable.
			let ancillary = ["skin-temperature", "heat-strain", "fatigue", "stress", "workload", "hydration-status"]
			_hasSensingOutput: true & list.Contains([for m in d.measurements {!list.Contains(ancillary, m.quantity)}], true)
			let supporting = [
				d.ref,
				for m in d.measurements {m.ref},
			]
			for ref in supporting {
				_exists: true & list.Contains(ids, ref)
				if item.disposition != "lead" {_primary: true & (roles[ref] != "discovery")}
			}
			for m in d.measurements if m.validation != _|_ {
				_exists:      true & list.Contains(ids, m.validation.ref)
				_pairedStudy: "study" & roles[m.validation.ref]
			}
			if d.comparisons != _|_ {for c in d.comparisons {_study: "study" & roles[c.ref]}}
			if item.stream == "emerging" {
				if item.stage != "announced" {_demonstration: "study" & roles[d.ref]}
			}
		}
		if item.stream == "market" {
			for _, o in item.offers {
				let offerRefs = [
					if o.status != "unknown" {o.ref},
					if o.price != _|_ {o.price.ref},
					for field, value in o if field == "shipping" if value != "unknown" {value.ref},
				]
				for ref in offerRefs {
					_offerScopePresent: true & list.Contains([for field, _ in records[ref] {field}], "offerScope")
					_regionSupported: true & list.Contains(records[ref].offerScope.regions, o.region)
					_modelSupported:  true & list.Contains(records[ref].offerScope.models, item.device.model)
				}
				if o.status != "unknown" {_seller: true & list.Contains(["vendor", "retailer"], roles[o.ref])}
				if o.shipping != _|_ {
					if o.shipping != "unknown" {_fulfillment: true & list.Contains(["vendor", "retailer"], roles[o.shipping.ref])}
				}
				if o.price != _|_ {_price: true & list.Contains(["vendor", "retailer"], roles[o.price.ref])}
			}
			for _, cap in item.telemetry if cap != "unknown" {_access: true & list.Contains(["vendor", "platform", "study"], roles[cap.ref])}
		}
	}
}

#Manifest: core.#RunBundleManifestV3 & {
	profile_id:          profile.id
	run_id:              #RunID
	terminal_state:      "terminal_success" | "coverage_gap"
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
