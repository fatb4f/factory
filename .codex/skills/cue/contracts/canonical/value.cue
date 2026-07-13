package canonical

import "strings"

#SafeInteger:          int & >=-9007199254740991 & <=9007199254740991
#CanonicalCoefficient: "0" | (string & =~"^-?[1-9][0-9]*$")

#CanonicalNull: close({kind: "null"})
#CanonicalBool: close({kind: "bool", value: bool})
#CanonicalString: close({kind: "string", value: string})
#CanonicalNumber: close({
	kind:        "number"
	coefficient: #CanonicalCoefficient
	exponent:    #SafeInteger
	if coefficient != "0" {
		coefficient: !~"0$"
	}
})
#CanonicalList: close({kind: "list", list: [...#CanonicalSubjectValue]})
#CanonicalObject: close({kind: "object", object: {[string]: #CanonicalSubjectValue}})

#CanonicalSubjectValue: #CanonicalNull | #CanonicalBool | #CanonicalString | #CanonicalNumber | #CanonicalList | #CanonicalObject

#SHA256:   string & =~"^[a-f0-9]{64}$"
#NonEmpty: string & strings.MinRunes(1)

// Concrete round-trip witnesses for the bounded exact-number representation.
numberFixtures: {
	zero: #CanonicalSubjectValue & {kind: "number", coefficient: "0", exponent: 0}
	integer: #CanonicalSubjectValue & {kind: "number", coefficient: "123", exponent: 0}
	decimal: #CanonicalSubjectValue & {kind: "number", coefficient: "123", exponent: -2}
	negative: #CanonicalSubjectValue & {kind: "number", coefficient: "-5", exponent: 10}
}
