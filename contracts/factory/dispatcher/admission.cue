package dispatcher

#Candidate: close({
	registration:  #TaskRegistration
	occurrence:    #Occurrence
	attemptCount:  int & >=0
	terminal:      bool
	disposed:      bool
	dispatchAfter: #Timestamp

	registration: {
		id:       occurrence.taskID
		timezone: occurrence.timezone
	}
})

#PlanInput: close({
	apiVersion:         "factory.dispatcher.preflight/v1"
	repositoryRevision: #CommitSHA
	snapshotDigest:     #Digest
	registryDigest:     #Digest
	workflowDigest:     #Digest
	cueIdentity:        #NonEmptyString
	tick:               #ResolvedTick
	registry: [#TaskID]: #TaskRegistration
	candidates: [...#Candidate]

	_candidateRegistryBindings: [for i, value in candidates {
		resolved: value & {
			occurrence: {registryDigest: registryDigest}
			registration: registry[value.occurrence.taskID]
		}
		if i > 0 {
			if candidates[i-1].occurrence.taskID == value.occurrence.taskID {
				ordered: candidates[i-1].occurrence.scheduledDate < value.occurrence.scheduledDate
			}
		}
	}]
})

#DispatchItem: close({
	taskID:         #TaskID
	occurrenceID:   #NonEmptyString
	scheduledDate:  #CivilDate
	attemptOrdinal: int & >0
	adapter: close({
		contract:  #RepositoryPath & =~"contract\\.cue$"
		procedure: #RepositoryPath
	})
	occurrence: #Occurrence
	occurrence: {
		taskID:        taskID
		id:            occurrenceID
		scheduledDate: scheduledDate
	}
})

#DispositionItem: close({
	taskID:        #TaskID
	occurrenceID:  #NonEmptyString
	scheduledDate: #CivilDate
	state:         #DispositionState
})

#DuePlan: close({
	apiVersion:         "factory.dispatcher.due-plan/v1"
	repositoryRevision: #CommitSHA
	snapshotDigest:     #Digest
	registryDigest:     #Digest
	workflowDigest:     #Digest
	cueIdentity:        #NonEmptyString
	tick:               #ResolvedTick
	dispatch: [...#DispatchItem]
	dispositions: [...#DispositionItem]
	admission: true
})

#PlanAdmission: {
	input: #PlanInput

	_eligible: {
		for registryKey, registration in input.registry {
			if registration.enabled {
				"\(registryKey)": [for candidate in input.candidates if candidate.occurrence.taskID == registryKey && candidate.occurrence.scheduledDate >= candidate.registration.activationDate && candidate.occurrence.scheduledDate >= candidate.registration.schedule.epoch && candidate.occurrence.scheduledDate <= input.tick.localDate && !candidate.terminal && !candidate.disposed && input.tick.ciObservedAt >= candidate.dispatchAfter && (candidate.occurrence.scheduledDate < input.tick.localDate || (input.tick.localTime >= candidate.registration.schedule.window.notBefore && input.tick.localTime <= candidate.registration.schedule.window.notAfter)) {
					candidate
				}]
			}
			if !registration.enabled {
				"\(registryKey)": []
			}
		}
	}

	_closed: {
		for registryKey, registration in input.registry {
			if registration.enabled {
				"\(registryKey)": [for candidate in input.candidates if candidate.occurrence.taskID == registryKey && candidate.occurrence.scheduledDate >= candidate.registration.activationDate && candidate.occurrence.scheduledDate <= input.tick.localDate && !candidate.terminal && !candidate.disposed && candidate.registration.misfirePolicy == "expire" && (candidate.occurrence.scheduledDate < input.tick.localDate || input.tick.localTime > candidate.registration.schedule.window.notAfter) {
					candidate
				}]
			}
			if !registration.enabled {
				"\(registryKey)": []
			}
		}
	}

	plan: #DuePlan & {
		repositoryRevision: input.repositoryRevision
		snapshotDigest:     input.snapshotDigest
		registryDigest:     input.registryDigest
		workflowDigest:     input.workflowDigest
		cueIdentity:        input.cueIdentity
		tick:               input.tick
		dispatch: [for registryKey, registration in input.registry for i, candidate in _eligible[registryKey] if registration.misfirePolicy == "catch_up_all" || (registration.misfirePolicy == "coalesce_latest" && i == len(_eligible[registryKey])-1) || (registration.misfirePolicy == "expire" && candidate.occurrence.scheduledDate == input.tick.localDate && input.tick.localTime <= registration.schedule.window.notAfter) {
			taskID:         registryKey
			occurrenceID:   candidate.occurrence.id
			scheduledDate:  candidate.occurrence.scheduledDate
			attemptOrdinal: candidate.attemptCount + 1
			adapter:        registration.adapter
			occurrence:     candidate.occurrence
		}]
		dispositions: [for registryKey, registration in input.registry for i, candidate in _eligible[registryKey] if registration.misfirePolicy == "coalesce_latest" && i < len(_eligible[registryKey])-1 {
			taskID:        registryKey
			occurrenceID:  candidate.occurrence.id
			scheduledDate: candidate.occurrence.scheduledDate
			state:         "coalesced"
		}, for registryKey, registration in input.registry for candidate in _closed[registryKey] {
			taskID:        registryKey
			occurrenceID:  candidate.occurrence.id
			scheduledDate: candidate.occurrence.scheduledDate
			state:         "expired"
		}]
	}
}

#ClaimAdmission: close({
	archivedPlan: #DuePlan
	planDigest:   #Digest
	currentInput: #PlanInput
	item:         #DispatchItem
	claim:        #ClaimRecord

	_currentPlan: (#PlanAdmission & {input: currentInput}).plan
	_archivedMatches: [for candidate in archivedPlan.dispatch if candidate == item {candidate}]
	_currentMatches: [for candidate in _currentPlan.dispatch if candidate == item {candidate}]
	_tickOrder: currentInput.tick.ciObservedAt >= archivedPlan.tick.ciObservedAt
	_claimBinding: claim & {
		occurrence: item.occurrence
		attempt: {
			id:      "\(item.occurrenceID)/attempt-\(item.attemptOrdinal)"
			ordinal: item.attemptOrdinal
			invocation: {
				taskID:         item.taskID
				occurrenceID:   item.occurrenceID
				attemptOrdinal: item.attemptOrdinal
				duePlanDigest:  planDigest
				scheduledAt:    item.occurrence.windowStart
			}
		}
	}
	admission: len(_archivedMatches) == 1 && len(_currentMatches) == 1 && _tickOrder
})

#DispositionTransitionAdmission: close({
	archivedPlan: #DuePlan
	planDigest:   #Digest
	currentInput: #PlanInput
	item:         #DispositionItem
	occurrence:   #Occurrence
	record:       #DispositionRecord

	_currentPlan: (#PlanAdmission & {input: currentInput}).plan
	_archivedMatches: [for candidate in archivedPlan.dispositions if candidate == item {candidate}]
	_currentMatches: [for candidate in _currentPlan.dispositions if candidate == item {candidate}]
	_tickOrder: currentInput.tick.ciObservedAt >= archivedPlan.tick.ciObservedAt
	_occurrenceBinding: occurrence & {
		taskID:        item.taskID
		id:            item.occurrenceID
		scheduledDate: item.scheduledDate
	}
	_recordAdmission: #DispositionAdmission & {
		occurrence: occurrence
		record: record & {
			disposition: {
				state:      item.state
				planDigest: planDigest
			}
		}
	}
	admission: len(_archivedMatches) == 1 && len(_currentMatches) == 1 && _tickOrder
})
