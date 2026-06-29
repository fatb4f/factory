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

	goal: {
		implement: [
			"which-key backed leader-menu registry for Neovim command discovery",
			"fzf-lua as the single picker adapter for editor-local files, grep, buffers, commands, keymaps, diagnostics, and symbols",
			"Trouble-backed diagnostics, quickfix, references, and symbol list surface",
			"Conform-backed explicit format command with opt-in per-filetype format-on-save",
			"GitSigns and mini.nvim primitives for high-signal editing QoL",
			"CUE command surface routed through visible diagnostics or quickfix results",
			"WezTerm/sessionizer invocation surface without Neovim project or session selection authority",
			"issue-local manifest and negative check surface",
		]

		notImplement: [
			"LazyVim-style framework takeover",
			"Mason-managed language-tool authority",
			"Neovim project picker",
			"Neovim workspace/session topology authority",
			"Neovim cwd/session persistence as project authority",
			"hidden format-on-save behavior before manual format command exists",
			"plugin pile expansion outside the declared QoL primitives",
			"generated artifacts as authority",
		]
	}

	intent: "Add a compact Neovim QoL control surface that makes keys, editor-local navigation, diagnostics, formatting, CUE operations, and WezTerm/sessionizer command invocation discoverable without replacing the current WezTerm/xplr/smart-splits architecture."
}
```
