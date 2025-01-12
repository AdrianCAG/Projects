# Geometric Expressions Interpreter

## Overview

This project implements a **geometric expressions interpreter** that leverages **functional programming**, **pattern matching**, and **object-oriented programming (OOP)** concepts like **dynamic dispatch** and **double dispatch** to evaluate and manipulate geometric expressions.

## Features

- **Functional Design**: Implements immutability and concise functions for evaluating and manipulating expressions.
- **Pattern Matching**: Used extensively to handle various cases in geometric expression evaluation.
- **Dynamic Dispatch**: Provides polymorphism for operations like `intersect` and `shift`.
- **Double Dispatch**: Handles complex interactions between different geometric types (e.g., lines, points, segments).

## Supported Geometric Expressions

The interpreter supports a range of geometric expressions defined using the `geomExp` enum:

- `NoPoints`: Represents no valid points.
- `Point(x, y)`: A single point in 2D space.
- `Line(m, b)`: A line with slope `m` and y-intercept `b`.
- `VerticalLine(x)`: A vertical line at `x`.
- `LineSegment(x1, y1, x2, y2)`: A line segment between two points.
- `Intersect(e1, e2)`: Represents the intersection of two geometric expressions.
- `Let(var, expr1, expr2)`: Binds `var` to `expr1` for use in `expr2`.
- `Var(name)`: Represents a variable.
- `Shift(deltaX, deltaY, expr)`: Shifts an expression by the given x and y deltas.

## Key Concepts

### Functional Programming

- Uses immutability and pure functions for expression evaluation.
- Helper functions like `realClose` and `realClosePoint` enable approximate comparison of floating-point numbers.

### Pattern Matching

- Simplifies the evaluation of geometric expressions using Swift's `switch` statements.
- Handles up to 25 cases in the `intersect` function, covering all combinations of geometric entities.

### Dynamic Dispatch

- Each class (e.g., Point, Line, VerticalLine, LineSegment) inherits from GeometryValue and overrides the intersect method.
- When intersect is called on an instance of GeometryValue, the implementation executed depends on the runtime type of the object.

### Double Dispatch

- Ensures precise handling of interactions between geometric types, e.g., intersection of two `LineSegment`s.


## Contributing
Contributions are welcome! Please submit a pull request or open an issue to suggest improvements or report bugs.

## License
This project is licensed under the MIT License. See the [MIT License](LICENSE) file for details.