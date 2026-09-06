# Factory projection toolchain

Status: architecture guidance / tracked by GitHub issue #184

## Objective

Factory should prefer a small, reusable OSS projection toolchain across analytical, documentary, semantic, operational and evidential comprehension work instead of introducing a bespoke rendering stack for each domain.

The recurring pattern is:

```text
authoritative structure
        ↓
qualified / admitted content
        ↓
content projection
        ↓
executable relational representation
        ↓
late materialization
        ↓
human-facing renderer / publication adapter
```

Generated documentation from decorators is a useful analogy. The structured source is not itself the documentation; a downstream projection transforms machine-readable meaning into a representation optimized for human consumption.

Observatory applies that pattern beyond code documentation to:

```text
semantic state
documentation
proposals
decisions
claims
evidence
tracker state
repository structure
telemetry
analytical records
```

The output may be an entity page, table, chart, topology, timeline, inspector, generated narrative, document or publication artifact. Output shape does not change the authority of the input.

## Authority boundary

The projection toolchain is downstream of Factory authority.

```text
CUE / narrow domain authority
        ↓
constrained or admitted state
        ↓
Factory semantic/context/analytical projection
        ↓
replaceable OSS realization layers
```

No parser, relational engine, notebook, template, document converter, charting library or graph renderer becomes semantic or qualification authority merely because it transforms or displays Factory state.

Presentation must preserve epistemic role and provenance. In particular:

```text
proposal != decision
observation != admitted fact
hypothesis != admitted response
tracker issue != semantic entity
documentary relation != semantic relation
coverage gap != inferred non-performance
```

If a human-facing representation would erase one of those distinctions, the projection is invalid even if the rendering is visually convenient.

## Preferred layered toolchain

The following roles are candidates for standard reuse where their capability is required. They are not mandatory dependencies for every Factory subsystem.

| Concern | Preferred role / candidate | Boundary |
| --- | --- | --- |
| Semantic and contract authority | CUE | Defines meaning, constraints and admission; never replaced by the projection stack. |
| Repository Markdown parsing | `markdown-it-py` candidate | Parse repository-native Markdown into structured tokens for documentary extraction; not semantic authority. |
| Source/code structural parsing | CPython AST, Tree-sitter, Jedi, SCIP as qualified by the owning context contract | Structural observation and identity evidence only. |
| Analytical intent | `factory.analytics-ir` | Typed analytical request, grain, provenance, admissibility and relational-plan semantics. |
| Executable relational/content IR | Ibis candidate | Lazy backend-independent relational expressions lowered from Factory intent or normalized content. |
| Local relational execution | DuckDB candidate | Executes admitted/lowered relations; does not define Factory meaning. |
| Materialized interchange | Arrow / PyArrow candidate | Typed columnar materialization and adapter boundary. |
| Reactive composition | Marimo | Interactive dependency/recomputation host; notebook state is not authority. |
| Analytical visualization | Altair / Vega-Lite candidate | Declarative chart adapter over typed relational content. |
| Small/static topology | Mermaid | Deterministic generated topology for bounded graphs and documentation. |
| Rich graph exploration | Replaceable graph renderer, to qualify | Interactive entity traversal must remain downstream of Factory graph authority. |
| Terminal text templating | Jinja candidate | Deterministic final text assembly from already selected/qualified content. |
| Document AST conversion/publication | Pandoc candidate | Cross-format document readers, AST transforms and writers at the publication boundary. |
| Telemetry semantic interface | OpenTelemetry semantic conventions | Machine-readable execution-observation vocabulary. |
| Telemetry schema tooling | Weaver | Resolve/check/diff/generate/live-check semantic-convention projections; CUE remains Factory authority. |

## Content projection, not a separate visualization subsystem

Observatory rendering is a form of analytical projection over heterogeneous content.

Traditional analytics commonly starts from measures and dimensions:

```text
rows / measures / dimensions
        ↓
filter / join / group / derive / order
        ↓
human-readable representation
```

Observatory performs the same class of transformation over meaning-bearing content:

```text
semantics / docs / proposals / decisions / evidence
        ↓
select / filter / join / relate / group / order
contextualize / compare / annotate / trace provenance
        ↓
human-readable representation
```

This means numerical analytics, repository comprehension, evidence inspection and generated documentation should share projection machinery where possible rather than maintain independent query/rendering stacks.

## Ibis as executable content IR

Ibis is a strong candidate for the runtime representation between Factory-owned analytical/content intent and render adapters.

The durable boundary remains:

```text
Factory authority
      ↓
Factory Analytics IR / admitted context
      ↓
Ibis expressions
      ↓
backend execution / materialization
      ↓
renderer
```

Ibis does not replace `factory.analytics-ir`. The Factory IR carries authority-sensitive concepts such as source identity, grain, admissibility, basis and provenance. Ibis is an executable lowering suitable for composition and backend-neutral relational execution.

For conventional analytical content:

```text
AnalyticalRequest
      ↓
RelationalPlan
      ↓
Ibis expression
      ↓
DuckDB or replaceable backend
      ↓
Arrow when materialization is required
```

For heterogeneous comprehension surfaces, content can be normalized into typed relations before lowering:

```text
semantic topology
    nodes: relations
    edges: relations

document view
    sections: relations
    references: relations
    claims: relations

proposal view
    alternatives: relations
    dependencies: relations
    decisions: relations

operational view
    issues: relations
    commits: relations
    qualifications: relations
```

A renderer consumes those relations according to presentation need rather than requiring Factory to invent a renderer-specific object model for every view.

## Reactive rendering model

Marimo should own presentation reactivity, while Ibis owns relational recomposition.

```text
Marimo control / selection
          ↓
Factory-qualified parameter or scope
          ↓
Ibis expression
          ↓
backend execution
          ↓
materialized or directly consumable relation
          ↓
view adapter
```

This keeps filtering, grouping, ordering, grain changes and analytical drilldown below the presentation layer instead of reimplementing them independently in each widget.

The renderer remains replaceable:

```text
Ibis relation(s)
      ├── table adapter
      ├── Altair/Vega-Lite
      ├── Mermaid
      ├── entity inspector
      ├── graph renderer
      └── publication adapter
```

## Markdown parsing

Repository Markdown should be treated as structured documentary input rather than an opaque text blob when comprehension requires headings, links, code blocks, tables, references or other syntax-level structure.

`markdown-it-py` is a good candidate for repository-native Markdown because it provides a token-oriented parser/renderer boundary that can feed documentary normalization without introducing document-publication concerns into acquisition.

A typical path is:

```text
README / proposal / decision Markdown
        ↓
Markdown parser
        ↓
syntax/token structure
        ↓
qualified documentary occurrences / relations
        ↓
Ibis-backed content projection where analytical composition is useful
```

Adopting a Markdown parser does not make headings, links or proximity semantic relations. Plane-specific qualification remains required.

## Jinja and template engines

Jinja belongs late in the pipeline.

Its useful role is deterministic assembly of text-based outputs such as:

```text
Markdown
HTML
XML
configuration-like text
LaTeX
small generated summaries
```

from an already-qualified context.

```text
qualified projection / materialized content
        ↓
Jinja template
        ↓
terminal text artifact
```

Jinja should not become the content IR or query language. Template logic should not own joins, semantic inference, admission, provenance reconstruction or substantial analytical derivation.

Prefer:

```text
Ibis / Factory projection computes content
        ↓
Jinja places content into a target text shape
```

not:

```text
Jinja loops and conditionals reconstruct domain meaning
```

The same rule applies to similar template systems such as Mako, Mustache or Handlebars: select one only when target text templating is needed, and keep it terminal.

Jinja is especially attractive where the surrounding realization is already Python, but using it should be justified by repeated templating needs rather than installed by default in every workbook.

## Pandoc and document converters

Pandoc solves a different problem from both Ibis and Jinja.

Its architecture is approximately:

```text
input format
    ↓
reader
    ↓
Pandoc document AST
    ↓
optional AST filters
    ↓
writer
    ↓
target format
```

That makes Pandoc valuable at two boundaries.

### Cross-format ingestion

When Factory needs to structurally inspect formats beyond repository-native Markdown, a Pandoc reader/AST may be an effective normalization source.

Examples include document formats where preserving headings, blocks, citations, tables or other document structure is more useful than plain-text extraction.

The output remains documentary observation until qualified by the appropriate Factory plane.

### Publication

Pandoc is particularly strong as a terminal publication backend when one admitted/generated document needs multiple forms:

```text
Factory document projection
        ↓
Pandoc AST / writer
        ├── Markdown
        ├── HTML
        ├── LaTeX / PDF pipeline
        └── DOCX or other supported output
```

Pandoc filters can transform its document AST between reading and writing. Those transforms are publication/document transforms, not a substitute for Factory analytical or semantic IR.

Because cross-format conversion can be lossy, keep Pandoc conversion late unless its AST is specifically required for ingestion. Do not round-trip authoritative content through Pandoc merely for convenience.

## Jinja versus Pandoc

They are complementary rather than competing choices.

Use Jinja when:

```text
the desired output structure is known
+ the input context is already selected
+ deterministic text interpolation/composition is sufficient
```

Use Pandoc when:

```text
document structure itself must be parsed/transformed
or
one structured document must be emitted into multiple publication formats
```

A valid combined pipeline is therefore:

```text
Factory/Ibis content projection
        ↓
Jinja-generated Markdown or other source document
        ↓
Pandoc publication
        ↓
HTML / PDF / DOCX / other terminal artifact
```

This is useful only when the intermediate template adds value. Factory should avoid stacking tools when a direct renderer or Pandoc writer is sufficient.

## Higher-level documentation systems

Systems such as Quarto, Sphinx, MkDocs and similar documentation/site generators should be considered orchestration/publication products above the same boundaries, not replacements for Factory authority or content IR.

Their adoption should require a concrete capability gap such as:

```text
multi-page publication
navigation/search packaging
citation/reference management
static site generation
cross-format report generation
extension/plugin ecosystem
```

If the required capability is merely interactive exploration, Marimo is the more natural host. If it is merely deterministic text generation, Jinja may suffice. If it is document conversion, Pandoc may suffice.

## Late materialization and late lossiness

Two rules should guide the stack.

### Materialize late

Keep relational content as lazy Ibis expressions until a renderer, export boundary or external adapter actually requires concrete data.

Arrow is the preferred typed materialization/interchange candidate where compatible.

### Introduce lossy or target-specific transforms late

Keep structured semantic/documentary/analytical meaning intact for as long as possible.

```text
authoritative / qualified structure
        ↓
relational/content projection
        ↓
late materialization
        ↓
target-specific transformation
        ↓
terminal artifact
```

Jinja formatting, Pandoc conversion, Mermaid text generation and chart specifications should therefore remain downstream of the richest reusable representation that the task needs.

## Selection policy

Before creating a new Factory projection abstraction:

1. identify the narrowest owning CUE authority;
2. determine whether the content can be represented by an existing Factory semantic/context/analytical contract;
3. determine whether an established OSS IR or protocol already covers the implementation boundary;
4. prefer lowering into that representation over introducing another generic Factory query/render algebra;
5. keep adapters replaceable and one-way with respect to semantic authority;
6. preserve provenance and epistemic role through every projection;
7. activate optional tools only when a concrete capability requires them.

This yields the preferred general shape:

```text
CUE authority
    ↓
Factory typed intent / admitted state
    ↓
normalized content
    ↓
Ibis where relational composition is useful
    ↓
DuckDB / replaceable execution
    ↓
Arrow when materialization is needed
    ↓
Marimo or publication host
    ↓
Altair / Mermaid / graph / Jinja / Pandoc / other thin adapter
```

## Current implementation versus direction

This document records architectural direction, not an assertion that every candidate is currently implemented.

At the current Observatory V1 boundary:

- `runtime/workbook.py` evaluates typed workbook projections;
- `runtime/marimo_adapter.py` emits deterministic Mermaid text and structured table/chart/timeline payloads;
- `runtime/property_graph_adapter.py` provides a downstream one-way exploratory graph projection;
- `world/industrial-signals/workbook.py` is the reference directory-bound workbook.

Ibis-as-content-IR, `markdown-it-py`, Altair/Vega-Lite, Jinja, Pandoc and richer graph rendering remain candidates to qualify against real workbook UX and publication tasks before they are promoted into implementation dependencies.

The target is not a maximal stack. It is a small set of reusable standard substrates that repeatedly solve Factory projection problems without acquiring authority they do not own.
