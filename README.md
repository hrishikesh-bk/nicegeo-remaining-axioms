# System E Kernel

A typechecker kernel for a proof system based on the formal system **E** (Euclid’s Elements). The kernel is implemented in OCaml using Dune and is intended to support dependent type theory with built-in geometric types and a decidable definitional equality.

### Exploratory ideas

- Dependent type theory (no inductive types)
- Built-in types like Point and Circle
- Built-in object that satisfies the axioms of the non-negative part of a linearly ordered abelian group
- **Type checker:** infer type; decide definitional equality

---

## Project structure

```
system-e-kernel/
├── dune-project          # Dune and package configuration
├── system-e-kernel.opam  # Opam package manifest (generated from dune-project)
├── README.md             # This file
├── .gitignore
│
├── lib/                  # Core library (the kernel)
│   ├── dune
│   ├── term.ml           # Term AST and context types (environment, localcontext)
│   └── infer.ml          # Type inference (inferType)
│
├── bin/                  # Main executable
│   ├── dune
│   └── main.ml           # Entry point + demo/verification of inference
│
└── test/                 # Test suite
    ├── dune
    └── test_system_e_kernel.ml  # Unit tests for inferType (stack, lookup, errors)
```

### Roles

| Path | Purpose |
|------|--------|
| **lib/** | Reusable kernel: term representation and type inference. No I/O; used by both the binary and the tests. |
| **bin/main.ml** | Runnable program: builds an environment, runs a fixed set of inference checks, and prints results. Use it to see the stack-based inference in action. |
| **test/** | Automated tests: structured tests for `inferType` (const/Fvar lookup, Bvar stack, error cases). Run with `dune runtest`. |

---

## Prerequisites

- **OCaml** (4.08 or later recommended)
- **Dune** (3.x; the project uses `(lang dune 3.17)` in `dune-project`)
- **opam** (optional, for installing OCaml and Dune)

### Installing OCaml and Dune (with opam)

If you don’t have OCaml or Dune:

```bash
# Install opam (see https://opam.ocaml.org/doc/Install.html)
# Then:
opam init
eval $(opam env)
opam install dune
```

---

## Installation

Clone the repository and build the project. There is no separate “install” step unless you want to install the opam package.

### Build only (no install)

```bash
git clone <repository-url>
cd system-e-kernel
dune build
```

This compiles the library, the `system-e-kernel` executable, and the test executable.

### Install as an opam package (optional)

From the project root:

```bash
opam install .
```

This builds and installs the `system-e-kernel` library and the `system-e-kernel` executable so you can use them from other opam projects or run `system-e-kernel` from your PATH if the package installs the binary.

---

## Running

### Run the main executable (demo)

After `dune build`:

```bash
dune exec system-e-kernel
```

**Expected output:** A sequence of lines showing that type inference works for constants, free variables, and bound variables (stack), plus expected failure cases, ending with:

```
Const "Point" -> Sort 0: OK
Fvar "p" -> Point: OK
Bvar 0 in [Point] -> Point: OK
Bvar 1 in [Line; Point] -> Point: OK
Fvar "q" (missing) -> expected failure: OK
Bvar 0 in [] -> expected failure: OK

All checks passed.
```

### Run the test suite

```bash
dune runtest
```

If you want to see the test binary’s output:

```bash
dune exec test/test_system_e_kernel.exe
```

**Expected:** Exit code 0 and the line `All inferType tests passed.`

### Build and run everything in one go

```bash
dune build && dune exec system-e-kernel && dune exec test/test_system_e_kernel.exe
```

---

## Quick reference: Dune commands

| Command | Description |
|--------|-------------|
| `dune build` | Build the library, main executable, and tests |
| `dune exec system-e-kernel` | Run the main demo executable |
| `dune runtest` | Run the test suite (may not show stdout; check exit code) |
| `dune exec test/test_system_e_kernel.exe` | Run the test binary and see its output |
| `dune clean` | Remove build artifacts |
| `opam install .` | Build and install the package via opam (optional) |

---
