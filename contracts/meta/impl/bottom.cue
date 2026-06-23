package impl

#BottomCheckSpec: close({
	name: string & !=""
	input: _
	target: _
})

#MakeBottomCheck: {
	in: #BottomCheckSpec

	out: {
		"\(in.name)": in.input & in.target
	}
}
