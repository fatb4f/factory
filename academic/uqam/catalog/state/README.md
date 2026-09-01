# UQAM catalog comparison state

`admitted-baseline.json` is the single mutable comparison pointer for `academic.uqam.catalog` once a complete catalog acquisition has been admitted.

It references one immutable run under `../runs/<run-id>/`. Catalog runs contain source-qualified normalized institutional/community entities and explicit graph relations. The pointer is task state, not dispatcher state and not semantic authority.

No baseline pointer is committed until all required catalog discovery surfaces and group-category traversals complete successfully. A partial seed must remain a fixture or observation and must not be promoted to admitted state.

Do not edit a prior run. Advance the pointer only through the catalog task compare-and-swap publication protocol.
