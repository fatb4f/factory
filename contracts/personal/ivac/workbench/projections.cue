package ivacworkbench

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

// Projection-only transports. Unknown fields stay absent, never false/zero.
#WorkbenchStatementRow: close({
	workbenchID:     ivac.#ID
	caseID:          ivac.#ID
	snapshotID:      ivac.#ID
	recordID:        ivac.#ID
	recordKind:      #RecordKind
	statementID:     ivac.#ID
	topic:           string & !=""
	assertion:       string & !=""
	classState:      "recorded" | "unknown"
	classLabel?:     string & !=""
	percentageState: "recorded" | "unknown"
	percentageKind?: "fixed" | "range" | "not-specified"
	value?:          number & >=0 & <=100
	minimum?:        number & >=0 & <=100
	maximum?:        number & >=0 & <=100
	reason?:         string & !=""
	legalBasisState: "cited" | "unknown"
	sourceVersion?:  ivac.#ID
	unitID?:         ivac.#ID
	status:          "attributed-source-statement"
})
#WorkbenchAnchorRow: close({
	workbenchID:    ivac.#ID
	anchorID:       ivac.#ID
	evidenceID:     ivac.#ID
	artifactDigest: ivac.#RegulatoryDigest
	textDigest:     ivac.#RegulatoryDigest
	page:           int & >=1
	start:          int & >=0
	end:            int & >=1
	exactText:      string & !=""
	transcription:  "machine-unreviewed" | "image-checked"
})
#WorkbenchStatementAnchorRow: close({
	workbenchID: ivac.#ID
	statementID: ivac.#ID
	anchorID:    ivac.#ID
})
workbenchProjectionSchemas: {
	statement:       #WorkbenchStatementRow
	anchor:          #WorkbenchAnchorRow
	statementAnchor: #WorkbenchStatementAnchorRow
}
