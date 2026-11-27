package biowear

#Channel: {
	role: "vendor" | "retailer" | "study" | "discovery" | "platform"
	url:  #URL
}
#Channels: [#ID]: [#ID]: #Channel

// Acquisition starting points. Each run captures the specific dated page, study
// or offer supporting a claim, including the model and region it applies to.
sources: #Channels & {
	nix: {
		product: {role: "vendor", url: "https://nixbiosensors.com/products/hydration-biosensor"}
		canada: {role: "vendor", url: "https://nixbiosensors.com/en-ca/pages/shop"}
		calculations: {role: "vendor", url: "https://nixbiosensors.com/pages/article-nix-app-calculations"}
		export: {role: "vendor", url: "https://nixbiosensors.com/pages/tech-tips-exporting-workout-data"}
	}
	hdrop: {
		product: {role: "vendor", url: "https://hdroptech.com/product/hdrop-gen-2-wearable-hydration/"}
		integrations: {role: "vendor", url: "https://hdroptech.com/hdrop-data-integrations/"}
		trainingpeaks: {role: "vendor", url: "https://hdroptech.com/hdrop-integrates-trainingpeaks/"}
	}
	flowbio: {
		product: {role: "vendor", url: "https://flowbio.com/products/flowbio-sensor"}
		history: {role: "vendor", url: "https://flowbio.com/pages/become-a-partner"}
	}
	viaciclante: canada: {role: "retailer", url: "https://viaciclante.com/products/flowbio-sensor-wearable"}
	wahoo: fit: {role: "platform", url: "https://support.wahoofitness.com/hc/en-us/articles/35617816675474-Use-FLOWBIO-sweat-sensor-with-ELEMNT-ACE-ROAM-3-and-BOLT-3"}
	onalabs: {
		product: {role: "vendor", url: "https://onalabs.com/en/product/onasport/"}
		help: {role: "vendor", url: "https://onalabs.com/en/helpcenter/"}
		manual: {role: "vendor", url: "https://onalabs.com/wp-content/uploads/2025/01/USER-MANUAL-ONASPORT-V.ENG_compressed.pdf"}
		shipping: {role: "vendor", url: "https://onalabs.com/en/terms-and-conditions/"}
	}
	europepmc: search: {role: "discovery", url: "https://www.ebi.ac.uk/europepmc/webservices/rest/search"}
	crossref: works: {role: "discovery", url: "https://api.crossref.org/works"}
	clinicaltrials: search: {role: "discovery", url: "https://clinicaltrials.gov/api/v2/studies"}
	frontiers: "flowbio-s1": {role: "study", url: "https://doi.org/10.3389/fphys.2025.1717275"}
	aaas: {
		"exercise-lactate": {role: "study", url: "https://doi.org/10.1126/scitranslmed.ado5366"}
		"multiday-sweat": {role: "study", url: "https://doi.org/10.1126/sciadv.adw9024"}
		"sweat-chloride": {role: "study", url: "https://doi.org/10.1126/sciadv.abe3929"}
	}
	matter: cortisol: {role: "study", url: "https://doi.org/10.1016/j.matt.2020.01.021"}
	acs: cytokines: {role: "study", url: "https://doi.org/10.1021/acssensors.4c03728"}
	acs: "sequential-cortisol": {role: "study", url: "https://doi.org/10.1021/acs.analchem.6c03183"}
	talanta: "urea-uric-acid": {role: "study", url: "https://doi.org/10.1016/j.talanta.2025.128039"}
	biosensors: "glucose-lactate-electrolytes": {role: "study", url: "https://doi.org/10.1016/j.bios.2026.118746"}
}

// A source and its channel must resolve as a pair in the selected catalogue.
#SeedRef: #SourceChannel & or([for sourceID, channels in sources for channelID, _ in channels {
	{source: sourceID, channel: channelID}
}])
#SeedProduct: {
	displayName: string & !=""
	model:       string & !=""
	watch: [#SeedRef, ...#SeedRef]
	notes?: string & !=""
}

seedProducts: [#ID]: #SeedProduct
seedProducts: {
	"nix-hydration": {
		displayName: "Nix Hydration Biosensor"
		model:       "STOSB01U001"
		watch: [{source: "nix", channel: "product"}, {source: "nix", channel: "canada"},
			{source: "nix", channel: "calculations"}, {source: "nix", channel: "export"}]
	}
	"hdrop-gen-2": {
		displayName: "hDrop Gen 2"
		model:       "Gen 2"
		watch: [{source: "hdrop", channel: "product"}, {source: "hdrop", channel: "integrations"},
			{source: "hdrop", channel: "trainingpeaks"}]
	}
	"flowbio-s1": {
		displayName: "FLOWBIO S1"
		model:       "S1"
		watch: [{source: "flowbio", channel: "history"}, {source: "frontiers", channel: "flowbio-s1"}]
		notes: "Identify the tested generation in each paper before comparing results with later hardware."
	}
	"flowbio-sensor": {
		displayName: "FLOWBIO Sensor"
		model:       "FLOWBIO Sensor"
		watch: [{source: "flowbio", channel: "product"}, {source: "flowbio", channel: "history"},
			{source: "viaciclante", channel: "canada"}, {source: "wahoo", channel: "fit"}]
		notes: "Verify hardware and receiver compatibility for each export or live-data claim."
	}
	onasport: {
		displayName: "Onalabs ONASPORT"
		model:       "ONASPORT with ONAS10 cartridge"
		watch: [{source: "onalabs", channel: "product"}, {source: "onalabs", channel: "help"},
			{source: "onalabs", channel: "manual"}, {source: "onalabs", channel: "shipping"}]
	}
}

// Search across manufacturers and studies each run. A seed or registry match
// is a lead; maturity, availability and validation are evaluated per finding.
researchDiscovery: {
	watch: [#SeedRef, ...#SeedRef] & [
		{source: "europepmc", channel: "search"}, {source: "crossref", channel: "works"},
		{source: "clinicaltrials", channel: "search"},
	]
	query: "(wearable OR epidermal OR skin-interfaced) AND (sweat OR perspiration) AND (microfluidic OR biosensor OR biochemical OR electrochemical OR colorimetric)"
	analytes: ["sodium", "potassium", "chloride", "glucose", "lactate", "cortisol", "urea", "uric acid", "cytokines"]
	method: "Search the run window using the broad query and analyte-specific variants. Resolve DOI, trial ID, study population, sweat collection conditions and model. Follow newly found devices to their manufacturers and regional sellers. Record the query, window and any inaccessible sources."
	referenceStudies: [#SeedRef, ...#SeedRef] & [
		{source: "aaas", channel: "exercise-lactate"}, {source: "aaas", channel: "multiday-sweat"},
		{source: "aaas", channel: "sweat-chloride"}, {source: "matter", channel: "cortisol"},
		{source: "acs", channel: "cytokines"}, {source: "frontiers", channel: "flowbio-s1"},
		{source: "acs", channel: "sequential-cortisol"}, {source: "talanta", channel: "urea-uric-acid"},
		{source: "biosensors", channel: "glucose-lactate-electrolytes"},
	]
}
