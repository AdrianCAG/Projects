//
//  OOPFunctionalTest.swift
//  OOPFunctionalTest
//
//  Created by Adrian on 1/12/25.
//

import XCTest



func realEqual(_ x: Float, _ y: Float) -> Bool {
    return abs(x - y) < epsilon // epsilon is already defined as a small threshold
}


let ZERO: Float = 0.0
let ONE: Float = 1.0
let TWO: Float = 2.0
let THREE: Float = 3.0
let FOUR: Float = 4.0
let FIVE: Float = 5.0
let SIX: Float = 6.0
let SEVEN: Float = 7.0
let EIGHT: Float = 8.0
let NINE: Float = 9.0
let TEN: Float = 10.0


final class OOPFunctionalTest: XCTestCase {

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------
       // Functional
       
       func testFunctional() throws {
           // --------------------------------------------------------------------------------------------------
           // Preprocess tests
           
           let result1: geomExp = preprocessProg(.LineSegment(3.2, 4.1, 3.2, 4.1))
           let result2: geomExp = .Point(3.2, 4.1)
           
           // Check if the processed result is equal to the expected result
           switch result1 {
           case .Point(let x1, let y1):
               switch result2 {
               case .Point(let x2, let y2):
                   XCTAssertTrue(realEqual(x1, x2), "The x values should be equal.")
                   XCTAssertTrue(realEqual(y1, y2), "The y values should be equal.")
               default:
                   XCTFail("Expected a Point.")
               }
           default:
               XCTFail("Expected a Point from LineSegment.")
           }
           
           
           
           // ---------------------------------------------------------------
           let result3 = preprocessProg(.LineSegment(3.2, 4.1, -3.2, -4.1))
           let result4: geomExp = .LineSegment(-3.2, -4.1, 3.2, 4.1)
           
           switch result3 {
           case .LineSegment(let a, let b, let c, let d):
               switch result4 {
               case .LineSegment(let e, let f, let g, let h):
                   XCTAssertTrue(realEqual(a, e), "The x values should be equal.")
                   XCTAssertTrue(realEqual(b, f), "The y values should be equal.")
                   XCTAssertTrue(realEqual(c, g), "The x values should be equal.")
                   XCTAssertTrue(realEqual(d, h), "The y values should be equal.")
               default:
                   XCTFail("Expected a LineSegment.")
               }
           default:
               XCTFail("Expected a LineSegment from LineSegment.")
           }
           
           
           // --------------------------------------------------------------------------------------------------
           // eval_prog tests with Shift
           
           let result5 = evalProg(preprocessProg(.Shift(3.0, 4.0, .Point(4.0, 4.0))), [])
           let result6: geomExp = .Point(7.0, 8.0)
           
           switch result5 {
           case .Point(let a, let b):
               switch result6 {
               case .Point(let c, let d):
                   XCTAssertTrue(realEqual(a, c), "The x values should be equal.")
                   XCTAssertTrue(realEqual(b, d), "The y values should be equal.")
               default:
                   XCTFail("Expected a Point.")
               }
           default:
               XCTFail("Expected a Point from LineSegment.")
           }
           
           
           // --------------------------------------------------------------------------------------------------
           //  Using a Var
           
           let result7 = evalProg(.Shift(3.0, 4.0, .Var("a")), [("a", .Point(4.0, 4.0))])
           let result8: geomExp = .Point(7.0, 8.0)
           
           switch result7 {
           case .Point(let a, let b):
               switch result8 {
               case .Point(let c, let d):
                   XCTAssertTrue(realEqual(a, c), "The x values should be equal.")
                   XCTAssertTrue(realEqual(b, d), "The y values should be equal.")
               default:
                   XCTFail("Expected a Point.")
               }
           default:
               XCTFail("Expected a Point from LineSegment.")
           }
           
           
           // --------------------------------------------------------------------------------------------------
           //  With Variable Shadowing
           let result9 = evalProg(.Shift(3.0, 4.0, .Var("a")), [("a", .Point(4.0, 4.0)), ("a", .Point(1.0, 1.0))])
           let result10: geomExp = .Point(7.0, 8.0)
           
           switch result9 {
           case .Point(let a, let b):
               switch result10 {
               case .Point(let c, let d):
                   XCTAssertTrue(realEqual(a, c), "The x values should be equal.")
                   XCTAssertTrue(realEqual(b, d), "The y values should be equal.")
               default:
                   XCTFail("Expected a Point.")
               }
           default:
               XCTFail("Expected a Point from LineSegment.")
           }
           
           
           let result11 = evalProg(.Shift(3.0, 4.0, .Var("c")), [("a", .Line(4.0, 4.0)), ("c", .Point(1.0, 1.0))])
           let result12: geomExp = .Point(4.0, 5.0)
           
           switch result11 {
           case .Point(let a, let b):
               switch result12 {
               case .Point(let c, let d):
                   XCTAssertTrue(realEqual(a, c), "The x values should be equal.")
                   XCTAssertTrue(realEqual(b, d), "The y values should be equal.")
               default:
                   XCTFail("Expected a Point.")
               }
           default:
               XCTFail("Expected a Point from LineSegment.")
           }
       }
       
       
       
       // -----------------------------------------------------------------------------------------------------------------------------------------------------------------
       // OOP
       
       func testPointOOP() throws {
           let a = Point(THREE, FIVE)
           
           XCTAssertEqual(a.x, THREE, "Point is not initialized properly")
           XCTAssertEqual(a.y, FIVE, "Point is not initialized properly")
           XCTAssertEqual(a.evalProg([]), a, "Point evalProg should return self")
           XCTAssertEqual(a.preprocessProg() as! Point, a, "Point preprocessProg should return self")
           
           let a1 = a.shift(THREE, FIVE) as! Point
           XCTAssertEqual(a1.x, SIX, "Point shift not working properly")
           XCTAssertEqual(a1.y, TEN, "Point shift not working properly")
           
           let a2 = a.intersect(Point(THREE, FIVE))
           XCTAssertEqual(a2 as? Point, a, "Point intersect not working properly")

           let a3 = a.intersect(Point(FOUR, FIVE))
           XCTAssertTrue(a3 is NoPoints, "Point intersect not working properly")
       }
       
       
       func testLineOOP() throws {
           let b = Line(THREE, FIVE)
           XCTAssertEqual(b.m, THREE, "Line not initialized properly")
           XCTAssertEqual(b.b, FIVE, "Line not initialized properly")
           XCTAssertEqual(b.evalProg([]), b, "Line evalProg should return self")
           XCTAssertEqual(b.preprocessProg() as! Line, b, "Line preprocessProg should return self")

           let b1 = b.shift(THREE, FIVE) as! Line
           XCTAssertEqual(b1.m, THREE, "Line shift not working properly")
           XCTAssertEqual(b1.b, ONE, "Line shift not working properly")

           let b2 = b.intersect(Line(THREE, FIVE))
           XCTAssertTrue(b2 is Line, "Line intersect not working properly")
           XCTAssertEqual((b2 as? Line)?.m, THREE, "Line intersect not working properly")
           XCTAssertEqual((b2 as? Line)?.b, FIVE, "Line intersect not working properly")

           let b3 = b.intersect(Line(THREE, FOUR))
           XCTAssertTrue(b3 is NoPoints, "Line intersect not working properly")
       }
       
       
       func testVerticalLineOOP() throws {
           let c = VerticalLine(THREE)
           XCTAssertEqual(c.x, THREE, "VerticalLine not initialized properly")
           XCTAssertEqual(c.evalProg([]), c, "VerticalLine evalProg should return self")
           XCTAssertEqual(c.preprocessProg() as! VerticalLine, c, "VerticalLine preprocessProg should return self")

           let c1 = c.shift(THREE, FIVE) as! VerticalLine
           XCTAssertEqual(c1.x, SIX, "VerticalLine shift not working properly")

           let c2 = c.intersect(VerticalLine(THREE))
           XCTAssertTrue(c2 is VerticalLine, "VerticalLine intersect not working properly")
           XCTAssertEqual((c2 as? VerticalLine)?.x, THREE, "VerticalLine intersect not working properly")

           let c3 = c.intersect(VerticalLine(FOUR))
           XCTAssertTrue(c3 is NoPoints, "VerticalLine intersect not working properly")
       }
     
       
       func testLineSegmentOOP() throws {
           var d = LineSegment(ONE, TWO, -THREE, -FOUR)
           XCTAssertEqual(d.evalProg([]), d, "LineSegment evalProg should return self")

           let d1 = LineSegment(ONE, TWO, ONE, TWO)
           let d2 = d1.preprocessProg()
           XCTAssertTrue(d2 is Point, "LineSegment preprocessProg should convert to a Point")
           XCTAssertEqual((d2 as? Point)?.x, ONE, "LineSegment preprocessProg conversion issue")
           XCTAssertEqual((d2 as? Point)?.y, TWO, "LineSegment preprocessProg conversion issue")

           d = d.preprocessProg() as! LineSegment
           XCTAssertEqual(d.x1, -THREE, "LineSegment preprocessProg reordering issue")
           XCTAssertEqual(d.y1, -FOUR, "LineSegment preprocessProg reordering issue")
           XCTAssertEqual(d.x2, ONE, "LineSegment preprocessProg reordering issue")
           XCTAssertEqual(d.y2, TWO, "LineSegment preprocessProg reordering issue")

           let d3 = d.shift(THREE, FIVE) as! LineSegment
           XCTAssertEqual(d3.x1, ZERO, "LineSegment shift not working properly")
           XCTAssertEqual(d3.y1, ONE, "LineSegment shift not working properly")
           XCTAssertEqual(d3.x2, FOUR, "LineSegment shift not working properly")
           XCTAssertEqual(d3.y2, SEVEN, "LineSegment shift not working properly")

           let d4 = d.intersect(LineSegment(-THREE, -FOUR, ONE, TWO))
           XCTAssertTrue(d4 is LineSegment, "LineSegment intersect not working properly")
           XCTAssertEqual((d4 as? LineSegment)?.x1, -THREE, "LineSegment intersect values incorrect")
           XCTAssertEqual((d4 as? LineSegment)?.y1, -FOUR, "LineSegment intersect values incorrect")
           XCTAssertEqual((d4 as? LineSegment)?.x2, ONE, "LineSegment intersect values incorrect")
           XCTAssertEqual((d4 as? LineSegment)?.y2, TWO, "LineSegment intersect values incorrect")

           let d5 = d.intersect(LineSegment(TWO, THREE, FOUR, FIVE))
           XCTAssertTrue(d5 is NoPoints, "LineSegment intersect not working properly")
       }
       
       
       func testIntersectOOP() throws {
           let e1 = LineSegment(-ONE, -TWO, THREE, FOUR)
           let e2 = LineSegment(THREE, FOUR, -ONE, -TWO)
           let i = Intersect(e1, e2)
           let i1 = i.preprocessProg().evalProg([]) as! LineSegment
           
           XCTAssertEqual(i1.x1, -ONE, "Intersect evalProg should return the correct x1")
           XCTAssertEqual(i1.y1, -TWO, "Intersect evalProg should return the correct y1")
           XCTAssertEqual(i1.x2, THREE, "Intersect evalProg should return the correct x2")
           XCTAssertEqual(i1.y2, FOUR, "Intersect evalProg should return the correct y2")
       }
       
       
       func testVarOOP() throws {
           let v = Var("a")
           let v1 = v.evalProg([("a", Point(THREE, FIVE))])
               
           XCTAssertTrue(v1 is Point, "Var evalProg should return a Point instance")
           XCTAssertEqual((v1 as! Point).x, THREE, "Var evalProg did not return the correct x value")
           XCTAssertEqual((v1 as! Point).y, FIVE, "Var evalProg did not return the correct y value")
           XCTAssertEqual(v.preprocessProg() as! Var, v, "Var preprocessProg should return self")
       }
       
       
       func testLetOOP() throws {
           let l = Let("a", LineSegment(-ONE, -TWO, THREE, FOUR), Intersect(Var("a"), LineSegment(THREE, FOUR, -ONE, -TWO)))
           let l1 = l.preprocessProg().evalProg([]) as! LineSegment
           
           XCTAssertEqual(l1.x1, -ONE, "Let evalProg should return the correct x1")
           XCTAssertEqual(l1.y1, -TWO, "Let evalProg should return the correct y1")
           XCTAssertEqual(l1.x2, THREE, "Let evalProg should return the correct x2")
           XCTAssertEqual(l1.y2, FOUR, "Let evalProg should return the correct y2")
       }
       
       
       func testLetVariableShadowingOOP() throws {
           let l2 = Let("a", LineSegment(-ONE, -TWO, THREE, FOUR), Let("b", LineSegment(THREE, FOUR, -ONE, -TWO), Intersect(Var("a"), Var("b"))))
           let l2Result = l2.preprocessProg().evalProg([("a", Point(0, 0))]) as! LineSegment
           
           XCTAssertEqual(l2Result.x1, -ONE, "Let evalProg with shadowing should return the correct x1")
           XCTAssertEqual(l2Result.y1, -TWO, "Let evalProg with shadowing should return the correct y1")
           XCTAssertEqual(l2Result.x2, THREE, "Let evalProg with shadowing should return the correct x2")
           XCTAssertEqual(l2Result.y2, FOUR, "Let evalProg with shadowing should return the correct y2")
       }
       
       
       func testShiftOOP() throws {
           let s = Shift(THREE, FIVE, LineSegment(-ONE, -TWO, THREE, FOUR))
           let s1 = s.preprocessProg().evalProg([]) as! LineSegment
           
           XCTAssertEqual(s1.x1, TWO, "Shift should correctly shift x1")
           XCTAssertEqual(s1.y1, THREE, "Shift should correctly shift y1")
           XCTAssertEqual(s1.x2, SIX, "Shift should correctly shift x2")
           XCTAssertEqual(s1.y2, NINE, "Shift should correctly shift y2")
       }

}
