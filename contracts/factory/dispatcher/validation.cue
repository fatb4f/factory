package dispatcher

import "time"

// Validation is a concrete production export. CI requires this package to vet
// before it will resolve candidates or emit a due-plan admission.
Validation: close({
	registry: [for taskID, registration in Registry {
		idMatchesKey:     registration.id == taskID
		epochIsDate:      time.Format(registration.schedule.epoch, time.RFC3339Date) & true
		activationIsDate: time.Format(registration.activationDate, time.RFC3339Date) & true
		windowOrdered:    registration.schedule.window.notBefore <= registration.schedule.window.notAfter
		if registration.schedule.cadence.unit == "weeks" {
			weeklyWeekdayPresent: registration.schedule.weekday != _|_
		}
	}]
	literalAdmissionRequired: true
})
