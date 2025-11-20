# 📖 User Guide

Welcome to the GLADOS User Guide! This document provides an overview of the features and functionalities of GLADOS, a powerful interpreter for the LISP / TSL (TheShowLang). Whether you're a beginner or an experienced user, this guide will help you get started and make the most out of GLADOS.

## ✨ Features

GLADOS offers the following features:
- **🟦 LISP Interpreter**: Execute LISP code with support for arithmetic operations, list manipulations, and function definitions.
- **🟩 TSL Interpreter**: Run TSL code, a simple programming language that supports variable assignments, arithmetic operations, and basic control structures.
- **▶️ Interactive REPL**: Experiment with LISP and TSL code in an interactive Read-Eval-Print Loop (REPL) environment.
- **⚠️ Error Handling**: Get informative error messages to help you debug your code.

## 🚀 Getting Started

To get started with GLADOS, follow these steps:
1. **⬇️ Installation**: Ensure you have [Stack](https://docs.haskellstack.org/en/stable/README/) installed. Clone the GLADOS repository and navigate to the project directory:
    ```bash
    git clone https://github.com/LaTableSurGit/GlaGla.git
    cd GlaGla
    stack setup
    ```
2. **⚒️ Building the Project**: Build GLADOS using the following command:
    ```bash
    make
    ```
3. **▶️ Running the Interpreter**: You can run the interpreter with a LISP or TSL file as input:
    ```bash
    ./glados < path_to_your_file.lisp
    ```
    or
    ```bash
    ./glados < path_to_your_file.tsl
    ```

## ✍️ Writing Code

Here are some basic examples of LISP and TSL code to get you started:
### 🧠 LISP Example
```lisp
(define (factorial n)
  (if (eq? n 1)
      1
      (* n (factorial (- n 1)))))
(factorial 5) ; Returns 120
```

### 🧩 TSL Example
```tsl
Deschodt factoriel(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factoriel(n - 1)

Deschodt Eric() -> int
    eric val = 5
    peric("factoriel({val}) = {factoriel(val)}")
    deschodt 0

desnote print factoriel(5) = 120
```

## 📚 Additional Resources

For more detailed information on the TSL language syntax and features, please refer to the [TSL Language Reference](./tsl_language_reference.md). If you have any questions or need further assistance, feel free to reach out to the GLADOS community or check the project's GitHub repository for issues and discussions.

## ✅ Conclusion

We hope this User Guide helps you get started with GLADOS. Enjoy coding with LISP and TSL! 🎉
