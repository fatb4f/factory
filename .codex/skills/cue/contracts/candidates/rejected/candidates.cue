package rejected

// Raw rejected mutations deliberately remain unconstrained here. Ingress fixtures
// apply each value to its explicit target schema and require rejection.
candidates: {
	openIngress: {
		id: "open-ingress", class: "open-ingress", unexpected: true
	}
	danglingReference: {
		id: "dangling-reference", operation: {reads: {missing: true}}
	}
	wrongGeneratedRole: {
		id: "wrong-generated-role", resource: {id: "output", role: "authority"}
	}
	widenedState: {
		id: "widened-state", additionalResource: "extra"
	}
	widenedOperationReference: {
		id: "widened-operation-reference", additionalRead: "extra"
	}
	incompletePublication: {
		id: "incomplete-publication", missingRole: "suite"
	}
	invalidNegativeFixture: {
		id: "invalid-negative-fixture", independentlyValid: false
	}
}
