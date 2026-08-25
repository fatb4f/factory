package dispatcher

import root "github.com/fatb4f/factory"

Registry: close({
	"projects.ctrl.upstream-monitor": #TaskRegistration & {
		id:             "projects.ctrl.upstream-monitor"
		authority:      root.units["projects.ctrl"].tasks["upstream-monitor"].authority
		adapter:        root.units["projects.ctrl"].tasks["upstream-monitor"].adapter
		enabled:        true
		activationDate: "2026-08-24"
		timezone:       "America/Toronto"
		schedule: {
			epoch: "2026-08-24"
			cadence: {
				unit:  "days"
				every: 3
			}
			window: {
				notBefore: "00:00"
				notAfter:  "23:59"
			}
		}
		misfirePolicy: "coalesce_latest"
		staleAfter:    "6h"
	}
	"projects.epistemic-plant-bootstrap.upstream-monitor": #TaskRegistration & {
		id:             "projects.epistemic-plant-bootstrap.upstream-monitor"
		authority:      root.units["projects.epistemic-plant-bootstrap"].tasks["upstream-monitor"].authority
		adapter:        root.units["projects.epistemic-plant-bootstrap"].tasks["upstream-monitor"].adapter
		enabled:        true
		activationDate: "2026-08-24"
		timezone:       "America/Toronto"
		schedule: {
			epoch: "2026-08-24"
			cadence: {
				unit:  "days"
				every: 3
			}
			window: {
				notBefore: "00:00"
				notAfter:  "23:59"
			}
		}
		misfirePolicy: "coalesce_latest"
		staleAfter:    "6h"
	}
})
