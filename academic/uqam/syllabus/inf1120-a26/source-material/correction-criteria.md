# INF1120 — Critères généraux de correction du code

> Structured text projection of `CriteresGenerauxDeCorrection_V4.pdf`. Canonical source identity: `sha256:fbf0add95e353f1723817f135680b4cf73464d37baaeddb593e6c46e5e03e9ad`. Examples whose original meaning depends on PDF table layout are summarized rather than reconstructed visually.

## Documentation

### File preamble

Each source file must begin with a Javadoc comment containing at least:

- author;
- permanent code;
- email;
- date/version;
- description of the file contents.

### Method preamble

Each method must have Javadoc documentation. Relevant tags include parameters, return value and thrown exceptions.

## Indentation and comments

- Indentation must remain consistent with syntactic block nesting.
- Increase indentation after opening a block and decrease it after closing the block.
- Comments should explain complex code, non-obvious tests or algorithms rather than translating obvious instructions into prose.
- Avoid both under-documenting and commenting every line.

## Functional decomposition

A method should encapsulate:

- a reusable block of code; or
- a meaningful step in a complex algorithm.

Methods are treated as black boxes: they receive inputs, perform one coherent task reflected by the method name and return a result when appropriate.

Repeated code should be characterized and factored into a parameterized method. The course guidance expects `main` to remain short — roughly on the order of twenty lines — and to express the high-level algorithm rather than contain the implementation details.

## Code constraints

- Apply encapsulation once classes and objects are introduced.
- Declare local variables/constants at the beginning of their respective method.
- Use one variable declaration per line and one instruction per line.
- A method must contain zero or one `return` statement.
- A `void` method must contain no `return` statement.

The following constructs are prohibited by the course correction contract:

1. `break` outside a `switch` case where it is the final case instruction;
2. `continue`;
3. `return` inside `for`, `while`, `do...while`, `switch`, `if`, `try` or `catch` blocks;
4. `while (true)` loops;
5. operations in the update portion of a `for` header other than increment/decrement of the control variable;
6. modifying the `for` control variable inside the loop body.

Avoid explicit comparisons such as:

```java
== true
== false
!= true
!= false
```

Prefer the boolean expression itself. Likewise, do not use an `if/else` solely to assign `true` or `false`; assign the boolean expression directly.

## Input validation and robustness

All inputs must be validated syntactically and logically as appropriate, including examples such as:

- non-numeric input where an integer is expected;
- negative input where a positive value is required;
- values outside a required interval;
- invalid method parameters, including `null` where prohibited.

Additional correction expectations:

- comments are clear, relevant and concise;
- blank lines separate logical blocks/methods where useful;
- Java writing/style conventions from the course are respected;
- identifiers are meaningful rather than generic placeholders;
- values with only two states should use a boolean type;
- testing includes invalid input, erroneous values and boundary values;
- programs should be robust and avoid crashing on bad input where reasonably possible.

TP-specific statements may add stricter requirements.

## Programming-practice summary

The document closes with these design principles:

- avoid global variables; modules/methods communicate through parameters;
- low coupling;
- high cohesion;
- encapsulation;
- parameterization;
- black-box isolation / étanchéité;
- specialization;
- short, robust methods including `main`;
- avoid repeated code and optimize reasonably.
