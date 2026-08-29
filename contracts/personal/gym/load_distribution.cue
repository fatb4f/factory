package gym

#DualLoadProjection: {
	sample: #DualLoadSample

	total:      sample.left.value + sample.right.value
	difference: sample.right.value - sample.left.value
	unit:       sample.left.unit

	if total > 0 {
		leftShare:  sample.left.value / total
		rightShare: sample.right.value / total
		signedAsymmetryRatio: difference / total
	}
}
