package gym

#Measurement: close({
	kind:       "measurement"
	id:         #MeasurementID
	metric:     string
	metricKind: #MetricKind
	value:      number
	unit:       #Unit
	side?:      #Side
	at?:        #Timestamp
	provenance: #Provenance
})

#DualLoadSample: close({
	kind: "dual-load"
	id:   #MeasurementID
	left: close({
		value: number & >=0
		unit:  #Unit
	})
	right: close({
		value: number & >=0
		unit:  #Unit
	})
	at?:        #Timestamp
	stance?:    string
	provenance: #Provenance
})

#MediaArtifact: close({
	kind:        "media"
	id:          #MediaID
	mediaKind:   "video" | "image"
	capturedAt:  #Timestamp
	uri?:        string
	digest?:     string
	perspective?: "front" | "rear" | "left-side" | "right-side" | "oblique" | "overhead" | "other"
	durationS?:  number & >=0
	frameRate?:  number & >0
	widthPx?:    int & >0
	heightPx?:   int & >0
	deviceID?:   #DeviceID
	note?:       string
})
