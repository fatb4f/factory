package issue

manifestPathConvention: {
	root: "contracts/issues"
	pattern: "contracts/issues/<issue-number>/manifest.cue"
	example: issueManifest.issue.target.manifestPath
}

normalizedIssueManifest: issueManifest & {
	normalizedPath: "contracts/issues/example/normalized.cue"
	validationPath: "contracts/issues/example/validation.cue"
}

issueCompletionReportContract: _completion.out
