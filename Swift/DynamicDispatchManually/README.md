# Dynamic Dispatch in Swift
This project demonstrates the concept of dynamic dispatch in object-oriented programming and compares it to a manual approach implemented using functions. The project is structured into three files:

- DynamicDispatch.swift: Implements dynamic dispatch using classes and inheritance in Swift.
- DynamicDispatchManually.swift: Mimics dynamic dispatch manually using structs and function tables.
- DynamicDispatchTest.swift: A test file to compare both implementations.

## Project Structure
### 1. DynamicDispatch.swift

This file defines three classes: Point, ColorPoint, and PolarPoint, illustrating how Swift performs dynamic dispatch via inheritance and method overriding.

- Point: Represents a point with x and y coordinates and methods to get/set these values.
- ColorPoint: Inherits from Point, adding color information.
- PolarPoint: Inherits from Point, but uses polar coordinates (r, theta) instead of x, y, overriding the    appropriate methods.

Example usage of the Point class:
```swift
let p = Point(3.0, 4.0)
print(p.distFromOrigin()) // Outputs the distance from origin
```

### 2. DynamicDispatchManually.swift
In this file, dynamic dispatch is manually simulated by creating a struct Obj that holds fields and method tables, using function calls to access and modify values.

Key functions:

- get: Retrieves field values.
- set: Modifies field values.
- send: Dynamically invokes methods based on message names.

Example manual dispatch usage:
```swift
var p = makePoint(3.0, 4.0)
print(send(&p, "distToOrigin")) // Manually calls the distToOrigin method
```

### 3. DynamicDispatchTest.swift
This file contains test cases to compare the two approaches. It demonstrates how Swift’s built-in dynamic dispatch compares to a more manual function dispatch system.


## How to Run
1. Clone the project to your local machine.
2. Open the project in Xcode.
3. Run the DynamicDispatchTest target to execute the tests and observe the behavior of dynamic dispatch in both implementations.


## Conclusion
This project highlights the difference between built-in dynamic dispatch in Swift’s object-oriented system and a manual approach that mimics this behavior using function tables. It serves as a learning tool to better understand method resolution and dispatch mechanisms in Swift.

## License
This project is licensed under the MIT License. See the [MIT License](LICENSE) file for details.