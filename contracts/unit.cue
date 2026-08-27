package unit

#Name:     string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"
#UnitKind: "project" | "academic" | "world"
#UnitID:   string & =~"^(projects|academic|world)\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#TaskID:   string & =~"^(projects|academic|world)\\.[a-z0-9]+(?:-[a-z0-9]+)*\\.[a-z0-9]+(?:-[a-z0-9]+)*$"

#RepositoryPath: string & =~"^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$" & !~"(^|/)\\.{1,2}(/|$)"
#AuthorityPath:  #RepositoryPath & =~"(^|/)contract\\.cue$"
#AgentRootPath:  #RepositoryPath & =~"(^|/)\\.agents$"
#AgentPath:      #RepositoryPath & =~"(^|/)\\.agents/.*AGENTS\\.md$"

#Unit: close({
	id:     #UnitID
	kind:   #UnitKind
	agents: #AgentRootPath
})

#Task: close({
	id:         #TaskID
	name:       #Name
	unit:       #UnitID
	authority?: #AuthorityPath
	agent:      #AgentPath
	enabled:    bool
	cadence: close({
		everyDays: int & >0
	})
})
