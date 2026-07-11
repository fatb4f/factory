package kb

#Check: {
	id:          string
	description: string
	command?:    string
	depends_on?: {[string]: true}
}

checks: references_admitted: #Check & {
	id: "references_admitted", description: "Every packet reference resolves to an admitted declaration"
}
