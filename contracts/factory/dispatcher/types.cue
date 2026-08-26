package dispatcher

import (
	"list"
	"time"
)

#NonEmptyString:   string & !=""
#Digest:           string & =~"^[0-9a-f]{64}$"
#CommitSHA:        string & =~"^[0-9a-f]{40}$"
#GitObjectSHA:     string & =~"^[0-9a-f]{40}$"
#Timestamp:        string & time.Time
#CivilDate:        string & =~"^[0-9]{4}-(0[1-9]|1[0-2])-([0-2][0-9]|3[01])$"
#ClockTime:        string & =~"^([01][0-9]|2[0-3]):[0-5][0-9]$"
#Timezone:         "America/Toronto"
#TaskID:           string & =~"^(projects|academic|world)\\.[a-z0-9]+(?:-[a-z0-9]+)*\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#RepositoryPath:   string & =~"^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$" & !~"(^|/)\\.{1,2}(/|$)"
#Weekday:          "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday" | "Saturday" | "Sunday"
#MisfirePolicy:    "catch_up_all" | "coalesce_latest" | "expire"
#ResultState:      "success" | "no_change" | "deferred" | "coverage_gap" | "failed"
#DispositionState: "coalesced" | "expired"

#Schedule: close({
	epoch: #CivilDate
	cadence: close({
		unit:  "days" | "weeks"
		every: int & >0
	})
	weekday?: #Weekday
	window: close({
		notBefore: #ClockTime
		notAfter:  #ClockTime
	})
})

#TaskRegistrationFields: {
	id:        #TaskID
	authority: #RepositoryPath & =~"contract\\.cue$"
	adapter: close({
		contract:  #RepositoryPath & =~"contract\\.cue$"
		procedure: #RepositoryPath
	})
	timezone:      #Timezone
	schedule:      #Schedule
	misfirePolicy: #MisfirePolicy
	staleAfter:    "6h"
}

#TaskRegistration: close({
	#TaskRegistrationFields
	enabled:        true
	activationDate: #CivilDate
}) | close({
	#TaskRegistrationFields
	enabled: false
})

#ResolvedTick: close({
	observedAt:   #Timestamp
	ciObservedAt: #Timestamp
	localDate:    #CivilDate
	localTime:    #ClockTime
	timezone:     #Timezone
})

#Occurrence: close({
	taskID:         #TaskID
	id:             "\(taskID)/\(scheduledDate)"
	epochIndex:     int & >=0
	registryDigest: #Digest
	scheduledDate:  #CivilDate
	timezone:       #Timezone
	windowStart:    #Timestamp
	windowEnd:      #Timestamp
})

#TaskInvocation: close({
	taskID:             #TaskID
	occurrenceID:       #NonEmptyString
	attemptID:          "\(occurrenceID)/attempt-\(attemptOrdinal)"
	attemptOrdinal:     int & >0
	scheduledAt:        #Timestamp
	invokedAt:          #Timestamp
	duePlanDigest:      #Digest
	repositoryRevision: #CommitSHA
	snapshotDigest:     #Digest
	registryDigest:     #Digest
})

#PublicationReference: close({
	path:   #RepositoryPath
	digest: #Digest
})

#PublicationObservation: close({
	path:       #RepositoryPath
	digest:     #Digest
	gitBlobSHA: #GitObjectSHA
})

#TaskCompletion: close({
	apiVersion:    "factory.dispatcher.task-completion/v1"
	taskID:        #TaskID
	occurrenceID:  #NonEmptyString
	attemptID:     #NonEmptyString
	scheduledDate: #CivilDate
	completedAt:   #Timestamp
	evidence:      #PublicationReference
	manifest:      #PublicationReference
	publications: [...#PublicationReference] & [_, ...]
})

#TaskResult: close({
	taskID:             #TaskID
	occurrenceID:       #NonEmptyString
	attemptID:          #NonEmptyString
	state:              #ResultState
	completedAt:        #Timestamp
	duePlanDigest:      #Digest
	repositoryRevision: #CommitSHA
	snapshotDigest:     #Digest
	registryDigest:     #Digest
	publications: [...#PublicationReference]
	taskAdmission: close({
		contract: #RepositoryPath & =~"contract\\.cue$"
		evidence: #PublicationReference
		manifest: #PublicationReference
	})
})

#Attempt: close({
	id:         #NonEmptyString
	ordinal:    int & >0
	claimedAt:  #Timestamp
	staleAt:    #Timestamp
	invocation: #TaskInvocation
	result?:    #TaskResult
	invocation: {
		attemptID:      id
		attemptOrdinal: ordinal
	}
	if result != _|_ {
		result: {
			attemptID:          id
			taskID:             invocation.taskID
			occurrenceID:       invocation.occurrenceID
			duePlanDigest:      invocation.duePlanDigest
			repositoryRevision: invocation.repositoryRevision
			snapshotDigest:     invocation.snapshotDigest
			registryDigest:     invocation.registryDigest
		}
	}
})

#Disposition: close({
	state:        #DispositionState
	classifiedAt: #Timestamp
	planDigest:   #Digest
})

#DispositionRecord: close({
	apiVersion:    "factory.dispatcher.disposition/v1"
	taskID:        #TaskID
	occurrenceID:  #NonEmptyString
	scheduledDate: #CivilDate
	disposition:   #Disposition
})

#DispositionAdmission: close({
	occurrence: #Occurrence
	record:     #DispositionRecord
	record: {
		taskID:        occurrence.taskID
		occurrenceID:  occurrence.id
		scheduledDate: occurrence.scheduledDate
	}
	admission: true
})

#OccurrenceRecord: close({
	occurrence: #Occurrence
	attempts: [...#Attempt]
	disposition?: #Disposition
	_attemptOrdinals: [for i, attempt in attempts {
		attempt & {
			ordinal: i + 1
			id:      "\(occurrence.id)/attempt-\(i+1)"
		}
	}]
	_terminalResults: [for attempt in attempts if attempt.result != _|_ {attempt.result}]
	_terminalResultLimit: list.MaxItems(_terminalResults, 1) & true
	if disposition != _|_ && len(attempts) > 0 {
		_invalidDispositionWithAttempts: _|_
	}
})

#ExecutionLedger: close({
	apiVersion: "factory.dispatcher.ledger/v1"
	occurrences: [string]: #OccurrenceRecord
	_occurrenceIDs: [for id, record in occurrences {
		record & {occurrence: {id: id}}
	}]
})

#ClaimRecord: close({
	apiVersion: "factory.dispatcher.claim/v1"
	occurrence: #Occurrence
	attempt:    #Attempt
	_invocationBinding: attempt.invocation & {
		occurrenceID:   occurrence.id
		taskID:         occurrence.taskID
		registryDigest: occurrence.registryDigest
	}
})

#ClaimLocationAdmission: close({
	taskID:        #TaskID
	occurrenceID:  #NonEmptyString
	scheduledDate: #CivilDate
	record:        #ClaimRecord
	record: {
		occurrence: {
			taskID:        taskID
			id:            occurrenceID
			scheduledDate: scheduledDate
		}
	}
	admission: true
})

#ResultAdmission: close({
	registration: #TaskRegistration
	occurrence:   #Occurrence
	invocation:   #TaskInvocation
	result:       #TaskResult

	_registrationBinding: registration & {id: occurrence.taskID}
	_invocationBinding: invocation & {
		taskID:         occurrence.taskID
		occurrenceID:   occurrence.id
		registryDigest: occurrence.registryDigest
	}
	_resultBinding: result & {
		taskID:             invocation.taskID
		occurrenceID:       invocation.occurrenceID
		attemptID:          invocation.attemptID
		duePlanDigest:      invocation.duePlanDigest
		repositoryRevision: invocation.repositoryRevision
		snapshotDigest:     invocation.snapshotDigest
		registryDigest:     invocation.registryDigest
		taskAdmission: {
			contract: registration.adapter.contract
		}
	}
	admission: true
})

#ResultTransitionAdmission: close({
	registration: #TaskRegistration
	occurrence:   #Occurrence
	invocation:   #TaskInvocation
	result:       #TaskResult
	current:      #Candidate

	_resultAdmission: #ResultAdmission & {
		registration: registration
		occurrence:   occurrence
		invocation:   invocation
		result:       result
	}
	_currentBinding: current & {
		registration: registration
		occurrence:   occurrence
		attemptCount: invocation.attemptOrdinal
		terminal:     false
		disposed:     false
	}
	admission: true
})
