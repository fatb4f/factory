package codeintelpluginbundle

#CodeIntelOutputPlan: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
	files: [...#CodeIntelTargetFile] & [_, ...]
	authority: false
})

codeIntelOutputPlan: #CodeIntelOutputPlan & {
	repo: codeIntelTarget.repo
	root: codeIntelTarget.root
	files: generatedFileInventory
	authority: false
}
