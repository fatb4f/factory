package issue

#SingleCueIssueBodyMarkdown: string & =~"(?s)^```cue\\nissue: \\{\\n.*\\n\\}\\n```\\n?$"

#IssueBodyWithoutGeneratorTerms: #SingleCueIssueBodyMarkdown & !~"(?s)\\n\\t[t]emplate:\\s*\\{|\\n\\t(manifest|checks|import|issueRoot|templatePath|constructorLibrary):"

issueBodyFixtureAccepted: #IssueBodyWithoutGeneratorTerms & """
```cue
issue: {
	id: "factory.<slice-id>"
}
```
"""

_negativeBottomChecks: {
	extraMarkdownHeadingRejected: #IssueBodyWithoutGeneratorTerms & """
### CUE issue manifest

```cue
issue: {
	id: "factory.<slice-id>"
}
```
"""

	missingCueFenceRejected: #IssueBodyWithoutGeneratorTerms & """
issue: {
	id: "factory.<slice-id>"
}
"""

	missingTopLevelIssueRejected: #IssueBodyWithoutGeneratorTerms & """
```cue
slice: {
	id: "factory.<slice-id>"
}
```
"""

	bodyCarriesGeneratorRejected: #IssueBodyWithoutGeneratorTerms & """
```cue
issue: {
	id: "factory.<slice-id>"
	template: {
		root: ".github/ISSUE_TEMPLATE/contracts"
		import: "github.com/fatb4f/factory/contracts/meta/impl"
	}
}
```
"""
}
