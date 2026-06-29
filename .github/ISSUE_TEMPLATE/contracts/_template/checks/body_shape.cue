package issue

#SingleCueIssueBodyMarkdown: string & =~"(?s)^```cue\\nissue: \\{\\n.*\\n\\}\\n```\\n?$"

issueBodyFixtureAccepted: #SingleCueIssueBodyMarkdown & """
```cue
issue: {
	id: "factory.<slice-id>"
}
```
"""

_negativeBottomChecks: {
	extraMarkdownHeadingRejected: #SingleCueIssueBodyMarkdown & """
### CUE issue manifest

```cue
issue: {
	id: "factory.<slice-id>"
}
```
"""

	missingCueFenceRejected: #SingleCueIssueBodyMarkdown & """
issue: {
	id: "factory.<slice-id>"
}
"""

	missingTopLevelIssueRejected: #SingleCueIssueBodyMarkdown & """
```cue
slice: {
	id: "factory.<slice-id>"
}
```
"""
}
