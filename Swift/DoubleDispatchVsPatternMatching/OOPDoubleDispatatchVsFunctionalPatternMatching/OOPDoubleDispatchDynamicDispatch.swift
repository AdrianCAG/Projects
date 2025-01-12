//
//  OOPDoubleDispatchDynamicDispatch.swift
//  OOPFunctionalTest
//
//  Created by Adrian on 1/12/25.
//

import Foundation






// This code is done in a way to accomodate some tests.


struct Constants {
    static let epsilon: Float = 0.00001
}

typealias Environment = [(String, GeometryValue)]


protocol GeometryExpression: Equatable {
    func preprocessProg()             -> any GeometryExpression
    func evalProg(_ env: Environment) -> GeometryValue
}

extension GeometryExpression {
    static func == (lhs: Self, rhs: Self) -> Bool {
        // Base class comparison should be handled by subclasses
        return type(of: lhs) == type(of: rhs)
    }
}


protocol Geometry: GeometryExpression {
    func shift(_ dx: Float, _ dy: Float)                      -> GeometryValue
    func intersect(_ other: GeometryValue)                    -> GeometryValue
    func intersectPoint(_ p: Point)                           -> GeometryValue
    func intersectLine(_ line: Line)                          -> GeometryValue
    func intersectVerticalLine(_ vline: VerticalLine)         -> GeometryValue
    func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue
    
}


class GeometryValue: Geometry {
    private func realClose(_ r1: Float, _ r2: Float) -> Bool {
        return abs(r1 - r2) < Constants.epsilon
    }
    
    private func realClosePoint(_ p1: (Float, Float), _ p2: (Float, Float)) -> Bool {
        return realClose(p1.0, p2.0) && realClose(p1.1, p2.1)
    }
    
    private func twoPointsToLine(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) -> GeometryValue {
        if realClose(x1, x2) {
            return VerticalLine(x1)
        } else {
            let m = (y2 - y1) / (x2 - x1)
            let b = y1 - m * x1
            return Line(m, b)
        }
    }
    
    // Unfortunatelly could not be added to Geometry extension
    func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        fatalError("Subclasses must implement shift")
    }
    
    func intersect(_ other: GeometryValue) -> GeometryValue {
        fatalError("Subclasses must implement intersect")
    }
    
    func intersectPoint(_ p: Point) -> GeometryValue {
        fatalError("Subclasses must implement intersectPoint")
    }
    
    func intersectLine(_ line: Line) -> GeometryValue {
        fatalError("Subclasses must implement intersectLine")
    }
    
    func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        fatalError("Subclasses must implement intersectVerticalLine")
    }
    
    func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        fatalError("Subclasses must implement intersectWithSegmentAsLineResult")
    }

    func intersectNoPoints(_ np: NoPoints) -> NoPoints {
        return np
    }
    
    func intersectLineSegment(_ seg: LineSegment) -> GeometryValue {
        let lineResult = intersect(twoPointsToLine(seg.x1, seg.y1, seg.x2, seg.y2))
        return lineResult.intersectWithSegmentAsLineResult(seg)
    }
    
    func evalProg(_ env: Environment) -> GeometryValue {
        return self
    }
    
    func preprocessProg() -> any GeometryExpression {
        return self
    }
}


class NoPoints: GeometryValue {
    override func evalProg(_ env: Environment) -> GeometryValue {
        return self
    }
    
    override func preprocessProg() -> any GeometryExpression {
        return self
    }
    
    override func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        return self
    }
    
    override func intersect(_ other: GeometryValue) -> GeometryValue {
        return other.intersectNoPoints(self)
    }
    
    override func intersectPoint(_ p: Point) -> GeometryValue {
        return self
    }
    
    override func intersectLine(_ line: Line) -> GeometryValue {
        return self
    }
    
    override func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        return self 
    }
    
    override func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        return self
    }
}


class Point: GeometryValue {
    internal let x: Float
    internal let y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    override func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        return Point(x + dx, y + dy)
    }
    
    override func intersect(_ other: GeometryValue) -> GeometryValue {
        return other.intersectPoint(self)
    }
    
    override func intersectPoint(_ p: Point) -> GeometryValue {
        if realClosePoint((x, y), (p.x, p.y)) {
            return self
        } else {
            return NoPoints()
        }
    }
    
    override func intersectLine(_ line: Line) -> GeometryValue {
        if realClose(y, (line.m * x + line.b)) {
            return self
        } else {
            return NoPoints()
        }
    }
    
    override func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        if realClose(x, vline.x) {
            return self
        } else {
            return NoPoints()
        }
    }
    
    override func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        if (realClose(x, seg.x1) || realClose(x, seg.x2) || (x > seg.x1) && x < seg.x2) {
            return self
        } else {
            return NoPoints()
        }
    }
}


class Line: GeometryValue {
    internal let m: Float
    internal let b: Float
    
    init(_ m: Float, _ b: Float) {
        self.m = m
        self.b = b
    }
    
    override func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        return Line(m, b + dy - m * dx)
    }
    
    override func intersect(_ other: GeometryValue) -> GeometryValue {
        return other.intersectLine(self)
    }
    
    override func intersectPoint(_ p: Point) -> GeometryValue {
        return p.intersectLine(self)
    }

    override func intersectLine(_ line: Line) -> GeometryValue {
        if realClose(m, line.m) {
            return realClose(b, line.b) ? self : NoPoints()
        }
        let x = (line.b - b) / (m - line.m)
        return Point(x, m * x + b)
    }
    
    override func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        return Point(vline.x, (vline.x * m + b))
    }
    
    override func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        return seg
    }
}


class VerticalLine: GeometryValue {
    let x: Float
    
    init(_ x: Float) {
        self.x = x
    }
    
    override func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        return VerticalLine(x + dx)
    }
    
    override func intersect(_ other: GeometryValue) -> GeometryValue {
        return other.intersectVerticalLine(self)
    }
    
    override func intersectPoint(_ p: Point) -> GeometryValue {
        return p.intersectVerticalLine(self)
    }
    
    override func intersectLine(_ line: Line) -> GeometryValue {
        return line.intersectVerticalLine(self)
    }
    
    override func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        if realClose(x, vline.x) {
            return self
        } else {
            return NoPoints()
        }
    }
    
    override func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        return seg
    }
    
}


class LineSegment: GeometryValue {
    let x1: Float
    let y1: Float
    let x2: Float
    let y2: Float
    
    init(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }
    
    override func preprocessProg() -> any GeometryExpression {
        if realClosePoint((x1, y1), (x2, y2)) {
            return Point(x1, y1)
        } else if realClose(x1, x2) && y1 > y2 {
            return LineSegment(x2, y2, x1, y1)
        } else if !realClose(x1, x2) && x1 > x2 {
            return LineSegment(x2, y2, x1, y1)
        } else {
            return self
        }
    }
    
    override func shift(_ dx: Float, _ dy: Float) -> GeometryValue {
        return LineSegment(x1 + dx, y1 + dy, x2 + dx, y2 + dy)
    }
    
    override func intersect(_ other: GeometryValue) -> GeometryValue {
        return other.intersectLineSegment(self)
    }
    
    override func intersectPoint(_ p: Point) -> GeometryValue {
        return p.intersectLineSegment(self)
    }
    
    override func intersectVerticalLine(_ vline: VerticalLine) -> GeometryValue {
        return vline.intersectLineSegment(self)
    }
    
    override func intersectWithSegmentAsLineResult(_ seg: LineSegment) -> GeometryValue {
        if realClose(x1, seg.x1) && realClose(x2, seg.x2) {
            return self
        } else if realClose(x1, seg.x1) {
            if x2 < seg.x2 {
                return self
            } else {
                return LineSegment(x1, y1, seg.x2, seg.y2)
            }
        } else if realClose(x2, seg.x2) {
            if x1 < seg.x1 {
                return LineSegment(seg.x1, seg.y1, x2, y2)
            } else {
                return self
            }
        } else if x2 < seg.x1 || x1 > seg.x2 {
            return NoPoints()
        } else {
            return LineSegment(
                max(x1, seg.x1),
                max(y1, seg.y1),
                min(x2, seg.x2),
                min(y2, seg.y2)
            )
        }
    }
}



struct Intersect: GeometryExpression {
    private let e1: any GeometryExpression
    private let e2: any GeometryExpression
    
    init(_ e1: any GeometryExpression, _ e2: any GeometryExpression) {
        self.e1 = e1
        self.e2 = e2
    }
    
    func evalProg(_ env: Environment) -> GeometryValue {
        return e1.evalProg(env).intersect(e2.evalProg(env))
    }
    
    func preprocessProg() -> any GeometryExpression {
        return Intersect(e1.preprocessProg(), e2.preprocessProg())
    }
}


struct Let: GeometryExpression {
    private let s: String
    private let e1: any GeometryExpression
    private let e2: any GeometryExpression
    
    init(_ s: String, _ e1: any GeometryExpression, _ e2: any GeometryExpression) {
        self.s = s
        self.e1 = e1
        self.e2 = e2
    }
    
    func preprocessProg() -> any GeometryExpression {
        return Let(s, e1.preprocessProg(), e2.preprocessProg())
    }
    
    func evalProg(_ env: Environment) -> GeometryValue {
        let newEnv = [(s, e1.evalProg(env))] + env
        return e2.evalProg(newEnv)
    }
}


struct Var: GeometryExpression {
    private let s: String
    
    init(_ s: String) {
        self.s = s
    }
    
    // remember: do not change this method
    func evalProg(_ env: Environment) -> GeometryValue {
        if let pair = env.first(where: { $0.0 == s }) {
            return pair.1
        } else {
            fatalError("undefined variable: \(s)")
        }
    }
    
    func preprocessProg() -> any GeometryExpression {
        return self
    }
}


struct Shift: GeometryExpression {
    private let dx: Float
    private let dy: Float
    private let e: any GeometryExpression
    
    init(_ dx: Float, _ dy: Float, _ e: any GeometryExpression) {
        self.dx = dx
        self.dy = dy
        self.e = e
    }
    
    func preprocessProg() -> any GeometryExpression {
        return Shift(dx, dy, e.preprocessProg())
    }
    
    func evalProg(_ env: Environment) -> GeometryValue {
        return e.evalProg(env).shift(dx, dy)
    }
}
