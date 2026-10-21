package ivac

// Disposable transport rows, never competing regulatory/qualification authority.
// Decimal adaptation belongs to codegen; CUE remains exact-number authority.
#RegulatoryRowKey: {
	sourceVersion: #ID
	compendiumID:  #ID
}
#RegulatoryUnitRow: close({
	sourceVersion: #ID
	compendiumID:  #ID
	unitID:        #ID
	number:        string & !=""
	kind:          "functional" | "aesthetic"
	label:         string & !=""
	reviewState:   "candidate" | "reviewed"
})
#RegulatoryClassRow: close({
	sourceVersion:  #ID
	compendiumID:   #ID
	unitID:         #ID
	classID:        #ID
	label:          string & !=""
	percentageKind: "fixed" | "range" | "not-specified"
	value?:         number & >=0 & <=100
	minimum?:       number & >=0 & <=100
	maximum?:       number & >=0 & <=100
	reason?:        string & !=""
})
#RegulatoryAlternativeRow: close({
	sourceVersion: #ID
	compendiumID:  #ID
	unitID:        #ID
	classID:       #ID
	alternativeID: #ID
	operator:      "all-of"
	position:      int & >=0
})
#RegulatoryCriterionRow: close({
	sourceVersion: #ID
	compendiumID:  #ID
	unitID:        #ID
	classID:       #ID
	alternativeID: #ID
	criterionID:   #ID
	position:      int & >=0
})
#RegulatoryCitationRow: close({
	sourceVersion: #ID
	compendiumID:  #ID
	ownerPath:     string & !=""
	locator:       string & !=""
	start:         int & >=0
	end:           int & >=1
	exactText:     string & !=""
})
#RegulatoryRuleRow: close({
	sourceVersion: #ID
	compendiumID:  #ID
	unitID:        #ID
	position:      int & >=0
	ownerPath:     string & !=""
})

regulatoryRowSchemas: {
	unit:        #RegulatoryUnitRow
	class:       #RegulatoryClassRow
	alternative: #RegulatoryAlternativeRow
	criterion:   #RegulatoryCriterionRow
	citation:    #RegulatoryCitationRow
	rule:        #RegulatoryRuleRow
}
