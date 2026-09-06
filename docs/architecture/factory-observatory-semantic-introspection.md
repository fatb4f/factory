# Factory Observatory semantic introspection and lineage

Status: architecture guidance / tracked by GitHub issue #185

## Objective

Factory Observatory should make the logical and analytical model of Factory directly comprehensible to a human without creating a second semantic authority.

The relevant source material is already structured and meaning-bearing at several layers:

```text
CUE semantic model
        ↓
Python-native semantic/context model
        ↓
Factory analytical intent / Ibis realization
        ↓
render projection
```

Observatory should therefore behave as a semantic introspection system rather than as a collection of manually maintained diagrams.

The core question is not only:

```text
what entities exist?
```

but also:

```text
what does this entity mean?
what authority owns it?
how is it constrained?
how is it represented in Python?
how is it projected into relational/analytical form?
how does primitive X become projection Y?
which semantic steps connect them?
```

The result is a bounded human-comprehension projection over existing semantic representations.

## Authority boundary

CUE remains the semantic authority.

Observatory does not promote Python classes, decorators, Ibis expressions, Structurizr workspaces, Rich output, Marimo state, graph layouts or renderer metadata into competing authority.

The direction remains one-way:

```text
CUE authority
    ↓
constrained / admitted model
    ↓
Python semantic/context realization
    ↓
analytical/query realization
    ↓
inspection projection
    ↓
render projection
```

A downstream representation may preserve, expose and navigate upstream meaning. It may not manufacture upstream meaning merely because it is convenient to display.

In particular:

```text
renderer adjacency      != semantic relation
visual grouping         != authority ownership
Python inheritance      != CUE semantic subsumption unless explicitly projected
Ibis join               != admitted semantic relation
layout                  != topology authority
notebook state          != admitted state
```

## CUE is more than evaluated output

Observatory must not treat CUE as only a validator or value emitter.

CUE carries the declarative semantic model itself through definitions, constraints, references, composition and unification. Factory's use of narrow CUE authorities means that the logical model and the rules that constrain its valid instances are available for introspection before any terminal rendering occurs.

The relevant semantic surface includes concepts such as:

```text
definitions
fields and constraints
references
composition
unification
closedness
optional/required structure
authority-local identity
admission constraints
semantic relations
```

CUE's value lattice also supplies a natural conceptual model for specialization and constraint accumulation.

A human-facing lineage view should therefore be able to explain a constrained value in terms of the model elements that participate in it:

```text
primitive / broad definition
        ↓
additional domain constraint
        ↓
composition / unification
        ↓
more specific admissible value
        ↓
concrete admitted instance
```

This is not a request to duplicate the CUE evaluator. Observatory projects the semantic structure and constraint relationships that Factory already relies on.

## Python-native semantic context

The Python-native layer is not merely serialization of evaluated CUE values.

It provides an executable semantic/context model suitable for local introspection and bounded navigation. Depending on the owning model, Python can carry meaning through normal language constructs such as:

```text
typed classes
object composition
inheritance where semantically appropriate
properties
methods
annotations
protocols
metadata / decorators
stable typed references
runtime-bound semantic/context objects
```

Decorators and metadata are especially useful as a projection mechanism because they can attach structured relationships such as evidence, admission, derivation, projection or provider capability to a Python-native representation without turning the decorator itself into semantic authority.

The current semantic runtime already establishes the important boundary: Python objects are bound to an immutable semantic/context snapshot and expose exact lookup, typed access, plane-qualified adjacency, bounded traversal and provenance navigation.

Conceptually:

```text
CUE #Project
      ↓ projection / generation
Python Project
      ├── typed fields
      ├── object relationships
      ├── semantic/context metadata
      ├── bounded navigation
      └── projection hooks
```

Python therefore answers a different but complementary question from CUE:

```text
CUE:    what is X and under what constraints is X valid?
Python: how can X be navigated and operated on while preserving its semantic context?
```

Observatory should introspect both.

## Analytical and query semantics

The next semantic layer is analytical transformation.

`factory.analytics-ir` remains the Factory authority for analytical intent. It carries concepts that ordinary dataframe/query engines do not own for Factory, including:

```text
source identity
snapshot identity
admissibility
provenance
input grain
output grain
project/filter/join/group/aggregate operations
derivations
ordering/windowing
capability gaps
```

An executable relational system such as Ibis then provides a rich query/expression model for realization.

The intended boundary is:

```text
Factory AnalyticalRequest / RelationalPlan
        ↓
Ibis expression tree
        ↓
backend execution / materialization
```

The Ibis expression graph is itself introspectable. Selections, joins, predicates, grouping, aggregation, windows and derived expressions form an analytical lineage that can be shown to a human instead of being hidden behind a final table or chart.

Ibis does not establish Factory semantic relations simply because two relations are joined. Its value to Observatory is that analytical realization remains structured enough to inspect.

At the current repository boundary, `factory.analytics-ir` is implemented; Ibis-as-general Observatory content/query realization remains a candidate described by `factory-projection-toolchain.md` and should be qualified before being treated as a mandatory dependency.

## Unified semantic lineage

Observatory should compose the native semantic representations rather than reconstruct lineage from terminal artifacts.

The canonical mental model is:

```text
                 CUE semantic model
                        │
                        ▼
                    #Project
                        │
              projection / generation
                        ▼
                Python Project
                /      |       \
         relations  metadata   behavior
                \      |       /
                        ▼
             analytical source
                        │
                  query / plan
                        ▼
               Ibis expression
                        │
                filter / join /
             group / derive / window
                        │
                        ▼
                analytical result
                        │
                  render projection
                        ▼
                human-facing view
```

For a particular output, the useful question becomes:

```text
How do we go from primitive X to projection Y?
```

The answer should be expressible as a typed lineage path over the contributing semantic layers.

For example:

```text
#Project
   │ CUE: constrained-by / composed-with
   ▼
#FundedProject
   │ CUE→Python: projects-to
   ▼
FundedProject
   │ Python: exposes / relates / decorates
   ▼
project funding source
   │ analytics: realizes-as
   ▼
projects ⋈ funding
   │ analytics: group-by(project)
   ▼
funding_by_project
   │ render: visualizes-as
   ▼
chart / table / integration view
```

The edge type is important. Observatory should not flatten all of these transitions into an unqualified generic `related-to` graph.

## Typed lineage edges

A lineage view should preserve the semantics of the layer that owns each transition.

Useful edge families include, conceptually:

```text
CUE/model
    references
    constrains
    composes-with
    unifies-with
    admits
    specializes

CUE → Python
    projects-to
    generates
    binds-to

Python/context
    contains
    exposes
    decorates
    navigates-to
    derives

analytics
    sources
    projects
    filters
    joins
    groups
    aggregates
    changes-grain
    windows
    derives

render
    selects
    summarizes
    visualizes-as
    renders-as
```

These names are projection vocabulary, not a new global Factory ontology. Where a relation has formal meaning in CUE or an owning domain contract, the projection must reference that meaning rather than invent an approximate substitute.

## Logical integration model

A primary Observatory requirement is projecting the logical core of Factory data models into a visual integration model that is easier for a human to consume.

The view should emphasize meaning rather than repository layout.

It should answer questions such as:

```text
what are the major logical entities?
which authority owns each entity?
which relations connect them?
which relations cross authority boundaries?
which models bridge domains?
which entities have relational realizations?
which analytical projections consume them?
```

A useful view therefore looks conceptually like:

```text
┌──────────────── Industrial Signals ────────────────┐
│                                                   │
│  Project ───── Facility ───── Organization        │
│     │             │                 │              │
│     │             └──── Technology ─┘              │
│     │                                             │
│     └──── Funding / Milestone / Outcome            │
└──────────────────────┬────────────────────────────┘
                       │ admitted bridge
                       ▼
┌────────────── Industrial Constraints ──────────────┐
│                                                   │
│ Resource ─ Capacity ─ Constraint ─ Demand          │
└──────────────────────┬────────────────────────────┘
                       │ relational realization
                       ▼
                  analytical views
```

The logical model remains CUE-owned. The visual integration model is a projection.

A model-oriented renderer such as Structurizr is attractive for this role because one structured model can support multiple scoped views. If qualified and adopted, Structurizr should receive a Factory-owned integration projection and remain a replaceable rendering adapter rather than becoming the source model.

## `rich.inspect()` as interaction analogy

`rich.inspect()` is a useful analogy for the Observatory interaction model.

For a local Python object:

```text
object
   ↓
rich.inspect()
   ↓
structured human-readable local view
```

For Factory:

```text
semantic/model subject
   ↓
Observatory inspection
   ↓
structured human-readable system view
```

The important property is that the inspection view is derived from the object/model rather than maintained as a second description of it.

A conceptual interaction surface is:

```text
inspect(subject)
    ├── summary
    ├── schema
    ├── relations
    ├── integration
    ├── lineage
    ├── relational realization
    ├── analytics
    └── provenance
```

The same subject can then be represented differently without changing its meaning.

## Introspection before rendering

Observatory should separate three concerns:

```text
meaning
  !=
what to inspect
  !=
how to display it
```

The preferred flow is:

```text
CUE / Python / analytical semantic surfaces
        ↓
semantic introspection projection
        ↓
bounded inspection request
        ↓
inspection result
        ↓
render request
        ↓
render projection
        ↓
replaceable adapter
```

This separation prevents layout, color, grouping, coordinates, terminal formatting or notebook widget state from leaking into the logical model.

A conceptual contract family may eventually resemble:

```text
LogicalModelProjection
InspectionRequest
InspectionResult
RenderRequest
RenderProjection
```

Those names are architectural placeholders until a narrow CUE contract owns them.

## View families

The same inspection result should support multiple human-comprehension views.

### Logical/model view

Answers:

```text
what exists?
what authority owns it?
what fields and constraints define it?
what logical relations connect it?
```

### Integration view

Answers:

```text
how do logical models connect across Factory?
where are authority boundaries?
where are explicit bridges?
where do relational and analytical realizations attach?
```

### Lineage view

Answers:

```text
how did primitive/model X become projection Y?
which CUE constraints contributed?
which Python semantic/context representation carried it?
which analytical operations transformed it?
```

### State view

Answers:

```text
which admitted instances exist in this snapshot?
which context planes and evidence occurrences are attached?
which coverage gaps remain?
```

### Analytical view

Answers:

```text
which source/grain feeds the result?
which operations change it?
where does grain change?
what capability realizes the plan?
```

### Provenance view

Answers:

```text
which authority, snapshot, occurrence, basis or source supports this node or edge?
```

These are different inspections of the same semantic system, not independent manually maintained documentation products.

## Render projection layer

Rendering is terminal and replaceable.

A bounded inspection result may project to different representations according to human need:

```text
InspectionResult
      ├── terminal inspector
      ├── logical integration diagram
      ├── lineage graph
      ├── relation matrix
      ├── ER-style model view
      ├── table
      ├── analytical chart
      ├── Marimo interactive surface
      └── machine-readable artifact
```

Candidate adapters include:

```text
terminal/local inspection    Rich-style renderer
model/integration views      Structurizr candidate
small generated topology     Mermaid / Graphviz-style adapters
analytical relations         Ibis-backed table/chart adapters
interactive composition      Marimo
publication                  downstream document adapters
```

The adapter consumes a Factory-owned projection. It must not be scraped later to recover semantic state that was available before rendering.

## Late lossiness

The introspection pipeline should retain the richest reusable structured representation until a renderer requires a narrower form.

Prefer:

```text
semantic model
    ↓
typed introspection graph
    ↓
bounded view
    ↓
renderer-specific projection
    ↓
terminal representation
```

rather than:

```text
semantic model
    ↓
plain text / diagram syntax
    ↓
re-parse terminal artifact to recover meaning
```

This is the same late-lossiness principle used by the broader Factory projection toolchain.

## Implementation direction

A future implementation should prefer adapters that introspect the native semantic representation of each layer:

```text
CUE model introspector ──────┐
                             │
Python semantic introspector ├──→ typed Observatory inspection graph
                             │
analytics/Ibis introspector ─┘
                                      ↓
                               bounded view selection
                                      ↓
                                render projection
```

The implementation should not start by defining a large generic graph ontology.

The narrowest viable path is:

1. project CUE logical entities, constraints and explicit relations;
2. correlate them with Python-native representations through explicit projection identity;
3. correlate analytical requests/plans and, where realized, Ibis expression nodes;
4. preserve typed cross-layer lineage edges;
5. select bounded human-facing inspection views;
6. lower those views into replaceable render adapters.

## Relationship to existing Observatory architecture

This document refines, rather than replaces, the current Observatory boundaries.

`factory-observatory.md` remains authoritative architecture guidance for:

```text
semantic/context snapshots
repository-context admission planes
Python runtime boundaries
analytics-ir boundaries
workbook scope/binding
property-graph projection boundaries
```

`factory-projection-toolchain.md` remains the implementation/tooling guidance for reusable OSS realization and rendering layers.

This document adds the missing comprehension model between those surfaces:

```text
native semantic representations
        ↓
typed semantic introspection / lineage
        ↓
bounded human-comprehension views
        ↓
render projection
```

The result is an Observatory that behaves less like a manually maintained documentation site and more like a repository-scale semantic `inspect()` facility.