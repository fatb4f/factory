package issue

_alternateRoot: "github.com/fatb4f/factory/\("cue")mod"

#RootCueModuleImport: string & =~"^github\\.com/fatb4f/factory/" & !~"^\(_alternateRoot)(/|$)"

rootCueModuleImportAccepted: #RootCueModuleImport & "github.com/fatb4f/factory/contracts/meta/impl"

_negativeBottomChecks: {
	alternateModuleRootRejected: #RootCueModuleImport & "\(_alternateRoot)/contracts/meta/impl"
}
