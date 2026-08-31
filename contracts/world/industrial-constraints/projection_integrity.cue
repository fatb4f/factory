package industrialconstraints

// ProjectionGraphIntegrity proves that every relation/state input is produced by
// a declared projection in the same graph. Source-channel inputs are explicit
// acquisition boundaries and therefore do not require an internal producer.
#ProjectionGraphIntegrity: close({
	projections: {[string]: #Projection}

	_producedRelationStates: {
		for _, projection in projections {
			for output in projection.outputs {
				"\(output.relation):\(output.state)": true
			}
		}
	}

	_inputClosure: [for _, projection in projections {
		_relationInputs: [for input in projection.inputs if input.kind == "relation" {
			_key:      "\(input.relation):\(input.state)"
			_producer: _producedRelationStates[_key] & true
		}]
	}]
})

projectionGraphIntegrity: #ProjectionGraphIntegrity & {
	projections: projections
}
