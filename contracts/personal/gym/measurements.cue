package gym

#Measurement: close({
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
	id:          #MediaID
	kind:        "video" | "image"
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
