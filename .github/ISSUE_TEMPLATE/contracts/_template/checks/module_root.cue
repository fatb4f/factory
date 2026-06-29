package issue

#RootCueModuleImport: string & =~"^github\\.com/fatb4f/factory/" & !~"^github\\.com/fatb4f/factory/cuemod(/|$)"

rootCueModuleImportAccepted: #RootCueModuleImport & "github.com/fatb4f/factory/contracts/meta/impl"

_negativeBottomChecks: {
	cuemodImportRootRejected: #RootCueModuleImport & "github.com/fatb4f/factory/cuemod/contracts/meta/impl"
}
