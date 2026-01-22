# Contributing to GLADOS

Thank you for your interest in contributing to GLADOS! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

---

## Code of Conduct

### Our Standards

- **Be respectful**: Treat everyone with respect and kindness
- **Be constructive**: Provide helpful feedback and suggestions
- **Be collaborative**: Work together to improve the project
- **Be inclusive**: Welcome contributors of all skill levels

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling, insulting, or derogatory remarks
- Publishing others' private information
- Any conduct that would be inappropriate in a professional setting

---

## Getting Started

### Prerequisites

1. **Install required tools**:
   - Git
   - GHC (Glasgow Haskell Compiler) >= 8.10
   - Stack (Haskell build tool)
   - Make

2. **Fork the repository** on GitHub

3. **Clone your fork**:
   ```bash
   git clone git@github.com:YOUR_USERNAME/GlaGla.git
   cd GlaGla
   ```

4. **Add upstream remote**:
   ```bash
   git remote add upstream git@github.com:LaTableSurGit/GlaGla.git
   ```

5. **Install dependencies**:
   ```bash
   stack setup
   stack build
   ```

### Familiarize Yourself

- Read the [Technical Documentation](TECHNICAL.md)
- Browse the [User Guide](user_guide.md)
- Check [existing issues](https://github.com/LaTableSurGit/GlaGla/issues)
- Run the example programs in `examples/`

---

## Development Workflow

### 1. Create a Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions/improvements

### 2. Make Your Changes

- Write clean, readable code
- Follow the [coding standards](#coding-standards)
- Add comments for complex logic
- Update documentation as needed

### 3. Test Your Changes

```bash
# Run tests
make run_test

# Run style checker
./tools/tsl_style_checker.sh

# Test manually
./glados < examples/example1.tslang
```

### 4. Commit Your Changes

Follow the [commit guidelines](#commit-guidelines):

```bash
git add .
git commit -m "feat: add new feature description"
```

### 5. Keep Your Branch Updated

```bash
# Fetch upstream changes
git fetch upstream

# Rebase on upstream main
git rebase upstream/main

# Or merge if you prefer
git merge upstream/main
```

### 6. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Coding Standards

### Haskell Code Style

#### Naming Conventions

```haskell
-- Functions and variables: camelCase
parseExpression :: String -> Maybe Ast
currentValue :: Int

-- Types and constructors: PascalCase
data ExpressionType = IntType | BoolType
newtype Environment = Environment (Map String Value)

-- Constants: camelCase or UPPER_CASE for truly constant values
maxIterations :: Int
maxIterations = 1000
```

#### Formatting

```haskell
-- 4 spaces for indentation (no tabs)
myFunction :: Int -> String -> IO ()
myFunction count message = do
    putStrLn message
    if count > 0
        then do
            myFunction (count - 1) message
        else
            return ()

-- Line length: try to keep under 80 characters
-- Break long function signatures
longFunctionName 
    :: VeryLongTypeName 
    -> AnotherLongType 
    -> Maybe Result

-- Align list elements
myList = 
    [ element1
    , element2
    , element3
    ]

-- Use qualified imports for common modules
import qualified Data.Map as Map
import qualified Data.Set as Set
```

#### Documentation

```haskell
-- | Brief one-line description
--
-- Longer description with more details.
-- Can span multiple lines.
--
-- Arguments:
-- * First argument description
-- * Second argument description
--
-- Example:
-- >>> calculateSum [1, 2, 3]
-- 6
calculateSum :: [Int] -> Int
calculateSum = sum
```

#### Best Practices

```haskell
-- Use explicit type signatures
goodFunction :: Int -> String
goodFunction x = show x

-- Avoid partial functions when possible
safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

-- Use pattern matching
processResult :: Either String Int -> String
processResult (Left err) = "Error: " ++ err
processResult (Right val) = "Success: " ++ show val

-- Use let/where for readability
complexCalculation :: Int -> Int
complexCalculation x = result
  where
    intermediate = x * 2
    result = intermediate + 10

-- Prefer pure functions
-- Good: pure function
double :: Int -> Int
double x = x * 2

-- Avoid when possible: impure function with side effects
badPrintDouble :: Int -> IO Int
badPrintDouble x = do
    let result = x * 2
    print result  -- Side effect
    return result
```

### Module Structure

```haskell
{-
-- EPITECH PROJECT, 2025
-- Module Name
-- File description:
-- Description of what this module does
-}

-- Module declaration with exports
module ModuleName (
    -- * Types
    MyType(..),
    OtherType,
    
    -- * Functions
    mainFunction,
    helperFunction
) where

-- Imports grouped and sorted
import Control.Monad (when, unless)
import Data.Maybe (fromMaybe)
import qualified Data.Map as Map

-- Type definitions
data MyType = Constructor1 | Constructor2

-- Function implementations
mainFunction :: Int -> String
mainFunction = undefined
```

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc
- `refactor`: Code restructuring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Simple feature
git commit -m "feat(parser): add support for hexadecimal literals"

# Bug fix with body
git commit -m "fix(vm): correct stack overflow in recursive calls

The call stack wasn't being properly managed when handling
deeply nested function calls. Added proper bounds checking."

# Breaking change
git commit -m "feat(ast)!: change function definition syntax

BREAKING CHANGE: Function definitions now require explicit
return type annotations."
```

### Commit Best Practices

- **Keep commits atomic**: One logical change per commit
- **Write clear messages**: Explain what and why, not how
- **Reference issues**: Include `#issue-number` in commit message
- **Test before committing**: Ensure code compiles and tests pass

---

## Pull Request Process

### Before Submitting

- [ ] Code compiles without errors
- [ ] All tests pass (`make run_test`)
- [ ] Style checker passes (`./tools/tsl_style_checker.sh`)
- [ ] Documentation updated (if applicable)
- [ ] Examples updated (if adding new features)
- [ ] Commit messages follow guidelines

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- List specific changes
- Be detailed but concise

## Testing
- Describe how you tested
- Include test cases added

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Fixes #123
Relates to #456

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass
- [ ] No new warnings
```

### Review Process

1. **Automated checks**: CI/CD runs tests and style checks
2. **Code review**: Maintainers review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged

### Addressing Feedback

- Be responsive to comments
- Make requested changes in new commits
- Re-request review after changes
- Be open to suggestions and discussion

---

## Issue Reporting

### Before Creating an Issue

1. **Search existing issues**: Your issue might already exist
2. **Check documentation**: The answer might be in the docs
3. **Reproduce the bug**: Ensure it's consistent

### Bug Report Template

```markdown
## Bug Description
Clear and concise description of the bug

## To Reproduce
Steps to reproduce:
1. Run command '...'
2. Input '...'
3. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Environment
- OS: [e.g., Ubuntu 22.04]
- GHC version: [e.g., 9.0.2]
- Stack version: [e.g., 2.7.5]
- GLADOS version: [e.g., 0.4.1.0]

## Additional Context
- Error messages
- Stack traces
- Screenshots
- Related issues
```

### Feature Request Template

```markdown
## Feature Description
Clear description of the feature

## Motivation
Why is this feature needed?
What problem does it solve?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

---

## Areas Needing Contribution

### High Priority

- **LLVM Backend**: Complete the compiler backend
- **Type System**: Improve type inference
- **Error Messages**: Better error reporting
- **Standard Library**: Add built-in functions
- **Documentation**: API docs with Haddock

### Good First Issues

Look for issues labeled `good-first-issue`:
- Documentation improvements
- Example programs
- Test coverage
- Code comments
- Style fixes

### Advanced Contributions

For experienced contributors:
- VM optimization
- Garbage collection
- JIT compilation
- Language server protocol (LSP)
- Debugger implementation

---

## Questions?

- **GitHub Issues**: For bugs and features
- **GitHub Discussions**: For questions and ideas
- **Pull Requests**: For code contributions

## Recognition

Contributors will be acknowledged in:
- CHANGELOG.md
- Project README
- Release notes

Thank you for contributing to GLADOS! 🚀
