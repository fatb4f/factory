package gym

#SessionRef: close({
	id: #SessionID
})

#ExposureRef: close({
	id: #ExposureID
})

#RecoveryRef: close({
	id: #RecoveryID
})

#IssueRef: close({
	id: #IssueID
})

#ExerciseID: string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"

#ExerciseRef: close({
	id: #ExerciseID
})
