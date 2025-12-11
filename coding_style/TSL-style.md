---
autor: shirosaaki
title: "The TSL Coding Style Guide"
slug: TSL-style
description: "Best practices and conventions for writing clean, maintainable TSL code."
---

# 📚 TSL Coding Style Guide

## 🎯 Documentation Goals
This guide outlines the recommended coding style for TSL (The Scripting Language) to ensure code is clean, consistent, and maintainable. Following these conventions will help developers read and understand TSL code more easily.

## 📝 Naming Conventions

- **Variables and Functions**: Use `camelCase` for variable and function names (e.g., `myVariable`, `calculateSum`).
- **Types**: Use `PascalCase` for type names (e.g., `UserProfile`, `DataPoint`).

## 📏 Formatting Guidelines

- **Indentation**: Use 4 spaces per indentation level. Avoid tabs.
- **Line Length**: Limit lines to 80 characters for better readability.
- **Braces**: Place opening braces on the same line as the control statement or function declaration.
- **Spacing**: Use a single space after commas and around operators (e.g., `=`, `+`, `-`, `->`).
- **Blank Lines**: Use blank lines to separate logical sections of code, such as between functions or major blocks.

## 🔤 Commenting Standards

- **Function Comments**: Use comments to describe the purpose of functions, their parameters, and return values.
- **Inline Comments**: Use sparingly to explain complex logic, but avoid obvious comments.
- **Documentation Comments**: Use `desnote` for multi-line comments that explain larger sections of code.

## 🛠️ Code Structure

- **Function Length**: Keep functions short and focused on a single task. Aim for no more than 20 lines.
- **Modularity**: Break code into smaller, reusable functions where appropriate.
- **Error Handling**: Use clear and consistent error handling strategies.

## File Organization

- **File Naming**: Use lowercase with hyphens for file names (e.g., `user-profile.tsl`).
- **File Header**: Include a brief description of the file's purpose at the top.
- **File Ending**: Ensure files end with a newline character.

## 📚 Example Code (bad practice to good practice)

```tsl
desnote Bad Practice Example
Deschodt badExample(a -> int,b -> int)->int
    eric  result=0->int
    erif(a>0):
        result=a+b
	deschelse:
		result=a-b
	deschodt result
```

```tsl
desnote ==============================================
desnote                 example.tslang
desnote  Author: shirosaaki
desnote  Date: 2025-12-11
desnote =============================================
desnote Good Practice Example
Deschodt goodExample(a -> int, b -> int) -> int
    eric result = 0 -> int
    erif (a > 0):
        result = a + b
    deschelse:
        result = a - b
    deschodt result
```

## 🚀 Next Steps

Happy coding!