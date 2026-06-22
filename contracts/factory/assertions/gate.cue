package assertions

import factory "github.com/fatb4f/factory/contracts/factory"

#AllowedRootSurfaces: [
	".github",
	".codex",
	"contracts",
	"generated",
	"migration",
	"cmd",
	"internal",
	"go.mod",
	"justfile",
	"README.md",
]

#ForbiddenIndependentRoots: [
	"checks",
	"fixtures",
	"providers",
	"projections",
	"adapters",
	"test",
]

factoryPruningGate: {
	surface: factory.surface
	invariant: "top-level checks are forbidden; generated executable checks must be assertion-backed projections"
	allowedRootSurfaces: #AllowedRootSurfaces
	forbiddenIndependentRoots: #ForbiddenIndependentRoots
}
