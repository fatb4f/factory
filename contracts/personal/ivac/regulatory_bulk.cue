package ivac

import "time"

#RegulatoryBulkProvisionObservation: close({
	code: #ID
	publisherAttributes: [string]: string
	start:         int & >=0
	end:           int & >=0
	textDigest:    #RegulatoryDigest
	xmlByteStart:  int & >=0
	xmlByteEnd:    int & >=0
	xmlSpanDigest: #RegulatoryDigest
})
#RegulatoryBulkMemberObservation: close({
	memberPath:           string & !=""
	normalizedMemberPath: string & !=""
	artifactDigest:       #RegulatoryDigest
	artifactBytes:        int & >0
	mediaType:            "application/xml"
	instrument:           "P-9.2.1" | "P-9.2.1, r. 1"
	rootAttributes: [string]: string
	snapshotDigest: #RegulatoryDigest
	provisions: [#RegulatoryBulkProvisionObservation, ...#RegulatoryBulkProvisionObservation]
	publicationDate:        "unknown"
	consolidationDate:      "unknown"
	legalEffectiveInterval: "requires-legal-review"
	legalEffect:            "not-determined"
})
#RegulatoryBulkObservations: close({
	format:          "ivac.bulk-observations/v1"
	authority:       "none"
	retrievedAt:     time.Time
	catalogueURL:    "https://www.donneesquebec.ca/recherche/api/3/action/package_show?id=c8433300-f752-4815-8ea2-69cad416dd80"
	catalogueDigest: #RegulatoryDigest
	datasetID:       "c8433300-f752-4815-8ea2-69cad416dd80"
	licenseID:       string & !=""
	licenseURL:      string & =~"^https://"
	redistribution:  "pending-license-review"
	resources: [...close({
		resourceID:     #ID
		url:            string & =~"^https://www\\.donneesquebec\\.ca/"
		retrievedAt:    time.Time
		path:           string & !=""
		artifactDigest: #RegulatoryDigest
		artifactBytes:  int & >0
		member?:        #RegulatoryBulkMemberObservation
	})]
	gaps: [...close({resource: string & !="", error: string & !=""})]
	caseApplicability: "unresolved"
})
