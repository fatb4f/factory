package bdd

#BootstrapWorkbookIdentityDecision: close({
	id:               "kg://repository/factory/bootstrap/workbook/implementation-unit-validator"
	selectedPath:     "marimo/workflows/bdd/validate_implementation_unit.py"
	role:             "bddImplementationUnitValidator"
	legacyEntrypoint: "marimo/profiles/context-resolver/context_resolver.py"

	preservesLegacyInlineRuntime: true
	projectManaged:               true
	pep723Allowed:                false

	rationale: [
		"The BDD validator is distinct from the runtime context resolver.",
		"The legacy inline-managed UserPromptSubmit path must survive until RM-08.",
		"A project-managed workbook cannot contain PEP 723 metadata without bypassing the Factory uv project.",
	]

	source: close({
		path:   "AGENTS.md"
		digest: "sha256:460985ca987fde2c3fee1ff716235d312e9fc68f8b20379a24298f5f6a9e9515"
	})
})

bootstrapWorkbookIdentity: #BootstrapWorkbookIdentityDecision

_workbookPathDistinct:     bootstrapWorkbookIdentity.selectedPath != bootstrapWorkbookIdentity.legacyEntrypoint
_legacyRuntimePreserved:   bootstrapWorkbookIdentity.preservesLegacyInlineRuntime
_projectBoundaryPreserved: bootstrapWorkbookIdentity.projectManaged && !bootstrapWorkbookIdentity.pep723Allowed

workbookIdentityAdmission: close({
	implementationUnitID: "kg://repository/factory/implementation-unit/uv-bd-bootstrap/v1"
	decision:             bootstrapWorkbookIdentity
	admitted:             _workbookPathDistinct && _legacyRuntimePreserved && _projectBoundaryPreserved
})
