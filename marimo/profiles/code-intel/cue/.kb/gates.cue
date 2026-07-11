package kb

#Gate: {id: string, description: string, requires: {[string]: true}}

gates: execution_admitted: #Gate & {
	id: "execution_admitted", description: "Execution is admitted only after reference validation"
	requires: {references_admitted: true}
}
