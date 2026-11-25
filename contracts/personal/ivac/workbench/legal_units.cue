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

#CrossUnitRule: close({
	id:            ivac.#ID
	version:       string & =~"^[0-9]+[.][0-9]+[.][0-9]+$"
	sourceVersion: ivac.#ID
	from:          ivac.#ID
	target:        ivac.#ID & !=from
	concept:       string & !=""
	unresolvedConditions: [...(string & !="")]
	status: "test-only" | "candidate"
	basis: close({kind: "synthetic" | "published" | "DSM", citation: string & !=""})
	if status == "test-only" {basis: kind: "synthetic"}
	if status == "candidate" {basis: kind: "published" | "DSM"}
})
