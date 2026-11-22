# CUE-to-native Python bindings

Status: implemented bounded first slice, tracked by issue #224. The shared bridge
extends the existing semantic-runtime projection. The legacy generator, generated
types and mapping interfaces remain supported.

## Contract and authority

`contracts/state/python-bindings.cue` owns API evidence shapes, structured target
annotations, binding references, duplicate-identity checks and qualification
boundaries. `python-native-context.cue` owns the first binding instance. CUE remains
the domain and admission authority.

| Layer | Owns | Does not establish |
|---|---|---|
| Domain CUE package | Meaning, constraints, admissible states and transitions | Python library behavior |
| Pinned typeshed declarations | Versioned target API declarations and overload signatures | Observed behavior or domain facts |
| CUE binding plan | Explicit domain-type/field to native-API mapping and validation obligations | Automatic inference of every CUE constraint |
| Generated Python | Executable frozen/slotted objects and nested type annotations | Instance validity or admission |
| Native adapter | Structural decoding, wire encoding, explicit CUE validation receipt | An admission grant |
| Existing semantic runtime | Snapshot-bound lookup/navigation | New semantic facts from object existence |

This replaces raw `pythonType` expressions **for the new slice** with structured
annotations: API reference, local generated reference, tuple of an element, or
string literals. The original projection remains unchanged for compatibility.

The schema and compiler accept an explicit owning CUE source/package, so another
domain can author a binding plan without changing the compiler. The implemented
API target capability is deliberately small: `dataclasses.dataclass`, built-in
`str`, `int`, `tuple`, and `typing.Literal` on Python 3.12. Other constructors,
scalar types, unions, generic forms, or libraries require explicit qualification
extensions. Unsupported forms fail rather than degrading to `Any`.

## Pinned API evidence

Typeshed revision `e75a39fec6f375f5002d54c5607b44bedc025a4b` is retained under
`state/python-api/typeshed/`, with its Apache license. The complete original
`builtins.pyi`, `dataclasses.pyi`, and `typing.pyi` bytes are preserved. Their hashes,
repository/revision, requested symbols, license hash and target Python version
are CUE-owned in `pythonAPISource`.

The original files were acquired from
`https://raw.githubusercontent.com/python/typeshed/<revision>/<path>`.
Reacquisition must reproduce the recorded SHA-256 values; a new revision needs an
explicit source-pin and binding review, not an automatic upgrade to `main`.

`scripts/python_api_facts.py` parses stubs with CPython AST. It never imports or
executes them. It extracts selected top-level declarations, overload parameters,
annotations, source line ranges, declaration digests and selected version guards.
The supported guards compare `sys.version_info` to a two-integer version tuple.
Unknown relevant guards, patch-sensitive comparisons and missing declarations
fail closed. Unrelated branches do not become selected API evidence.

`state/python-api/facts.json` is disposable, reproducible evidence. The compiler
re-extracts it and checks equality before using it; changing a fact, source file,
source pin or license breaks validation. Each generated module records its plan
and API-facts digests and semantic source metadata.

The declaration check proves selected-symbol presence and a compatible decorator
overload for the requested boolean keywords. It is **not a complete Python
assignability solver, stubtest run, or proof of target behavior**. Native runtime
tests separately exercise construction, immutability, slots and conversion.
Future `py.typed`, third-party stub distributions, full static checking and other
native libraries must preserve this declaration/behavior distinction.

## First executable slice

`runtime/generated/native_semantic_context.py` contains six generated types:

- `SemanticAuthorityRef`
- `SemanticRef`
- `SourceIdentity`
- `SourceOccurrence`
- `ContextArtifactRef`
- `ContextArtifact`

Nested authority/source/occurrence references use generated classes. Subject
collections use native tuples. Source kinds and context planes use literals.
All source-occurrence location fields are represented, including optional line
and byte offsets omitted from the older projection.

Optional absence uses `UNSET`; it is not converted to `None`. `to_wire()` omits
absent fields, and decoding rejects explicit null where this binding has no null
variant. Tuples become JSON arrays at the wire boundary. A native object can
therefore round-trip without collapsing missing into null or losing provenance
offsets.

```python
from runtime.generated import native_semantic_context as native
from runtime.native_binding import NativeModelAdapter, to_wire

binding = NativeModelAdapter(native)
receipt = binding.decode_validated("SemanticRef", {
    "authority": {
        "id": "fixture",
        "contract": "contracts/state/semantic-context.cue",
    },
    "subject": "sample",
})

ref = receipt.value
assert isinstance(ref.authority, native.SemanticAuthorityRef)
assert receipt.admission == "not-determined"
wire = to_wire(ref)
```

`decode()` is structural conversion only. `decode_validated()` additionally invokes
the owning CUE package/root with concrete validation. The receipt retains payload
digest, selected CUE root, a conservative digest of local contract/module inputs,
and CUE engine version, together with binding-plan and API-facts digests. It does
not contain an admission grant. The current receipt
input digest covers local repository contracts and module metadata; externally
resolved CUE dependencies would need their own pin/digest extension.

`SemanticRuntime.semantic()` now accepts these native references alongside legacy
references and mappings. It still requires the subject to exist in its bound
snapshot. A CUE-valid reference to a missing subject raises `KeyError`; object
construction and CUE validation cannot create a subject or an admitted relation.

The `cueRequired` entries in each plan enumerate important unprojected obligations,
such as nonempty strings, digest patterns, numeric minima and nonempty collections.
They are reviewed declarations, not an automatically complete constraint-loss
analysis. The blanket policy revalidates every value in CUE. Cross-record admission,
causal attribution and transition rules remain with their domain-owned contracts.

## Reproduce and validate

From repository root, with CUE v0.16.1 and Python 3.12:

```sh
python3 scripts/python_api_facts.py --check state/python-api/facts.json
cue export ./contracts/state:state -e nativePythonProjection --out json > /tmp/native-plan.json
python3 scripts/generate_semantic_runtime_types.py /tmp/native-plan.json \
  --api-facts state/python-api/facts.json --output /tmp/native_semantic_context.py
cmp /tmp/native_semantic_context.py runtime/generated/native_semantic_context.py
bash scripts/validate-python-native-bindings.sh
```

Both the contract suite and Observatory validation invoke the new checks. CI pins
Python 3.12 and watches API-evidence/compiler paths. No network access is required
to extract, generate or test the bridge. The native adapter checks its configured
Python major/minor and source digest before use.

## Adoption across Factory

Project adoption requires a domain-owned binding plan, native/wire round-trip
fixtures, explicit constraint losses, API declaration qualification and separate
CUE/domain admission checks. This PR wires the shared semantic-context slice; it
does not claim all 14 registered units have been migrated.

Next consumers can be IVAC evidence/evaluation types and industrial workbook
requests, followed by Gym's object-native session model. A new API target should
be added only when an actual consumer needs it. Native Ibis expressions remain
an analytical lowering target, rather than being wrapped in a second domain model.
IVAC regulatory source completeness and legal qualification remain separate work.
