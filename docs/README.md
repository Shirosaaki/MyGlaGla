# GLADOS

## Description

A compilator of this own programming language. Us will call it TheShowLang (TSL). TSL is a simple language that supports variable assignments, arithmetic operations, and basic control structures.

All code is written in Haskell.

## Installation

To install the project, ensure you have [Stack](https://docs.haskellstack.org/en/stable/README/) installed. Then, clone the repository and navigate to the project directory:

```bash
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla
stack setup
```
## Building the project

To build the project, run the following command in the project directory:

```bash
make build
```

To clean the build artifacts, use the following command:

```bash
make clean
```

To clean all artifacts including dependencies, use the following command:

```bash
make fclean
```

## Running the Compilator

To run the compilator, use the following command:
```bash
./glados < <path_to_input_file>
```
or
```bash
./glados
```
to enter the interactive console.

## Unit tests

To run the unit tests, use the following command:
```bash
make run_test
```

To run the unit tests with coverage report, use the following command:
```bash
make test_coverage
```
