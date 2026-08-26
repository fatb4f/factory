package ctrlupstreammonitor

import (
	dispatcher "github.com/fatb4f/factory/contracts/factory/dispatcher"
	core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"
	profile "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor/profiles_ctrl:ctrlprofile"
)

#DispatcherResultProjection: close({
	invocation: dispatcher.#TaskInvocation
	completion: dispatcher.#TaskCompletion
	evidenceDocument: profile.#CtrlRunEvidence & {
		dispatcher!: profile.#CtrlDispatcherContext
	}
	manifestDocument: core.#RunBundleManifest & {
		dispatcher!: profile.#CtrlDispatcherContext
	}
	publicationObservations: [...dispatcher.#PublicationObservation]

	_invocationContext: profile.#CtrlDispatcherContext & {
		task_id:         invocation.taskID
		scheduled_date:  completion.scheduledDate
		occurrence_id:   invocation.occurrenceID
		attempt_ordinal: invocation.attemptOrdinal
		attempt_id:      invocation.attemptID
		due_plan_digest: invocation.duePlanDigest
	}
	_completionBinding: completion & {
		taskID:       invocation.taskID
		occurrenceID: invocation.occurrenceID
		attemptID:    invocation.attemptID
	}
	_evidenceBinding: evidenceDocument & {
		profile_id: "ctrl"
		dispatcher: _invocationContext
	}
	_runRoot: "contracts/upstream-monitor/ctrl/contract-surface/runs/\(evidenceDocument.run_id)"
	_pathBinding: completion & {
		evidence: {path: "\(_runRoot)/evidence.json"}
		manifest: {path: "\(_runRoot)/manifest.json"}
		publications: [
			{path: "\(_runRoot)/report.md"},
			{path: "\(_runRoot)/summary.md"},
			{path: "\(_runRoot)/evidence.json"},
			{path: "\(_runRoot)/manifest.json"},
		]
	}
	_observationBinding: publicationObservations & [
		{path: completion.publications[0].path, digest: completion.publications[0].digest},
		{path: completion.publications[1].path, digest: completion.publications[1].digest},
		{path: completion.publications[2].path, digest: completion.publications[2].digest},
		{path: completion.publications[3].path, digest: completion.publications[3].digest},
	]
	_manifestBinding: manifestDocument & {
		run_id:         evidenceDocument.run_id
		profile_id:     "ctrl"
		terminal_state: evidenceDocument.terminal_state
		dispatcher:     _invocationContext
		artifacts: [
			{kind: "report", filename: "report.md", mediaType: "text/markdown", gitBlobSHA: publicationObservations[0].gitBlobSHA},
			{kind: "summary", filename: "summary.md", mediaType: "text/markdown", gitBlobSHA: publicationObservations[1].gitBlobSHA},
			{kind: "evidence", filename: "evidence.json", mediaType: "application/json", gitBlobSHA: publicationObservations[2].gitBlobSHA},
		]
	}
	_reportableItems: [for item in evidenceDocument.items if item.decision != "none" {item}]

	result: dispatcher.#TaskResult & {
		taskID:             invocation.taskID
		occurrenceID:       invocation.occurrenceID
		attemptID:          invocation.attemptID
		completedAt:        completion.completedAt
		duePlanDigest:      invocation.duePlanDigest
		repositoryRevision: invocation.repositoryRevision
		snapshotDigest:     invocation.snapshotDigest
		registryDigest:     invocation.registryDigest
		publications:       completion.publications
		taskAdmission: {
			contract: "projects/ctrl/upstream-monitor/contract.cue"
			evidence: completion.evidence
			manifest: completion.manifest
		}
		if evidenceDocument.terminal_state == "terminal_abort" {
			state: "failed"
		}
		if evidenceDocument.terminal_state == "terminal_deferred" {
			state: "deferred"
		}
		if evidenceDocument.terminal_state == "coverage_gap" {
			state: "coverage_gap"
		}
		if evidenceDocument.terminal_state == "terminal_success" && len(_reportableItems) == 0 {
			state: "no_change"
		}
		if evidenceDocument.terminal_state == "terminal_success" && len(_reportableItems) > 0 {
			state: "success"
		}
	}
	admission: true
})
