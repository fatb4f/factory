# INF1120 normalized learning graph

## Primary dependency spine

```text
program model
  → software lifecycle
  → problem definition / requirements
  → inputs + outputs + data types
  → pseudocode + boolean conditions
  → selections + loops
  → input validation + test cases
  → Java types / expressions / conversions
  → Java control flow + execution tracing
  → methods / parameters / returns / decomposition
  → String + Math libraries
  → classes / objects / references / encapsulation
  → arrays / traversal / references
  → exceptions / propagation
  → java.io text files
```

`prerequisite` represents a content dependency derived from the supplied material. Week placement is represented separately as `introduces` and lab reinforcement as `practices`; chronology is not silently promoted to a semantic prerequisite.

## Course-contract axis

```text
concept progression
        │
        │ constrained throughout
        ▼
style + Javadoc + declaration rules + control-flow restrictions
+ decomposition/robustness + submission/exam rules
```

Code may therefore be legal Java while still violating the INF1120 correction contract.

## Assessment interpretation

The current A26 evaluation structure is 30% intra, 30% final, 5% Quiz #1, 5% Quiz #2 and 10% each for TP1/TP2/TP3. Historical 2016 and A18/H19 quiz material is modeled only through `historical-assessment-derived` edges. Those edges are practice signals, not claims or predictions about A26 quiz content.

## Normalization issue

The supplied Moodle snapshot prints week 06 as `12/05/2026`. The normalized schedule stores `2026-10-12`, preserves the literal source value, and records the change as `schedule-sequence` derived because the surrounding weekly sequence and the October 13 quiz place that week in October.

## Query surface

The graph can answer questions such as:

- which concepts are prerequisites for arrays or exceptions;
- which week introduces and which lab practices a concept;
- which INF1120 rule constrains a generated Java construct;
- whether assessment evidence is current or historical;
- which source artifact supports a concept, edge or constraint;
- which due dates or source inconsistencies remain unresolved.
