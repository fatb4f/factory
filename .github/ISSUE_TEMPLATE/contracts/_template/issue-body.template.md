```cue
"issue": {
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

	authorityRoot: {
		root: "chezmoi"
		surfaces: [
			"chezmoi/private_dot_config/nvim/**",
			"chezmoi/private_dot_config/wezterm/**",
			".github/dotfiles-manifest-slice/contracts/issues/44/**",
		]
	}

	authoritySplit: {
		neovim: [
			"editor command graph projection",
			"leader-key menu surface",
			"picker UI for editor-local files, grep, buffers, commands, keymaps, diagnostics, and symbols",
			"manual format dispatch surface",
			"CUE command invocation and result presentation",
			"invocation-only bridge to WezTerm/sessionizer commands",
		]
		wezterm: [
			"workspace and project-session authority",
			"sessionizer/project launch authority",
			"mux and workspace switching substrate",
			"xplr/palette routing validation before Neovim RPC dispatch",
		]
		xplr: [
			"tree browsing",
			"focused path selection",
			"bounded open and layout intent emission",
		]
		smartSplits: [
			"pane focus mechanics",
			"pane resize mechanics",
			"mux traversal and resize execution",
		]
		cue: [
			"contract and validation authority for issue-local manifest/checks",
			"source-contract evaluation commands",
		]
		cli: [
			"fd, rg, fzf, cue, git, and formatter binaries as external adapters",
		]
	}

	"targetSurfaces": [
		"chezmoi/private_dot_config/nvim/lua/plugins/which-key.lua",
		"chezmoi/private_dot_config/nvim/lua/plugins/fzf.lua",
		"chezmoi/private_dot_config/nvim/lua/plugins/trouble.lua",
		"chezmoi/private_dot_config/nvim/lua/plugins/conform.lua",
		"chezmoi/private_dot_config/nvim/lua/plugins/gitsigns.lua",
		"chezmoi/private_dot_config/nvim/lua/plugins/mini.lua",
		"chezmoi/private_dot_config/nvim/lua/config/keymaps.lua",
		"chezmoi/private_dot_config/nvim/lua/config/commands.lua",
		"chezmoi/private_dot_config/nvim/lua/config/autocmds.lua",
		"chezmoi/private_dot_config/nvim/lua/adapters/cue.lua",
		"chezmoi/private_dot_config/nvim/lua/adapters/wezterm.lua",
		"chezmoi/private_dot_config/nvim/lua/adapters/git.lua",
		"chezmoi/private_dot_config/nvim/lua/ui/menu.lua",
		"chezmoi/private_dot_config/nvim/lua/ui/statusline.lua",
		".github/dotfiles-manifest-slice/contracts/issues/44/manifest.cue",
		".github/dotfiles-manifest-slice/contracts/issues/44/checks/bottom.cue",
	]

	workflow: [
		{order: 1, id: "#MakeDotfilesPrimitive", instantiateAt: "_primitives"},
		{order: 2, id: "#MakeObservedSurface", instantiateAt: "_observed"},
		{order: 3, id: "#MakeAdmissibleSurface", instantiateAt: "_admissible"},
		{order: 4, id: "#MakePredicateSet", instantiateAt: "_predicates"},
		{order: 5, id: "#MakePromotionCandidate", instantiateAt: "_promotion"},
		{order: 6, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
		{order: 7, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
		{order: 8, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
		{order: 9, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
		{order: 10, id: "#MakeValidationPlan", instantiateAt: "_validation"},
		{order: 11, id: "#MakeCompletionReport", instantiateAt: "_completion"},
	]

	boundaries: {
		pluginManager: {
			authority: false
			role: "dependency loader only; not configuration authority"
		}
		mason: {
			authority: false
			role: "do not reintroduce Mason-managed tool authority in this slice"
		}
		weztermRuntime: {
			authority: true
			role: "workspace/session authority remains outside Neovim"
		}
		neovimPicker: {
			authority: false
			role: "editor-local selection only; must not select, rank, persist, or own project/workspace topology"
		}
		xplrRuntime: {
			authority: false
			role: "tree UI and bounded intent emission only"
		}
		generatedArtifacts: {
			authority: false
			role: "projection/evidence only"
		}
		runtimeState: {
			authority: false
			role: "observed evidence only"
		}
	}

	closure: {
		requires: [
			"which-key exposes the declared leader menu groups",
			"fzf-lua is the only picker adapter introduced by this slice",
			"fzf-lua remains editor-local and does not implement project/session topology selection",
			"diagnostics and quickfix surfaces can be opened through Trouble",
			"formatting is manually invokable before any format-on-save automation is enabled",
			"CUE vet/eval/export commands are visible and route failures to a stable result surface",
			"WezTerm/sessionizer commands are invoked through existing WezTerm authority instead of duplicated in Neovim",
			"xplr remains a bounded intent emitter and does not depend directly on smart-splits",
			"all declared dotfiles surfaces validate from repo-local CUE",
		]
	}

	validation: {
		commands: [
			"cue vet ./.github/dotfiles-manifest-slice/contracts/issues/44",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/44 -e normalizedDotfilesIssueManifest",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/44 -e dotfilesValidationPlan",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/44 -e dotfilesCompletionReportContract",
			"! cue export ./.github/dotfiles-manifest-slice/contracts/issues/44/checks -e '_negativeBottomChecks.<name>'",
			"! rg '[t]arget:\\s*_|[i]nput:\\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority|Neovim project picker|workspace/session topology authority' ./.github/dotfiles-manifest-slice/contracts/issues/44",
		]
	}

	completionReport: {
		sections: [
			"summary",
			"manifest workflow",
			"target surfaces",
			"materialized config changes",
			"leader menu surface",
			"picker and diagnostics surfaces",
			"CUE command surface",
			"WezTerm/sessionizer invocation surface",
			"xplr intent boundary",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}
```
