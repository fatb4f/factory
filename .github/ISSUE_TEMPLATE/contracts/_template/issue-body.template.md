```cue
issue : {
	id:     "dotfiles.nvim-qol-control-surface"
	kind:   "implementation-slice"
	repo:   "fatb4f/dotfiles"
	number: 44
	title:  "dotfiles: add Neovim QoL control surface"

	template: {
		name: "Dotfiles manifest slice"
		root: ".github/dotfiles-manifest-slice"
		workflow: ".github/dotfiles-manifest-slice/contracts/dotfiles/workflow"
		manifest: ".github/dotfiles-manifest-slice/contracts/issues/44/manifest.cue"
		checks: ".github/dotfiles-manifest-slice/contracts/issues/44/checks/bottom.cue"
		import: "github.com/fatb4f/dotfiles/.github/dotfiles-manifest-slice/contracts/dotfiles/workflow"
	}

	tracking: {
		parent: _|_
		dependsOn: []
		blocks: []
	}
}
```
