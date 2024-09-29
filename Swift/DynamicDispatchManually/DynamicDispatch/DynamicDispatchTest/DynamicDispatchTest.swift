//
//  DynamicDispatchTest.swift
//  DynamicDispatchTest
//
//  Created by Adrian Ghita on 9/28/24.
//

import XCTest

final class DynamicDispatchTest: XCTestCase {
    
    // DynamicDispatch
    // -----------------------------------------------------------------------------------
    func testPoint() throws {
        let point = Point(-4, 0)
        
        let resultOne = point.getX()
        let resultTwo = point.getY()
        let resultThree = point.distFromOrigin()
        point.setY(3)
        let resultFour = point.getY()
        let resultFive = point.distFromOrigin()
        
        XCTAssertEqual(resultOne, -4)
        XCTAssertEqual(resultTwo, 0)
        XCTAssertEqual(resultThree, 4.0)
        XCTAssertEqual(resultFour, 3)
        XCTAssertEqual(resultFive, 5.0)
    }
    
    func testColorPoint() throws {
        let colorPoint = ColorPoint(-4, 0, "red")
        
        
        let resultOne = colorPoint.getX()
        let resultTwo = colorPoint.getY()
        let resultThree = colorPoint.getColor()
        let resultFour = colorPoint.distFromOrigin()
        colorPoint.setY(3)
        let resultFive = colorPoint.getY()
        let resultSix = colorPoint.distFromOrigin()
        colorPoint.setColor("blue")
        let resultSeven = colorPoint.getColor()

        XCTAssertEqual(resultOne, -4)
        XCTAssertEqual(resultTwo, 0)
        XCTAssertEqual(resultThree, "red")
        XCTAssertEqual(resultFour, 4.0)
        XCTAssertEqual(resultFive, 3)
        XCTAssertEqual(resultSix, 5.0)
        XCTAssertEqual(resultSeven, "blue")
        
    }
    
    func testPolarPoint() throws {
        let polarPoint = PolarPoint(4, 3.1415926535)
        
        let resultOne = polarPoint.getX()
        let resultTwo = polarPoint.getY()
        let resultThree = polarPoint.distFromOrigin()
        polarPoint.setRTheta(10, -10)
//        let resultFour = polarPoint.r
//        let resultFive = polarPoint.theta

        XCTAssertEqual(resultOne, -4.0)
        XCTAssertEqual(resultTwo , 3.591727373580927e-10)
        XCTAssertEqual(resultThree, 4.0)
//        XCTAssertEqual(resultFour, 10)
//        XCTAssertEqual(resultFive, -10)
    }
    

    
    // DynamicDispatchManually
    // -----------------------------------------------------------------------------------
    func testAssocM() throws {
        let dict = ["x": 10, "y": 20]
        
        let resultOne = assocM("x", dict)
        let resultTwo = assocM("y", dict)
        let resultThree = assocM("z", dict)
        
        XCTAssertEqual(resultOne as! [String : Int], ["x": 10])
        XCTAssertEqual(resultTwo as! [String : Int], ["y": 20])
        XCTAssertEqual(resultThree as! Bool, false)
    }
    
    func testMakePoint() throws {
        var point = makePoint(-4, 0)
        
        let resultOne = send(&point, "getX")
        let resultTwo = send(&point, "getY")
        let resultThree = send(&point, "distToOrigin")
        send(&point, "setY", 3)
        let resultFour = send(&point, "getY")
        let resultFive = send(&point, "distToOrigin")
        
        XCTAssertEqual(resultOne as! Int, -4)
        XCTAssertEqual(resultTwo as! Int, 0)
        XCTAssertEqual(resultThree as! Double, 4.0)
        XCTAssertEqual(resultFour as! Int, 3)
        XCTAssertEqual(resultFive as! Double, 5.0)
    }
    
    func testMakeColorPoint() throws {
        var colorPoint = makeColorPoint(-4, 0, "red")
        
        let resultOne = send(&colorPoint, "getX")
        let resultTwo = send(&colorPoint, "getY")
        let resultThree = send(&colorPoint, "getColor")
        let resultFour = send(&colorPoint, "distToOrigin")
        send(&colorPoint, "setY", 3)
        let resultFive = send(&colorPoint, "getY")
        let resultSix = send(&colorPoint, "distToOrigin")
        send(&colorPoint, "setColor", "blue")
        let resultNine = send(&colorPoint, "getColor")
        let resultTen = get(colorPoint, "color")
        
        XCTAssertEqual(resultOne as! Int, -4)
        XCTAssertEqual(resultTwo as! Int, 0)
        XCTAssertEqual(resultThree as! String, "red")
        XCTAssertEqual(resultFour as! Double, 4.0)
        XCTAssertEqual(resultFive as! Int, 3)
        XCTAssertEqual(resultSix as! Double, 5.0)
        XCTAssertEqual(resultNine as! String, "blue")
        XCTAssertEqual(resultTen as! String, "blue")
    }
    
    func testMakePolarPoint() throws {
        var polarPoint = makePolarPoint(4, 3.1415926535)
        
        let resultOne = send(&polarPoint, "getX")
        let resultTwo = send(&polarPoint, "getY")
        let resultThree = send(&polarPoint, "distToOrigin")
        send(&polarPoint, "setY", 3)
        let resultFour = send(&polarPoint, "getY")
        let resultFive = send(&polarPoint, "distToOrigin")
        
        
        XCTAssertEqual(resultOne as! Double, -4.0)
        XCTAssertEqual(resultTwo as! Double, 3.591727373580927e-10)
        XCTAssertEqual(resultThree as! Double, 4.0)
        XCTAssertEqual(resultFour as! Double, 3.0)
        XCTAssertEqual(resultFive as! Double, 5.0)
    }
   
}
