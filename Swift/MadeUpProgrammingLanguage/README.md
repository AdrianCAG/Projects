# Made Up Programming Language (MUPL) in Swift

Welcome to the Made Up Programming Language (MUPL), a simple interpreted language implemented in Swift. This project provides an interpreter for MUPL, along with examples and usage instructions.

## Table of Contents
- [Overview](#overview)
- [MUPL Syntax](#mupl-syntax)
- [Interpreter Overview](#interpreter-overview)
- [Usage Examples](#usage-examples)
- [Conclusion](#conclusion)
- [License](#license)

## Overview
MUPL is a minimalist language that includes basic constructs such as variables, integers, functions, conditionals, pairs, and more. The purpose of MUPL is to explore the design and implementation of interpreters, with a focus on recursive functions and closures.

## MUPL Syntax
MUPL supports the following expressions:

- Variables: vaar("x")
- Integers: int(42)
- Addition: addE(e1, e2)
- Conditionals: ifgreater(e1, e2, e3, e4) (if e1 > e2 then e3 else e4)
- Functions: fun(nameopt, formal, body)
- Function Calls: call(funexp, actual)
- Let Bindings: mlet(var, e, body)
- Pairs: apair(e1, e2)
- First of Pair: fst(e)
- Second of Pair: snd(e)
- Unit Value: aunit()
- Check if Unit: isaunit(e)

## Interpreter Overview
The MUPL interpreter is implemented in Swift. It evaluates MUPL expressions by recursively traversing the abstract syntax tree (AST) and applying the appropriate operations.

The interpreter supports:
- Variable Lookup: Resolves variables from the environment.
- Function Closures: Implements closures by capturing the environment at the time of function definition.
- Pair Operations: Supports pairing and unpairing values.
- Conditional Expressions: Evaluates expressions based on comparison results.

## Usage Examples

### Example 1: Basic Arithmetic
```swift
let expr = addE(int(5), int(7))
print(evalExp(expr)) // Outputs: int(12)
```

### Example 2: Conditional Expression
```swift
let expr = ifgreater(int(10), int(5), int(1), int(0))
print(evalExp(expr)) // Outputs: int(1)
```

### Example 3: Function Definition and Application
```swift
let expr = call(
    fun("#f", "x", addE(vaar("x"), int(10))),
    int(5)
)
print(evalExp(expr)) // Outputs: int(15)
```

### Example 4: Let Binding
```swift
let expr = mlet("x", int(42), addE(vaar("x"), int(8)))
print(evalExp(expr)) // Outputs: int(50)
```

### Example 5: Pair Operations
```swift
let expr = fst(apair(int(1), int(2)))
print(evalExp(expr)) // Outputs: int(1)
```

## Example 6: Functions
```swift
let function = closure([], fun("hello", "x", addE(vaar("x"), int(7))))
let expr = call(function, int(1))
print(evalExp(expr)) // Outputs: int(8)

```

### Conclusion
MUPL is a simple yet powerful language that demonstrates key concepts in interpreter design, such as environment handling, closures, and recursive function evaluation. Experiment with different MUPL expressions to deepen your understanding of these concepts. Happy coding!

## License
This project is licensed under the MIT License. See the [MIT License](LICENSE) file for details.
