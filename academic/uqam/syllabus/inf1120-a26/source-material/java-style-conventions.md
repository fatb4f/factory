# INF1120 / INF2120 — Conventions de style Java

> Structured text projection of `ConventionsStyleJavaPourINF1120_INF2120(1).pdf`. Canonical source identity: `sha256:255cdc2ca6c81bdba5910f39fddb8c3e167a3923a8629e77c804d96ea54e9988`.

## 1. Naming

### Variables, attributes and parameters

Use meaningful **lower camelCase** names.

```java
double montantTotal;
char choixMenu;
```

Avoid arbitrary single-letter names except conventional loop-control variables. The course guide also discourages `$` and `_` in ordinary variable/attribute/parameter names.

### Constants

Use meaningful uppercase names with words separated by underscores.

```java
final int NBR_JOUEURS = 7;
```

### Methods

Use meaningful **lower camelCase** names that describe the operation.

```java
public void calculerSalaire(...) {
    ...
}
```

Accessors should follow `getX` / `setX` naming.

### Classes

Use meaningful **UpperCamelCase** names.

```java
public class FactureCommande {
    ...
}
```

## 2. Variable declarations

- Prefer one variable declaration per line.
- Declare local variables at the beginning of the method in which they exist, immediately after the opening brace, rather than introducing them later in the method body.

## 3. Blocks and indentation

- Place the opening brace at the end of the line that starts the class, method or control block, preceded by a space.
- Place the closing brace at the beginning of its own line after the final instruction of the block.
- Increase indentation consistently for child blocks.
- Sibling blocks begin/end at the same indentation level.

Preferred shape:

```java
while (a >= b) {
    if (a == b) {
        System.out.println("egaux");
    } else {
        System.out.println("differents");
    }
    a--;
}
```

## 4. Line length

Code lines should not exceed **120 characters**, including indentation.

When a line must be split, the guide permits breaks such as:

- after a comma;
- before an operator.

For a wrapped control expression, continuation lines should be indented by at least two additional indentation levels so the continuation is visually distinct from the block body.

## Constraint relationship

These style conventions operate together with `correction-criteria.md`. TP-specific statements can impose additional constraints and remain authoritative for their own submissions.
