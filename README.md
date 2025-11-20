# glados

## Description

The glados project is a LISP interpreter written in Haskell. It supports basic LISP functionalities including arithmetic operations, list manipulations, and function definitions.

## Unit tests

To run the unit tests, use the following command:

```bash
make run_test
```

To run the unit tests with coverage report, use the following command:

```bash
make test_coverage
REPORT=$(find .stack-work -name hpc_index.html -print -quit)
[ -n "$REPORT" ] && xdg-open "$REPORT" || echo "hpc_index.html not found; run 'stack test --coverage' first"
hpc_index.html not found; run 'stack test --coverage' first
```
