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
	candidates:         [...#Candidate]

	_candidateRegistryBindings: [for i, candidate in candidates {
		candidate & {
			occurrence:   {registryDigest: registryDigest}
			registration: Registry[candidate.occurrence.taskID]
		}
		if i > 0 && candidates[i-1].occurrence.taskID == candidate.occurrence.taskID {
			candidates[i-1].occurrence.scheduledDate < candidate.occurrence.scheduledDate
		}
	}]
})

#DispatchItem: close({
	taskID:         #TaskID
	occurrenceID:   #NonEmptyString
	scheduledDate:  #CivilDate
	attemptOrdinal: int & >0
	adapter:        #RepositoryPath
	occurrence:     #Occurrence
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
	dispatch:           [...#DispatchItem]
	dispositions:       [...#DispositionItem]
	admission:          true
})

#PlanAdmission: {
	input: #PlanInput

	_eligible: {
		for registryKey, registration in Registry {
			"\(registryKey)": [for candidate in input.candidates if candidate.occurrence.taskID == registryKey && candidate.registration.enabled && candidate.occurrence.scheduledDate >= candidate.registration.activationDate && candidate.occurrence.scheduledDate >= candidate.registration.schedule.epoch && candidate.occurrence.scheduledDate <= input.tick.localDate && !candidate.terminal && !candidate.disposed && input.tick.ciObservedAt >= candidate.dispatchAfter && (candidate.occurrence.scheduledDate < input.tick.localDate || (input.tick.localTime >= candidate.registration.schedule.window.notBefore && input.tick.localTime <= candidate.registration.schedule.window.notAfter)) {
				candidate
			}]
		}
	}

	_closed: {
		for registryKey, registration in Registry {
			"\(registryKey)": [for candidate in input.candidates if candidate.occurrence.taskID == registryKey && candidate.registration.enabled && candidate.occurrence.scheduledDate >= candidate.registration.activationDate && candidate.occurrence.scheduledDate <= input.tick.localDate && !candidate.terminal && !candidate.disposed && candidate.registration.misfirePolicy == "expire" && (candidate.occurrence.scheduledDate < input.tick.localDate || input.tick.localTime > candidate.registration.schedule.window.notAfter) {
				candidate
			}]
		}
	}

	plan: #DuePlan & {
		repositoryRevision: input.repositoryRevision
		snapshotDigest:     input.snapshotDigest
		registryDigest:     input.registryDigest
		workflowDigest:     input.workflowDigest
		cueIdentity:        input.cueIdentity
		tick:               input.tick
		dispatch: [for registryKey, registration in Registry for i, candidate in _eligible[registryKey] if registration.misfirePolicy == "catch_up_all" || (registration.misfirePolicy == "coalesce_latest" && i == len(_eligible[registryKey])-1) || (registration.misfirePolicy == "expire" && candidate.occurrence.scheduledDate == input.tick.localDate && input.tick.localTime <= registration.schedule.window.notAfter) {
			taskID:         registryKey
			occurrenceID:   candidate.occurrence.id
			scheduledDate:  candidate.occurrence.scheduledDate
			attemptOrdinal: candidate.attemptCount + 1
			adapter:        registration.adapter
			occurrence:     candidate.occurrence
		}]
		dispositions: [for registryKey, registration in Registry for i, candidate in _eligible[registryKey] if registration.misfirePolicy == "coalesce_latest" && i < len(_eligible[registryKey])-1 {
			taskID:        registryKey
			occurrenceID:  candidate.occurrence.id
			scheduledDate: candidate.occurrence.scheduledDate
			state:         "coalesced"
		}, for registryKey, registration in Registry for candidate in _closed[registryKey] {
			taskID:        registryKey
			occurrenceID:  candidate.occurrence.id
			scheduledDate: candidate.occurrence.scheduledDate
			state:         "expired"
		}]
	}
}
