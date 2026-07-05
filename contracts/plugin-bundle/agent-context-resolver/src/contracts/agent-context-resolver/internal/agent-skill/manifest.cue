package agentskill

#ContractID:   string & =~"^df:contract/[a-z0-9._-]+$"
#ProjectionID: string & =~"^df:projection/[a-z0-9._-]+$"

#SkillName: string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"

#RelativePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#SkillInstallRoot: ".codex/skills/\(#SkillName)" | ".codex/plugins/agent-context-resolver/skills"
#ScriptInstallPath: string & =~"^\\.codex/(skills/[a-z0-9-]+|plugins/agent-context-resolver)/scripts/[a-z0-9-]+$"

#ProjectionProvenance: close({
	projection_id: #ProjectionID
	contract_ids: [#ContractID, ...#ContractID]
	generated: true
})

#SkillMetadata: close({
	name:        #SkillName
	description: string & !=""
	path:        #RelativePath & ("\(#SkillInstallRoot)/SKILL.md")
	provenance:  #ProjectionProvenance
})

#HookCommand: close({
	type:          "command"
	command:       #RelativePath & #ScriptInstallPath
	timeout:       int & >0
	statusMessage: string & !=""
})

#HookProjection: close({
	hooks: {
		UserPromptSubmit: [{
			hooks: [#HookCommand, ...#HookCommand]
		}]
	}
})

#ScriptAsset: close({
	path:       #RelativePath & #ScriptInstallPath & !~"(^|/)bin/"
	content:    string & =~"^#!/bin/sh\n" & !~"/home/_404/src/contract\\.cuemod" & !~"/[^ \t\n]*/dotfiles/bin"
	executable: true
	provenance: #ProjectionProvenance
})

#SkillProjection: close({
	metadata: #SkillMetadata
	hooks:    #HookProjection
	scripts: [string]: #ScriptAsset
})
