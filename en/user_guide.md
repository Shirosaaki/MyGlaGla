# 📖 User Guide

Welcome to the GLADOS User Guide! This document provides an overview of the features and functionalities of GLADOS, a powerful compilator for the TSL (TheShowLang). Whether you're a beginner or an experienced user, this guide will help you get started and make the most out of GLADOS.

## ✨ Features

GLADOS offers the following features:
- **🟩 TSL Compilator**: Compile TSL code, a simple programming language that supports variable assignments, arithmetic operations, and basic control structures.
- **▶️ Interactive REPL**: Experiment with TSL code in an interactive Read-Eval-Print Loop (REPL) environment.
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
3. **▶️ Running the Compilator**: You can run the compilator with a TSL file as input:
    ```bash
    ./glados
    ```
    or
    ```bash
    ./glados < path_to_your_file.tsl
    ```

## ✍️ Writing Code

The project can be used in two ways: through the interactive console or by writing TSL code in files.
### 1. **Interactive Console**
Launch the interactive console by running `./glados` without any arguments. You can type TSL code directly into the console, and it will be evaluated immediately.

To write multi-line code, type `:code` to enter code mode, and `:end` to exit code mode and evaluate the code.

### 2. **TSL Code Files**
You can write TSL code in files with a `.tsl` extension and run them using the compilator.

Here are some basic examples of TSL code to get you started:
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

## 🎨 Error Output Configuration

GLADOS can customize how errors are printed (prefix, color, bold/underline), using a YAML config file.

### 1) Create a config file

Create a file named `glados.config.yaml` at the project root.
You can also use `GLADOS_CONFIG=/path/to/config.yaml` to point to another file.

Example:

```yaml
output_mode: console   # console | html

error:
    prefix: "*** ERROR: "
    color: "#FF8500"    # name (red/green/...) or hex (#RRGGBB)
    bold: true
    underline: false

html:
    font_family: "DejaVu Sans Mono, monospace"
    font_size: "18px"
    path: "glados_error.html"
```

### 2) Console mode (recommended)

- `error.color` supports **hex** colors (`#RRGGBB`). This uses truecolor ANSI escapes so the color is correct even if your terminal theme remaps basic ANSI colors.

### 3) HTML mode

If `output_mode: html`:

- GLADOS generates/overwrites `html.path` **once per run** (so past errors do not accumulate).
- GLADOS tries to auto-open the HTML file in your default browser (Linux: `xdg-open`).

For more detailed information on the TSL language syntax and features, please refer to the [TSL Language Reference](./tsl_language_reference.md). If you have any questions or need further assistance, feel free to reach out to the GLADOS community or check the project's GitHub repository for issues and discussions.

## ✅ Conclusion

We hope this User Guide helps you get started with GLADOS. Enjoy coding with LISP and TSL! 🎉
