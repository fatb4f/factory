package parity

factoryParityCertificate: close({
	schema: "factory.parity-certificate.v1"
	issue:  "#71"
	state:  "S5 ParityValidated"
	source: close({
		repository: "fatb4f/contract.cuemod"
		branch:     "factory/reflective-transition-factory"
		commit:     "0743121d8806f657ef20e22aadb77da93c735a1f"
		path:       "contracts/factory"
	})
	target: close({
		repository: "fatb4f/factory"
		branch:     "main"
		seedCommit: "3f657e745abfbefccfe0fa64537126e95b016560"
		rebindCommit: "46dcd6d60cba949ec8deecb351635f9942430a1a"
		path:       "contracts/factory"
	})
	normalization: [
		"Replace github.com/fatb4f/contract.reflective-transition-factory/contracts/factory with FACTORY_MODULE.",
		"Replace github.com/fatb4f/factory/contracts/factory with FACTORY_MODULE.",
	]
	validation: close({
		command: "just check"
		result:  "pass"
	})
	comparison: close({
		command: "diff -qr normalized(source/contracts/factory) normalized(target/contracts/factory)"
		result:  "pass"
	})
	authority: close({
		activeRepository: "fatb4f/factory"
		activeRoot:       "contracts/factory"
		sourceDetachGate: "contract.cuemod detach may proceed after this certificate is committed"
	})
})
