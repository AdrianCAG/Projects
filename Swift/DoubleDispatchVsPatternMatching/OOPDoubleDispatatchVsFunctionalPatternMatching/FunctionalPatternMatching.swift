//
//  FunctionalPatternMatching.swift
//  OOPFunctionalTest
//
//  Created by Adrian on 1/12/25.
//

import Foundation






indirect enum geomExp {
    case NoPoints
    case Point(Float, Float)                          // represents point (x,y)
    case Line(Float, Float)                           // represents line (slope, intercept)
    case VerticalLine(Float)                          // x value
    case LineSegment(Float, Float, Float, Float)      // x1,y1 to x2,y2
    case Intersect(geomExp, geomExp)                  // intersection expression
    case Let(String, geomExp, geomExp)                // let s = e1 in e2
    case Var(String)
    case Shift(Float, Float, geomExp)
}



enum MyError: Error {
    case badProgram(String)
    case impossible(String)
}


let epsilon: Float = 0.00001


func realClose(_ r1: Float, _ r2: Float) -> Bool {
    return abs(r1 - r2) < epsilon
}


func realClosePoint(_ p1: (Float, Float), _ p2: (Float, Float)) -> Bool {
    return realClose(p1.0, p2.0) && realClose(p1.1, p2.1)
}


func twoPointsToLine(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) -> geomExp {
    if realClose(x1, x2) {
        return .VerticalLine(x1)
    } else {
        let m = (y2 - y1) / (x2 - x1)
        let b = y1 - m * x1
        return .Line(m, b)
    }
}


func intersect(_ v1: geomExp, _ v2: geomExp) -> geomExp {
    switch (v1, v2) {
        case (.NoPoints, _): return .NoPoints  // 5 cases
        case (_, .NoPoints): return .NoPoints  // 4 additional cases
        case (.Point(let x1, let y1), .Point(let x2, let y2)): return realClosePoint((x1, y1), (x2, y2)) ? v1 : .NoPoints
        case (.Point(let x, let y), .Line(let m, let b)):      return realClose(y, m * x + b) ? v1 : .NoPoints
        case (.Point(let x1, _), .VerticalLine(let x2)):       return realClose(x1, x2) ? v1 : .NoPoints
        case (.Point, .LineSegment):                           return intersect(v2, v1)
        case (.Line, .Point):                                  return intersect(v2, v1)
        case (.Line(let m1, let b1), .Line(let m2, let b2)):
            if realClose(m1, m2) {
                return realClose(b1, b2) ? v1 : .NoPoints
            } else {
                let x = (b2 - b1) / (m1 - m2)
                let y = m1 * x + b1
                return .Point(x, y)
            }
        case (.Line(let m1, let b1), .VerticalLine(let x2)):   return .Point(x2, m1 * x2 + b1)
        case (.Line, .LineSegment):                            return intersect(v2, v1)
        case (.VerticalLine, .Point):                          return intersect(v2, v1)
        case (.VerticalLine, .Line):                           return intersect(v2, v1)
        case (.VerticalLine(let x1), .VerticalLine(let x2)):   return realClose(x1, x2) ? v1 : .NoPoints
        case (.VerticalLine, .LineSegment):                    return intersect(v2, v1)
        case (.LineSegment(let x1, let y1, let x2, let y2), _):
            let lineContainingSegment = twoPointsToLine(x1, y1, x2, y2)
            switch intersect(lineContainingSegment, v2) {
                case .NoPoints:                                return .NoPoints
                case .Point(let x0, let y0):

                    func inbetween(_ v: Float, _ end1: Float, _ end2: Float) -> Bool {
                        return (end1 - epsilon <= v && v <= end2 + epsilon) || (end2 - epsilon <= v && v <= end1 + epsilon)
                    }
                    return inbetween(x0, x1, x2) && inbetween(y0, y1, y2) ? .Point(x0, y0) : .NoPoints
                case .Line:                                    return v1   // so segment seg is on line v2
                case .VerticalLine:                            return v1   // so segment seg is on vertical-line v2
                case .LineSegment(let x3, let y3, let x4, let y4):
                let (x1start, y1start, x1end, _) = (x1, y1, x2, y2)
                let (x2start, y2start, _, _) = (x3, y3, x4, y4)
                
                    if realClose(x1start, x1end) {
                        let ((_, _, aXend, aYend),
                             (bXstart, bYstart, bXend, bYend)) = y1start < y2start ?
                                                                                    ((x1, y1, x2, y2),(x3, y3, x4, y4))
                                                                                   :
                                                                                    ((x3, y3, x4, y4), (x1, y1, x2, y2))
                        if realClose(aYend, bYstart) {
                            return .Point(aXend, aYend)  // just touching
                        } else if aYend < bYstart {
                            return .NoPoints             // disjoint
                        } else if aYend > bYend {
                            return .LineSegment(bXstart, bYstart, bXend, bYend)   // b inside a
                        } else {
                            return .LineSegment(bXstart, bYstart, aXend, aYend)   // overlapping
                        }
                    } else {
                        let ((_,_,aXend,aYend),
                             (bXstart,bYstart,bXend,bYend)) = x1start < x2start ?
                                                                                 ((x1, y1, x2, y2), (x3, y3, x4, y4))
                                                                                :
                                                                                 ((x3, y3, x4, y4), (x1, y1, x2, y2))
                        if realClose(aXend, bXstart) {
                            return .Point(aXend, aYend)  // just touching
                        } else if aXend < bXstart {
                            return .NoPoints             // disjoint
                        } else if aXend > bXend {
                            return .LineSegment(bXstart, bYstart, bXend, bYend)  // b inside a
                        } else {
                            return .LineSegment(bXstart, bYstart, aXend, aYend)     // overlapping
                        }
                        
                    }
                
                default:
                    fatalError("bad result from intersecting with a line")
            }
        default:
            fatalError("bad call to intersect: only for shape values")
    }
}


func evalProg(_ e: geomExp, _ env: [(String, geomExp)]) -> geomExp {
    switch e {
        case .NoPoints, .Point, .Line, .VerticalLine, .LineSegment: return e  
        case .Var(let s):
            if let (_, v) = env.first(where: { $0.0 == s }) {
                return v
            } else {
                fatalError("var not found: \(s)")
            }
        case .Let(let s, let e1, let e2):
            return evalProg(e2, [(s, evalProg(e1, env))] + env)
        case .Intersect(let e1, let e2):
            return intersect(evalProg(e1, env), evalProg(e2, env))
        case .Shift(let deltaX, let deltaY, let e):
            switch evalProg(e, env) {
                case .NoPoints: return .NoPoints
                case .Point(let x, let y): return .Point(x + deltaX, y + deltaY)
                case .Line(let m, let b): return .Line(b + deltaY, m * deltaX)
                case .VerticalLine(let x): return .VerticalLine(x + deltaX)
                case .LineSegment(let xStart, let yStart, let xEnd, let yEnd): return .LineSegment(xStart, yStart, xEnd + deltaX, yEnd + deltaY)
                default : fatalError("test")
            }
    }
}



func preprocessProg(_ exp: geomExp) -> geomExp {
    switch exp {
    case .Var, .Point, .Line, .VerticalLine, .NoPoints: return exp
    case .LineSegment(let x1, let y1, let x2, let y2):
        if realClosePoint((x1, y1), (x2, y2)) {
            return .Point(x1, y1)
        } else if x1 > x2 || (realClose(x1, x2) && y1 > y2) {
            return .LineSegment(x2, y2, x1, y1)
        } else {
            return exp
        }
    case .Intersect(let e1, let e2):
        return .Intersect(preprocessProg(e1), preprocessProg(e2))
    case .Let(let varName, let e1, let e2):
        return .Let(varName, preprocessProg(e1), preprocessProg(e2))
    case .Shift(let deltaX, let deltaY, let e):
        return .Shift(deltaX, deltaY, preprocessProg(e))
    }
}
