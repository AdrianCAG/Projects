//
//  main.cpp
//    ...
//
//  Created by Adrian on 10/21/24.
//



#include <iostream>
#include <cmath>
#include <map>
#include <string>
#include <functional>
#include <vector>
#include <stdexcept>




class Obj {
public:
    // Retrieve field value
    double getField(const std::string& field) {
        if (fields.find(field) != fields.end()) {
            return fields[field];
        }
        throw std::runtime_error("Field not found: " + field);
    }

    // Set field value
    void setField(const std::string& field, double value) {
        if (fields.find(field) != fields.end()) {
            fields[field] = value;
        } else {
            throw std::runtime_error("Field not found: " + field);
        }
    }

    // Send a message to an object, invoking a method
    double send(const std::string& msg, const std::vector<double>& args) {
        if (methods.find(msg) != methods.end()) {
            return methods[msg](args);
        } else {
            throw std::runtime_error("Method not found: " + msg);
        }
    }
    
    std::map<std::string, double> fields;                                      // Stores field values
    std::map<std::string, std::function<double(std::vector<double>)>> methods; // Method map
};



// Function to create a Point object
Obj makePoint(double x, double y) {
    Obj obj;
    
    // Fields
    obj.fields["x"] = x;
    obj.fields["y"] = y;
    
    // Methods
    obj.methods["getX"] = [&obj](const std::vector<double>& args) {
        return obj.getField("x");
    };
    obj.methods["getY"] = [&obj](const std::vector<double>& args) {
        return obj.getField("y");
    };
    obj.methods["setX"] = [&obj](const std::vector<double>& args) {
        obj.setField("x", args[0]);
        return 0;
    };
    obj.methods["setY"] = [&obj](const std::vector<double>& args) {
        obj.setField("y", args[0]);
        return 0;
    };
    obj.methods["distToOrigin"] = [&obj](const std::vector<double>& args) {
        double a = obj.send("getX", {});
        double b =  obj.send("getY", {});
        return std::sqrt(a * a + b * b);
    };
    
    return obj;
}


void exampleMakePoint() { // ---------------------------------------------------------
    Obj point = makePoint(4, 0);
    
    // 4
    std::cout << point.send("getX", {}) << std::endl;
    // 0
    std::cout << point.send("getY", {}) << std::endl;
    // 4
    std::cout << point.send("distToOrigin", {}) << std::endl;
    point.send("setY", {3});
    
    // 5
    std::cout << point.send("distToOrigin", {}) << std::endl;
    
    std::cout << std::endl;
} // ----------------------------------------------------------------------------------



// Function to create a ColorPoint object
Obj makeColorPoint(double x, double y, const std::string& color) {
    // Inherits from Point
    Obj obj = makePoint(x, y);

    // Add color field
    obj.fields["color"] = std::stod(color); // Assuming color is a numeric value for simplicity

    // Add color methods
    obj.methods["getColor"] = [&obj](const std::vector<double>& args) {
        return obj.getField("color");
    };
    obj.methods["setColor"] = [&obj](const std::vector<double>& args) {
        obj.setField("color", args[0]);
        return 0;
    };

    return obj;
}



void exampleMakeColorPoint() { // -----------------------------------------------------
    Obj colorPoint = makeColorPoint(-4, 0, "255 0 0");
    
    // -4
    std::cout << colorPoint.send("getX", {}) << std::endl;
    // 0
    std::cout << colorPoint.send("getY", {}) << std::endl;
    // 255
    std::cout << colorPoint.send("getColor", {}) << std::endl;
    // 4
    std::cout << colorPoint.send("distToOrigin", {}) << std::endl;
    colorPoint.send("setY", {3});
    
    // 3
    std::cout << colorPoint.send("getY", {}) << std::endl;
    // 5
    std::cout << colorPoint.send("distToOrigin", {}) << std::endl;
    
    std::cout << std::endl;
 } // ----------------------------------------------------------------------------------



// Function to create a PolarPoint objecte2
Obj makePolarPoint(double r, double theta) {
    // Inherits from Point
    Obj obj = makePoint(0, 0);
    
    // Fields
    obj.fields["r"] = r;
    obj.fields["theta"] = theta;
    
    // Methods
    obj.methods["setRTheta"] = [&obj](const std::vector<double>& args) {
        obj.setField("r", args[0]);
        obj.setField("theta", args[1]);
        return 0;
    };
    obj.methods["getX"] = [&obj](const std::vector<double>& args) {
         double r = obj.getField("r");
         double theta = obj.getField("theta");
         return r * std::cos(theta);
     };
    obj.methods["getY"] = [&obj](const std::vector<double>& args) {
        double r = obj.getField("r");
        double theta = obj.getField("theta");
        return r * std::sin(theta);
    };
    obj.methods["setX"] = [&obj](const std::vector<double>& args) {
        double x = args[0];
        double y = obj.send("getY", {});
        double theta = std::atan2(y, x);
        double r = std::sqrt(x * x + y * y);
        obj.send("setRTheta", {r, theta});
        return 0;
    };
    obj.methods["setY"] = [&obj](const std::vector<double>& args) {
        double y = args[0];
        double x = obj.send("getX", {});
        double theta = std::atan2(y, x);
        double r = std::sqrt(x * x + y * y);
        obj.send("setRTheta", {r, theta});
        return 0;
    };
    
    return obj;
}



void exampleMakePolarPoint() { // ----------------------------------------------------
    Obj polarPoint = makePolarPoint(4, 3.1415926535);
    
    // -4
    std::cout << polarPoint.send("getX", {}) << std::endl;
    // 3.59173e-10
    std::cout << polarPoint.send("getY", {}) << std::endl;
    // 4
    std::cout << polarPoint.send("distToOrigin", {}) << std::endl;
    polarPoint.send("setY", {3});

    // 3
    std::cout << polarPoint.send("getY", {}) << std::endl;
    // 5
    std::cout << polarPoint.send("distToOrigin", {}) << std::endl;
} // ----------------------------------------------------------------------------------







int main() {
    
    exampleMakePoint();
    
    exampleMakeColorPoint();
    
    exampleMakePolarPoint();
    
    return 0;
}
