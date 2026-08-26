package dispatcher

import root "github.com/fatb4f/factory"

import ctrl "github.com/fatb4f/factory/projects/ctrl"

import epistemicplant "github.com/fatb4f/factory/projects/epistemic-plant-bootstrap:epistemicplantbootstrap"

Registry: close({
	"projects.ctrl.upstream-monitor": #TaskRegistration & {
		id:        "projects.ctrl.upstream-monitor"
		authority: root.units["projects.ctrl"].tasks["upstream-monitor"].authority
		adapter:   ctrl.UpstreamMonitorMapping.adapter
		enabled:   false
		timezone:  "America/Toronto"
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
		id:        "projects.epistemic-plant-bootstrap.upstream-monitor"
		authority: root.units["projects.epistemic-plant-bootstrap"].tasks["upstream-monitor"].authority
		adapter:   epistemicplant.UpstreamMonitorMapping.adapter
		enabled:   false
		timezone:  "America/Toronto"
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
