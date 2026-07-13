module github.com/fatb4f/cue-bootstrap/runner

go 1.25.0

require cuelang.org/go v0.18.0

// The exact target engine is checked out by qualification.bootstrap_native.
replace cuelang.org/go => ../workbook/.deps/cue
