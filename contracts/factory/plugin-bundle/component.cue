package pluginbundle

#ComponentRole: "authority" | "input" | "projection" | "evidence" | "runtime" | "test"

#Component: close({
	id:   #NonEmptyString
	kind: "contract" | "adapter" | "hook" | "fixture" | "projection" | "evidence" | "test"
	path: #NonEmptyString
	role: #ComponentRole

	generated: *false | bool
	dependsOn: *[] | [...#NonEmptyString]
})
