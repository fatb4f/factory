package observatorymodel

#Entity: close({
	id: string
})

#Organization: #Entity & close({
	name: string
})

#Project: close({
	owner: #Organization
})
