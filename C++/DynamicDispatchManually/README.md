# Dynamic Dispatch in C++
This project demonstrates the concept of dynamic dispatch in object-oriented programming in C++ and compares it to a manual approach using function tables and structs. The project is structured into three key object types:

- Point: Represents a simple 2D point with x and y coordinates.
- ColorPoint: Extends Point with a color field.
- PolarPoint: Extends Point but uses polar coordinates (r, theta) instead of Cartesian coordinates.

## Project Structure
### 1. main.cpp

This file contains all of the following object types and functions:

- Obj Class: A generalized class that mimics dynamic dispatch manually. It holds fields and function tables (method maps) to dynamically invoke methods using the send function.
- makePoint: Function to create a Point object with x and y fields and methods for interacting with them (getters, setters, and a method for calculating the distance to the origin).
- makeColorPoint: Extends the Point functionality by adding a color field and associated methods for getting and setting the color.
- makePolarPoint: Extends Point by converting Cartesian coordinates into polar coordinates (r, theta), with methods to calculate x, y based on these values.

### 2. Manual Dispatch Mechanism
In this project, dynamic dispatch is manually simulated using the Obj class. This class holds fields (for storing object state) and methods (as function pointers) in maps. Methods are invoked dynamically via the send function, which takes a message (method name) and arguments to call the appropriate method.

Key Functions
- getField: Retrieves a field's value by name.
- setField: Modifies a field's value by name.
- send: Invokes a method dynamically by its name (as a message) and passes in arguments.

Example manual dispatch usage:
```cpp
Obj point = makePoint(3.0, 4.0);
std::cout << point.send("distToOrigin", {});  // Manually calls the distToOrigin method (5.0)
```

### 3. Extending Point
Both ColorPoint and PolarPoint build on the Point object by adding fields and methods:

- ColorPoint: Adds a color field and methods for getting and setting color.
- PolarPoint: Converts polar coordinates (r, theta) into x and y values dynamically and provides methods for working with polar geometry.

Example usage of the ColorPoint object:
```cpp
Obj colorPoint = makeColorPoint(3.0, 4.0, "255 0 0");
std::cout << colorPoint.send("getColor", {});  // Outputs the color value
```

### 4. Testing
Each object type (Point, ColorPoint, PolarPoint) is tested in the main function, showcasing their functionality, including dynamic method dispatch and field manipulation.

## How to Run
1. Clone the project to your local machine.
2. Open the project in your C++ IDE or compile it using a terminal command:
```bash
g++ -std=c++11 main.cpp -o dynamic_dispatch
./dynamic_dispatch
```

## Conclusion
This project highlights the difference between dynamic dispatch in object-oriented systems (like inheritance in C++) and a manual approach that mimics dynamic behavior using function maps. It serves as a learning tool to better understand method resolution, function pointers, and dispatch mechanisms in C++.

## License
This project is licensed under the MIT License. See the [MIT License](LICENSE) file for details.