package uav

// These labels distinguish the two aircraft described on 2026-11-17.
// Replace a null model or weight only when its identity or configuration is known.
#ReportedModel: {
	model:            null | (string & !="")
	operatingWeightG: null | (number & >0)
	reported: {
		source:                 "operator account"
		verification:           "unverified"
		approxDistanceKm:       number & >0
		distanceMeaning:        "unspecified"
		cameraFocusAndFollow:   bool
		pilotCertificateNeeded: bool
	}
}

cameraModels: {
	smaller: #ReportedModel & {
		model:            null
		operatingWeightG: null
		reported: {
			approxDistanceKm:       15
			cameraFocusAndFollow:   true
			pilotCertificateNeeded: false
		}
	}
	larger: #ReportedModel & {
		model:            null
		operatingWeightG: null
		reported: {
			approxDistanceKm:       30
			cameraFocusAndFollow:   true
			pilotCertificateNeeded: true
		}
	}
}

verification: {
	range:         "The account did not distinguish controller transmission range, total flight distance or usable flight radius. Verify against the exact Canadian model and configuration. No permitted flight distance is established by these estimates."
	camera:        "Verify focus and subject-follow features in each model's manual."
	certification: "Check each aircraft's operating weight including the fitted battery, accessories and payload, and the planned flight category."
}

canada: {
	checkedOn:           "2026-11-17"
	certificateIssuer:   "Transport Canada"
	airspacePermissions: "NAV CANADA handles requests for access to control zones it manages."
	microdrone:          "Ordinary operations with an aircraft weighing under 250 g in flight do not require a pilot certificate or registration."
	smallDrone:          "From 250 g through 25 kg, registration and the appropriate pilot certificate are normally required."
	basicOperations:     "The Small Basic Exam is online. Basic operations require visual line of sight."
	sources: {
		pilotCertificates: "https://tc.canada.ca/en/aviation/drone-safety/drone-pilot-licensing/getting-drone-pilot-certificate"
		categories:        "https://tc.canada.ca/en/aviation/drone-safety/learn-rules-you-fly-your-drone/drone-operation-categories-pilot-certificates"
		registration:      "https://tc.canada.ca/en/aviation/drone-safety/drone-zone/drone-zone-issue-10-august-2026"
		airspace:          "https://www.navcanada.ca/en/nav-drone-faq.aspx"
	}
}
