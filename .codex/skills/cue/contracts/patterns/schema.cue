package patterns

import "strings"

#NonEmptyString: string & strings.MinRunes(1)
#PatternID:      #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#AssertionMode:  "unifies" | "bottoms" | "exports" | "subsumes" | "preserves" | "requires" | "forbids"

// Pattern definitions describe a CUE operation. Fixtures remain separate so
// invalid input is never confused with an executable expected-bottom proof.
#PatternDefinition: close({
	id:            #PatternID
	description:   #NonEmptyString
	assertionMode: #AssertionMode
	schema:        _
})

#PositiveFixture: close({
	patternID: #PatternID
	value:     _
})

#NegativeFixture: close({
	patternID: #PatternID
	value:     _
})

// Directional relations are runner inputs. They are not encoded as
// unification, which only computes a greatest lower bound.
#DirectionalFixture: close({
	patternID: #PatternID
	mode:      "subsumes" | "preserves"
	general:   _
	specific:  _
})
