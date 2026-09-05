package unit

#Name:     string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"
#UnitKind: "project" | "academic" | "world" | "personal"
#UnitID:   string & =~"^(projects|academic|world|personal)\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#TaskID:   string & =~"^(projects|academic|world|personal)\\.[a-z0-9]+(?:-[a-z0-9]+)*\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#Weekday:  "monday" | "tuesday" | "wednesday" | "thursday" | "friday" | "saturday" | "sunday"

#RepositoryPath: string & =~"^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$" & !~"(^|/)\\.{1,2}(/|$)"
#AuthorityPath:  #RepositoryPath & =~"(^|/)contract\\.cue$"
#AgentRootPath:  #RepositoryPath & =~"(^|/)\\.agents$"
#AgentPath:      #RepositoryPath & =~"(^|/)\\.agents/.*AGENTS\\.md$"

#Unit: close({
	id:     #UnitID
	kind:   #UnitKind
	agents: #AgentRootPath
})

#Cadence: close({
	frequency: "weekly"
	weekday:   #Weekday
})

#Task: close({
	id:         #TaskID
	name:       #Name
	unit:       #UnitID
	authority?: #AuthorityPath
	agent:      #AgentPath
	enabled:    bool
	cadence:    #Cadence
})
