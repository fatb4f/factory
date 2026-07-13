package upstream

import "strings"

#NonEmptyString: string & strings.MinRunes(1)
#ID:             #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#GitCommit:      string & =~"^[0-9a-f]{40}$"
#GitBlob:        string & =~"^[0-9a-f]{40}$"
#Semver:         string & =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"

#SourceClass:
	"normative-specification" |
	"standard-library-documentation" |
	"go-api-contract" |
	"cli-behavior" |
	"executable-test" |
	"explanatory-documentation" |
	"release-notes" |
	"version-identity"

#AuthorityRole: "normative" | "supporting" | "context-only"
#DigestAlgorithm: "git-blob-sha1"

#ClassPolicy: close({
	id:                   #SourceClass
	role:                 #AuthorityRole
	mayDefineConcepts:    bool
	requiredForAdmission: bool
})

#Digest: close({
	algorithm: #DigestAlgorithm
	value:     #GitBlob
})

#ArtifactIdentity: close({
	id:         #ID
	class:      #SourceClass
	role:       #AuthorityRole
	repository: "https://github.com/cue-lang/cue"
	revision:   #GitCommit
	path:       #NonEmptyString & !~"^(https?://|refs/heads/|refs/tags/)"
	digest:     #Digest
	retrieval:  "github-contents-at-commit"
	mutable:    false
})

#ModuleIdentity: close({
	path:     "cuelang.org/go"
	version:  #NonEmptyString & =~"^cuelang\\.org/go@[0-9a-f]{40}$"
	revision: #GitCommit
})

#CLIIdentity: close({
	binary:   "cue"
	version:  #NonEmptyString & =~"^cue@[0-9a-f]{40}$"
	revision: #GitCommit
})

#EngineIdentity: close({
	languageVersion: #Semver
	goModule:        #ModuleIdentity
	cli:             #CLIIdentity
})

#AuthorityBoundary: close({
	"normative-specification":        #ClassPolicy & {id: "normative-specification"}
	"standard-library-documentation": #ClassPolicy & {id: "standard-library-documentation"}
	"go-api-contract":                #ClassPolicy & {id: "go-api-contract"}
	"cli-behavior":                   #ClassPolicy & {id: "cli-behavior"}
	"executable-test":                #ClassPolicy & {id: "executable-test"}
	"explanatory-documentation":      #ClassPolicy & {id: "explanatory-documentation"}
	"release-notes":                  #ClassPolicy & {id: "release-notes"}
	"version-identity":               #ClassPolicy & {id: "version-identity"}
})

#AuthorityRecord: close({
	id:           "cue-upstream-authority-v1"
	repository:   "https://github.com/cue-lang/cue"
	revision:     #GitCommit
	pinnedAt:     #NonEmptyString
	retrieval:    "github-contents-at-commit"
	movingTarget: false
	boundary:     #AuthorityBoundary
	engine:       #EngineIdentity
	artifacts:    {[#ID]: #ArtifactIdentity}
})
