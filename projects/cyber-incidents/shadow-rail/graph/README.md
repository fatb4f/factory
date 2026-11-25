# Shadow Graph

This first Phase 4 slice defines a closed bitemporal relationship revision in
`graph.cue`. It is not a graph realization, incident assertion, evidence
admission, or attribution decision. Shadow Rail World owns vocabulary. Exchange
formats and transform runtimes do not own graph semantics.

- A relationship ID persists across revisions. Endpoint references include rail,
  ID, revision and concept. A repository or snapshot must resolve those
  references and enforce unique revision identities.
- Both windows are half-open UTC Unix-second intervals. Valid time is when the
  relationship applies. Knowledge time is when a particular revision was
  available. A revision is visible only when both cutoffs fall in their
  respective windows. No valid-time fallback can reveal a later correction.
- Support and contradiction link recorded observations or evidence references
  to claims, hypotheses, or attribution assessments. They do not establish
  those claims. Reconciliation requires distinct rails, stays candidate or
  disputed, and never merges identities.
- Provenance points to a capture digest, source revision and locator. The
  contract checks the shape, not the existence or admission of the capture.

Still to qualify across revisions: reference resolution, gaps and overlaps,
the replacement protocol, replay snapshots, and tests demonstrating that
later knowledge cannot leak into an earlier replay.

Run `python3 projects/cyber-incidents/shadow-rail/graph/validate.py` from the
repository root with CUE v0.16.1 on PATH. The cases are synthetic and no runtime
data is fetched.
