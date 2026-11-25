# Shared typed transforms (T0 draft)

Extend the existing [native binding bridge](python-native-bindings.md) rather than
introducing a second source of domain meaning. CUE owns domain constraints and
admission. Generated native objects carry data. CUE validation receipts and source
digests remain explicit and do not authorize new findings.

The initial port in `runtime/typed_transform.py` is intentionally experimental.
Callers translate validated native inputs into typed outputs, passing input
digests and separate valid-time and knowledge-time cutoffs. Loss must be
returned explicitly, even when the payload is usable. If the transform cannot
honor its contract, it raises `TransformRejected` without a partial result.
The port does not validate digests, receipts, or facts itself. A runner must
check those obligations before enabling a production transform.

Use Pydantic for strict wire decoding, not as an alternative domain schema.
Keep Ibis and its backend behind the execution adapter and reuse the existing
RelationalPlan authority. Enrichment must retain provenance and cannot produce
new admissions. T1 qualifies exact API declarations and observed behavior
separately. No frontend consumer should depend on this draft port.
