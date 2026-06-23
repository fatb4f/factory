package impl

#NegativeFixtureSpec: close({
	name: string & !=""
	violates: string & !=""
	refusal: string & !=""
	input: _
})

#NegativeFixtureDescriptor: close({
	kind: "negative-fixture"
	id: string & =~"^negative\\..+"
	violates: string & !=""
	expectedRefusal: string & !=""
	input: _
	expectedBottom: true
})

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec

	out: #NegativeFixtureDescriptor & {
		kind: "negative-fixture"
		id: "negative.\(in.name)"
		violates: in.violates
		expectedRefusal: in.refusal
		input: in.input
		expectedBottom: true
	}
}
