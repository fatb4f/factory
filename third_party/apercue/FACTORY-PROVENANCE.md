Vendored from https://github.com/quicue/apercue.

Pinned commit: f485e108e5c8dd5420d86e385d7f54157aee1d8b
License: Apache-2.0, preserved in LICENSE.

Factory vendors this snapshot because apercue.ca@v0 is not yet published to
an OCI CUE registry. Factory .kb modules resolve the dependency through
cue.mod/local-module.cue replacements.

The vendored snapshot is intentionally limited to the public CUE packages and
documentation required by Factory:

- cue.mod
- patterns
- vocab
- charter
- README, ARCHITECTURE, LICENSE
- docs/api-stability.md
- docs/getting-started.md
- docs/pattern-api.md
