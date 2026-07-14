module github.com/fatb4f/cue-bootstrap/runner

go 1.25.0

require cuelang.org/go v0.18.0

// Both the gopy binding package and cueprobe compile against this exact checkout.
// qualification.bootstrap_native verifies the replacement before building.
replace cuelang.org/go => ../workbook/.deps/cue
