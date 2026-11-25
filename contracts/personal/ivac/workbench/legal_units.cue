package ivacworkbench

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

#LegalUnitSnapshot: close({
	snapshot: #CaseSnapshot
	let sid = snapshot.id
	sourceVersion: ivac.#ID
	observations: [key=string]: ivac.#ClinicalObservation & {id: key}
	relationships: [key=string]: close({
		id:            key & ivac.#ID
		kind:          "linked-observation"
		snapshotID:    sid
		unitNumber:    ivac.#ID
		observationID: ivac.#ObservationID
	})
	_refs: [for _, r in relationships {observations[r.observationID]}]
})

#RuleCondition: close({
	concept: string & !=""
	expectedValue: ivac.#ClinicalValue
})

// Receipts are references to external review, never proof of credentials.
#RuleReviewReceipt: close({
	id: ivac.#ID
	digest: ivac.#RegulatoryDigest
})

#CrossUnitRule: close({
	id:            ivac.#ID
	version:       string & =~"^[0-9]+[.][0-9]+[.][0-9]+$"
	sourceVersion: ivac.#ID
	from:          ivac.#ID
	target:        ivac.#ID & !=from
	concept:       string & !=""
	// A concept alone does not imply the observation is present or positive.
	expectedValue: ivac.#ClinicalValue
	// Every listed condition must match authorized observations.
	conditions?: [...#RuleCondition]
	unresolvedConditions: [...(string & !="")]
	status: "test-only" | "candidate" | "reviewed"
	basis: close({
		kind: "synthetic" | "published" | "DSM"
		citation: string & !=""
		url?: string & =~"^https://"
		digest?: ivac.#RegulatoryDigest
	})
	reviews?: close({
		clinical: #RuleReviewReceipt
		legal: #RuleReviewReceipt & {id: !=clinical.id}
	})
	if status == "test-only" {basis: kind: "synthetic"}
	if status == "candidate" {basis: kind: "published" | "DSM"}
	if status == "reviewed" {
		basis: {kind: "published" | "DSM", url: string, digest: ivac.#RegulatoryDigest}
		reviews: {clinical: #RuleReviewReceipt, legal: #RuleReviewReceipt}
	}
})
