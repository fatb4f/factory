package unit

#Name:      string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"
#Namespace: "projects" | "academic" | "world"
#UnitKind:  "project" | "academic" | "world"
#UnitID:    string & =~"^(projects|academic|world)\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#TaskID:    string & =~"^(projects|academic|world)\\.[a-z0-9]+(?:-[a-z0-9]+)*\\.[a-z0-9]+(?:-[a-z0-9]+)*$"
#OutputID:  #TaskID

#RepositoryPath: string & =~"^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$" & !~"(^|/)\\.{1,2}(/|$)"
#AuthorityPath:  #RepositoryPath & =~"(^|/)contract\\.cue$"
#AgentRootPath:  #RepositoryPath & =~"(^|/)\\.agents$"

#TaskReference: close({
	id:        #TaskID
	authority: #AuthorityPath
	adapter:   #RepositoryPath
})

#OutputReference: close({
	id:        #OutputID
	authority: #AuthorityPath
	path:      #RepositoryPath
})

#Unit: close({
	id:        #UnitID
	kind:      #UnitKind
	authority: #AuthorityPath
	agents?:   #AgentRootPath
	tasks: [#Name]:   #TaskReference
	outputs: [#Name]: #OutputReference
})

#Registry: {
	[string]: #Unit
	...
}
