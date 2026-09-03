# INF1035 A26 learning graph

## Conceptual spine

```text
physical machine
  CPU · RAM · storage · I/O
        ↓
binary representation
  bit · byte · positional binary
  type/encoding gives bit patterns meaning
  ASCII · Unicode · UTF-8
  two's complement · floating point
        ↓
execution model
  machine language
  fetch → decode → execute
        ↓
programming abstraction
  low-level ↔ high-level
  compiler ↔ interpreter
        ↓
Python execution environment
  interactive · script · Jupyter
```

The p. 9 representation rule is deliberately retained as a cross-cutting prerequisite: a bit pattern is not self-describing. The contract projects that idea forward to NumPy as a `content-dependency`, without pretending Chapter 1 already teaches NumPy details.

## Scheduled progression

```text
variables/operators/output
        ↓
conditions + boolean logic
        ↓
loops
        ↓
functions
        ↓
files + exceptions
        ↓
lists + tuples
        ↓
midterm (Ch. 1–7)
        ↓
strings + CSV
        ↓
dictionaries + sets + JSON
        ↓
NumPy → Pandas → Matplotlib → scikit-learn
```

The NumPy → Pandas → Matplotlib → scikit-learn arrows are schedule-sequence edges, not claims that each library is a strict technical prerequisite for the next.

## Evaluation control surface

```text
TP1 10%   TP2 10%   TP3 10%
     \       |       /
      \      |      /
       overall result >= 50%

midterm 35% + final 35%
           ↓
combined exam result >= 50%
```

Both gates are required. The source statement is preserved as a combined two-exam threshold; the contract does not infer that each exam must individually be >=50%.

## Calendar control points

- no Faculty of Science reading week;
- withdrawal without failure: **2026-11-13**;
- reserve session: **2026-12-15**;
- final + TP3 due: **2026-12-22**.
