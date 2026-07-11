package code_intel_python

import "quicue.ca/vocab"

// Populate with profile resources constrained by the shared vocabulary.
resources: [Name=string]: vocab.#Resource & {name: Name}
