package state

import "time"

// A historical receipt identifies an execution. It is not a replay grant.
#TransformInvocation: {
	apiVersion:       "factory.transforms/invocation-v1"
	invocationID:     string & !=""
	transformID:      string & !=""
	transformVersion: string & !=""
	extensionDigest:  #SHA256
	contractVersion:  string & !=""
	contractDigest:   #SHA256
	snapshotRef: close({
		id:     string & !=""
		digest: #SHA256
		sourceRevisionRefs: [string & !="", ...(string & !="")]
		schemaVersion: string & !=""
	})
	knowledgeCutoff: time.Time
	authorizationReceipt: close({
		policyVersion: string & !=""
		scopeDigest:   #SHA256
		decision:      "allowed" | "denied"
	})
	inputRefs: [string & !="", ...(string & !="")]
	executionBackend: string & !=""
	durationNS:       int & >=0
	outcome:          "success" | "empty" | "denied" | "failed"
	if outcome == "success" || outcome == "empty" {
		authorizationReceipt: decision: "allowed"
		outputDigest: #SHA256
		provenanceRefs: [string & !="", ...(string & !="")]
	}
	if outcome == "denied" {
		authorizationReceipt: decision: "denied"
	}
	if outcome == "failed" {
		authorizationReceipt: decision: "allowed"
	}
}
