//
//  DynamicDispatch.swift
//  DynamicDispatchTest
//
//  Created by Adrian Ghita on 9/28/24.
//

import Foundation




class Point {
    private var x: Double
    private var y: Double
    
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    func getX() -> Double {
        return self.x
    }
    
    func setX(_ newX: Double){
        self.x = newX
    }
    
    func getY() -> Double {
        return self.y
    }
    
    func setY(_ newY: Double){
        self.y = newY
    }
    
    func distFromOrigin() -> Double{
        return sqrt(getX() * getX() + getY() * getY())
    }
    
    func distFromOrigin2() -> Double {
        return sqrt(self.x * self.x + self.y * self.y)
    }
}

class ColorPoint: Point {
    private var color: String
    
    init(_ x: Double, _ y: Double, _ c: String="clear") {
        self.color = c
        super.init(x, y)
    }
    
    func getColor() -> String {
        return self.color
    }
    
    func setColor(_ newColor: String) {
        self.color = newColor
    }
}

class PolarPoint: Point {
    private var r: Double
    private var theta: Double
    
    override init(_ r: Double, _ theta: Double) {
        self.r = r
        self.theta = theta
        super.init(0, 0)  // Call to super, but unused x and y fields
    }
    
    override func getX() -> Double {
        return self.r * cos(theta)
    }
    
    override func setX(_ newValue: Double){
        let b = getY()
        self.theta = atan2(b, newValue)
        self.r = sqrt(newValue * newValue + b * b)
    }
    
    override func getY() -> Double {
        return self.r * sin(self.theta)
    }
    
    override func setY(_ newValue: Double){
        let a = getX()
        self.theta = atan2(newValue, a)
        self.r = sqrt(a * a + newValue * newValue)
    }
    
    func setRTheta(_ r: Double, _ theta: Double) {
        self.r = r
        self.theta = theta
    }
    
    // Method from parrent class uses instance vars/filds that this class does not use
    // override func distFromOrigin2() -> Double {  // must override since inherited method does wrong thing
    //     return self.r
    // }
    
    // inherited distFromOrigin already works!!
}


// E.g:
// let example = PolarPoint(4, 3.141592/4)
// 4.0
// print(example.distFromOrigin())
// 0.0
// print(example.distFromOrigin2())


