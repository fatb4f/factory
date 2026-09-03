# INF1035 — Chapitre 1: Introduction à l'informatique et à la programmation

> Structured text projection extracted from `INF1035 - Chapitre 01 - Introduction.pdf`. The supplied note is 20 pages; figures and page layout are omitted here. Organization and examples follow the course material.

**Course:** INF1035 — Informatique pour les sciences  
**Theme:** Programmation, simulation et exploitation des données  
**Term:** Automne 2026  
**Instructor:** Dylan Lebatteux

## 1. Matériel et logiciel

An **ordinateur** is a programmable electronic machine that automatically processes data to produce information and carry out tasks. A **programme** is a sequence of instructions executed by the computer.

The course separates:

- **matériel / hardware** — physical components;
- **logiciel / software** — programs executed on the hardware.

A typical computer is presented as five cooperating components:

1. processor (**CPU**);
2. main memory (**RAM**);
3. secondary storage;
4. input devices;
5. output devices.

### 1.1 CPU

Executing a program means carrying out its operations one by one. The CPU traditionally contains:

- an arithmetic and logic unit (**UAL / ALU**) for calculations and comparisons;
- a control unit (**UC**) that orchestrates instruction execution.

The notes contrast early vacuum-tube computers such as ENIAC with modern microprocessors.

### 1.2 RAM and secondary storage

**RAM** is the computer's fast working area. It contains the program currently being executed and the data being manipulated. It is **volatile**: its contents disappear when power is removed.

**Secondary storage** is persistent and slower. Programs/data are stored there and loaded into RAM when needed. Examples include HDDs, SSDs and USB flash storage.

The physical storage mechanisms differ:

- RAM: electrical charges in small capacitive structures;
- HDD: persistent magnetic regions on rotating platters;
- SSD / flash: trapped electrical charges in non-volatile memory cells.

### 1.3 Input, output and software families

**Input** is data received by the computer through devices such as a keyboard, mouse, touchscreen, scanner, microphone or camera.

**Output** is data produced by the computer and presented through devices such as a display, printer or speaker.

Two broad software families are introduced:

- **system software** — operating systems, utilities and development tools such as assemblers, compilers and interpreters;
- **application software** — word processors, spreadsheets, email clients, browsers, games and similar end-user programs.

## 2. Le stockage des données

All stored computer data is ultimately represented as sequences of **0** and **1**.

- A **bit** is one binary digit.
- A **byte / octet** contains 8 bits.
- Memory and storage capacity are measured in bytes and their multiples.

### 2.1 Binary integers

Each binary position represents a power of two. On eight bits the positional values are `1, 2, 4, 8, 16, 32, 64, 128`.

Course examples:

```python
for position in range(8):
    print(f"2^{position} = {2**position}")
```

Python can convert between bases:

```python
print(int("10011101", 2))  # 157
print(bin(157))             # 0b10011101
print(int("11111111", 2))  # 255
```

Eight bits provide `2**8 = 256` distinct patterns, so an unsigned byte spans **0–255**. Sixteen bits span **0–65,535**.

### 2.2 Characters: ASCII and Unicode

Characters are assigned numeric codes, which are then stored in binary.

- **ASCII** defines 128 codes; uppercase `A` has code 65.
- **Unicode** assigns codes to characters across many writing systems.
- **UTF-8** encodes Unicode code points as one to four bytes while preserving one-byte ASCII representations.

Python examples:

```python
print(ord("A"))  # 65
print(chr(65))    # A

for letter in "Python":
    print(letter, "->", ord(letter))
```

### 2.3 Signed integers, real numbers, images and sound

A binary pattern needs an **encoding convention** and a **type** to determine its meaning.

For signed integers the notes introduce **two's-complement** representation. On eight bits the representable range is **-128 to 127**. The high-order bit contributes `-128` in the signed interpretation, while the remaining positions contribute their ordinary positive weights.

Real numbers are introduced through the idea of **floating-point** representation: significant digits and an exponent represent scale separately. The notes explicitly present this as a simplified conceptual model rather than the exact implementation layout of a Python `float`.

Other digital data follows the same principle:

- an image is represented as a grid of encoded pixel values;
- sound is sampled at regular intervals, with each sample represented numerically.

The same bits can therefore mean different things depending on type. For example, `01000001` can represent integer 65 or character `A`; `11111111` can be 255 when unsigned or -1 when interpreted as an eight-bit signed two's-complement value.

## 3. Le fonctionnement d'un programme

A CPU performs simple operations such as loading values, arithmetic, movement and comparison. It directly understands **machine language**, whose instructions are binary encodings defined by the processor's **instruction set**.

The notes distinguish architectures such as **x86-64** and **ARM**. A program stored on secondary storage is copied into RAM when executed; the CPU then processes the in-memory instructions.

### 3.1 Fetch–decode–execute

For each instruction, the CPU repeats:

1. **fetch / chercher** — read the next instruction from memory;
2. **decode / décoder** — determine the requested operation;
3. **execute / exécuter** — carry out that operation.

### 3.2 Machine, assembly and high-level languages

A programming language provides symbols and rules for expressing instructions in a form more usable by humans.

- **Low-level languages**, especially assembly, remain close to machine instructions. An **assembler** translates mnemonics such as `add`, `mul` and `mov` into machine code.
- **High-level languages** hide much of the hardware detail and support more expressive programming. Examples listed include FORTRAN, COBOL, C/C++, Java, JavaScript, R, Python and Rust.

General trade-off presented by the notes:

```text
higher abstraction → easier programming, less direct hardware control
lower abstraction  → more direct control, greater implementation complexity
```

### 3.3 Keywords, operators, syntax and statements

- **Keywords / mots-clés** have predefined language roles (`if`, `for`, `def`, ...).
- **Operators** act on values (`+`, etc.).
- **Syntax** is the set of structural rules a program must follow.
- A **statement / instruction** is a complete command formed according to those rules.

The notes inspect Python's keyword list:

```python
import keyword

print("Nombre de mots-clés en Python :", len(keyword.kwlist))
print(keyword.kwlist)
print(12 + 75)
```

The supplied output reports 35 keywords for the Python version used to produce the note.

### 3.4 Compiler or interpreter

The material contrasts two translation models:

| Aspect | Compiled | Interpreted |
|---|---|---|
| Translation | source translated before execution | instructions translated/executed during execution |
| Runtime | generally faster after compilation | translation overhead occurs at runtime |
| Error discovery | compilation can reject code before execution | errors may surface while executing |
| Portability | executable may target a platform | source requires a compatible interpreter |
| Examples in note | C, C++, Java | Python, JavaScript, R |

Python is introduced as an interpreted language. A syntax error prevents successful translation/execution; the note illustrates this with an unterminated string literal.

## 4. Premiers pas avec Python

### 4.1 What is Python?

Python is presented as a high-level language created by Guido van Rossum in 1991, with these course-relevant properties:

- interpreted execution;
- clear syntax;
- dynamic typing;
- cross-platform availability;
- free/open-source distribution;
- broad library/community ecosystem;
- strong use in data analysis, visualization and machine learning.

### 4.2 Execution modes

The notes introduce three ways to execute Python code:

1. **Interactive mode** — start `python`, enter instructions at the `>>>` prompt and receive immediate results; typed commands are not a reusable saved program by themselves.
2. **Script mode** — save source in a `.py` file and execute the program as a file.
3. **Jupyter Notebook** — execute code cell-by-cell in a saved `.ipynb` document that can combine executable cells with Markdown text, images and tables.

### 4.3 Anaconda distribution

**Anaconda** is presented as a preassembled Python distribution oriented toward scientific/data work. The course note describes it as bundling:

- Python;
- scientific libraries such as NumPy, Pandas and Matplotlib;
- Jupyter Notebook;
- Spyder;
- Anaconda Navigator.

It also introduces **isolated environments**, where projects can keep separate Python/library versions rather than interfering with one another.

## 5. Synthesis

The chapter's dependency spine is:

```text
hardware + software
       ↓
binary representation
       ↓
CPU execution model
       ↓
programming-language abstraction
       ↓
compiler / interpreter
       ↓
Python execution surfaces
       ↓
scientific Python environment
```

Key terms defined by the note include:

- ordinateur;
- programme / logiciel;
- donnée and information;
- matériel;
- CPU;
- RAM;
- stockage secondaire;
- entrée / sortie;
- logiciel système / logiciel d'application;
- bit / octet;
- binaire;
- encodage;
- ASCII / Unicode / UTF-8;
- mode interactif / mode script;
- Jupyter Notebook;
- Markdown;
- bibliothèque / paquet;
- distribution;
- environnement isolé.

## Reference named in the course note

T. Gaddis, *Starting Out with Python*, 6th ed., Pearson, chapter 1.
