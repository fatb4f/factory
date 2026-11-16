package ivaccorpus

import (
	"time"
	ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"
)

// Acquisition observations are not admitted regulatory versions or legal findings.
#SourceKind:  "statute" | "regulation" | "directive" | "ethics-framework" | "legacy-policy" | "official-guidance" | "official-index"
#OfficialURL: string & =~"^https://(www\\.)?(ivac\\.qc\\.ca|cnesst\\.gouv\\.qc\\.ca|legisquebec\\.gouv\\.qc\\.ca|publicationsduquebec\\.gouv\\.qc\\.ca|donneesquebec\\.ca|laws-lois\\.justice\\.gc\\.ca|quebec\\.ca)/"
#CorpusEntry: close({
	id:         string & =~"^[a-z0-9][a-z0-9-]*$"
	title:      string & !=""
	category:   "governing" | "calculation" | "directives" | "ethics-oversight" | "concurrent" | "legacy" | "discovery"
	sourceKind: #SourceKind
	url:        #OfficialURL
	format:     "html" | "pdf" | "quebec-xml"
	instrument: string | null
})
#CorpusRequest: close({
	format: "ivac.official-corpus-request/v1"
	entries: [#CorpusEntry, ...#CorpusEntry]
})

// Exportable flat transport shape. Cross-field and byte constraints are checked
// against #CorpusManifest and by the verifier, not by row types alone.
#CorpusSourceRow: close({
	corpusID:         string & !=""
	sourceID:         string & =~"^[a-z0-9][a-z0-9-]*$"
	title:            string & !=""
	category:         string & !=""
	sourceKind:       #SourceKind
	requestedURL:     #OfficialURL
	finalURL:         #OfficialURL | null
	retrievedAt:      string & !=""
	status:           "acquired" | "failed"
	mediaType:        string | null
	artifactPath:     string | null
	artifactDigest:   ivac.#RegulatoryDigest | null
	artifactBytes:    (int & >=1) | null
	textPath:         string | null
	textDigest:       ivac.#RegulatoryDigest | null
	conversion:       string | null
	converterVersion: string | null
	containerPath:    string | null
	containerDigest:  ivac.#RegulatoryDigest | null
	memberPath:       string | null
	error:            string | null
	publicationDate:  ivac.#RegulatoryDate | null
	consolidatedAsOf: ivac.#RegulatoryDate | null
	effectiveFrom:    ivac.#RegulatoryDate | null
	dateStatus:       "unreviewed"
	semanticStatus:   "not-normalized"
	applicability:    "unresolved"
})

#CorpusSource: {
	#CorpusSourceRow
	publicationDate:  null
	consolidatedAsOf: null
	effectiveFrom:    null
	status:           "acquired" | "failed"
	memberPath:       string | null
	retrievedAt:      time.Time
	if status == "acquired" {
		finalURL:         #OfficialURL
		mediaType:        string & !=""
		artifactPath:     string & !=""
		artifactDigest:   ivac.#RegulatoryDigest
		artifactBytes:    int & >0
		textPath:         string & !=""
		textDigest:       ivac.#RegulatoryDigest
		conversion:       string & !=""
		converterVersion: string & !=""
		error:            null
	}
	if status == "failed" {
		error:            string & !=""
		finalURL:         null
		mediaType:        null
		artifactPath:     null
		artifactDigest:   null
		artifactBytes:    null
		textPath:         null
		textDigest:       null
		conversion:       null
		converterVersion: null
		containerPath:    null
		containerDigest:  null
		memberPath:       null
	}
	if memberPath != null {
		containerPath:   string & !=""
		containerDigest: ivac.#RegulatoryDigest
	}
	if memberPath == null {containerPath: null, containerDigest: null}
}

#CorpusManifest: {
	format:           "ivac.official-corpus/v1"
	id:               string & !=""
	repositoryCommit: string & =~"^[0-9a-f]{40}$"
	createdAt:        time.Time
	authority:        "acquisition-observations-only"
	sources: [#CorpusSource, ...#CorpusSource]
	anchors: [...ivac.#RegulatoryCitation]
	gaps: [string & !="", ...(string & !="")]
	if id != "" {
		_identities: [for i, s in sources {
			s & {corpusID: id}
			_unique: [for j, other in sources if other.sourceID == s.sourceID {j}] & [i]
		}]
		_anchors: [for a in anchors {
			_source: [for s in sources if s.sourceID == a.sourceVersion {s & {status: "acquired"}}] & [_, ...]
		}]
	}
}

#CorpusTextRow: close({
	corpusID:   string & !=""
	sourceID:   string & !=""
	textDigest: ivac.#RegulatoryDigest
	text:       string
})

#CorpusAnchorRow: close({
	corpusID:      string & !=""
	sourceVersion: string & !=""
	locator:       string & !=""
	start:         int & >=0
	end:           int & >=1
	exactText:     string & !=""
})

corpusProjectionSchemas: {source: #CorpusSourceRow, text: #CorpusTextRow, anchor: #CorpusAnchorRow}
