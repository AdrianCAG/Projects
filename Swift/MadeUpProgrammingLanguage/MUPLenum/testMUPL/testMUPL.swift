//
//  testMUPL.swift
//  testMUPL
//
//  Created by Adrian Ghita on 8/19/24.
//

import XCTest



func muplEqual(_ lhs: MUPLExpr, _ rhs: MUPLExpr) -> Bool {
    switch (lhs, rhs) {
    case let (.fun(name1, formal1, body1), .fun(name2, formal2, body2)):
        return name1 == name2 && formal1 == formal2 && muplEqual(body1, body2)

    case let (.vaar(lhsString), .vaar(rhsString)):
        return lhsString == rhsString

    case let (.int(lhsNum), .int(rhsNum)):
        return lhsNum == rhsNum

    case let (.addE(lhsE1, lhsE2), .addE(rhsE1, rhsE2)):
        return muplEqual(lhsE1, rhsE1) && muplEqual(lhsE2, rhsE2)

    case let (.ifgreater(lhsE1, lhsE2, lhsE3, lhsE4), .ifgreater(rhsE1, rhsE2, rhsE3, rhsE4)):
        return muplEqual(lhsE1, rhsE1) &&
               muplEqual(lhsE2, rhsE2) &&
               muplEqual(lhsE3, rhsE3) &&
               muplEqual(lhsE4, rhsE4)

    case let (.call(lhsFunExp, lhsActual), .call(rhsFunExp, rhsActual)):
        return muplEqual(lhsFunExp, rhsFunExp) && muplEqual(lhsActual, rhsActual)

    case let (.mlet(lhsVaar, lhsE, lhsBody), .mlet(rhsVaar, rhsE, rhsBody)):
        return lhsVaar == rhsVaar && muplEqual(lhsE, rhsE) && muplEqual(lhsBody, rhsBody)

    case let (.apair(lhsE1, lhsE2), .apair(rhsE1, rhsE2)):
        return muplEqual(lhsE1, rhsE1) && muplEqual(lhsE2, rhsE2)

    case let (.fst(lhsE), .fst(rhsE)):
        return muplEqual(lhsE, rhsE)

    case let (.snd(lhsE), .snd(rhsE)):
        return muplEqual(lhsE, rhsE)

    case (.aunit, .aunit):
        return true

    case let (.isaunit(lhsE), .isaunit(rhsE)):
        return muplEqual(lhsE, rhsE)

    case let (.closure(lhsEnv, lhsExpr), .closure(rhsEnv, rhsExpr)):
        return lhsEnv.elementsEqual(rhsEnv, by: { $0.first == $1.first && muplEqual($0.second, $1.second) }) && muplEqual(lhsExpr, rhsExpr)
        
    case let (.funChallenge(nameopt1, formal1, body1, freevars1), .funChallenge(nameopt2, formal2, body2, freevars2)):
        return nameopt1 == nameopt2 && formal1 == formal2 && muplEqual(body1, body2) && freevars1 == freevars2

    default:
        return false
    }
}

extension Array where Element == MUPLTuple<String, MUPLExpr> {
    static func ==(lhs: [MUPLTuple<String, MUPLExpr>], rhs: [MUPLTuple<String, MUPLExpr>]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (left, right) in zip(lhs, rhs) {
            if left.first != right.first || !muplEqual(left.second, right.second) {
                return false
            }
        }
        return true
    }
}


func muplArrayEqual(_ lhs: [MUPLExpr], _ rhs: [MUPLExpr]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs).allSatisfy(muplEqual)
}


func customTest(_ description: String, _ testCase: XCTestCase, _ function: () -> MUPLExpr, expected: MUPLExpr, file: StaticString = #file, line: UInt = #line) {
    let result = function()
    testCase.addTeardownBlock {
        XCTAssertTrue(muplEqual(result, expected), "\(description) failed. Expected \(expected), got \(result)", file: file, line: line)
    }
}

func customTestArray(_ description: String, _ testCase: XCTestCase, _ function: () -> [MUPLExpr], expected: [MUPLExpr], file: StaticString = #file, line: UInt = #line) {
    let result = function()
    testCase.addTeardownBlock {
        XCTAssertTrue(muplArrayEqual(result, expected), "\(description) failed. Expected \(expected), got \(result)", file: file, line: line)
    }
}


final class testMUPL: XCTestCase {

    func testSwiftArrayToMuplArray() {
           customTest("Empty swift Array should return Empty MUPL array", self, {
               swiftArrayToMuplArray([])
           }, expected: .aunit(()))
           
           customTest("Swift array with one MUPL elements should return MUPL array with one element", self, {
               swiftArrayToMuplArray([.int(3)])
           }, expected: .apair(.int(3), .aunit(())))
           
           customTest("Swift array with two MUPL elements should return MUPL array with two elements", self, {
               swiftArrayToMuplArray([.int(3), .int(4)])
           }, expected: .apair(.int(3), .apair(.int(4), .aunit(()))))
           
           customTest("Swift array with multiple MUPL elements should return MUPL array with multiple elements", self, {
               swiftArrayToMuplArray([.int(3), .int(4), .int(5)])
           }, expected: .apair(.int(3), .apair(.int(4), .apair(.int(5), .aunit(())))))
       }
       
       func testMuplArrayToSwiftArray() {
           customTestArray("Empty MUPL array should return an empty Swift array", self, {
               muplArrayToSwiftArray(.aunit(()))
           }, expected: [])
           
           customTestArray("MUPL array with one element should return a Swift array with that element", self, {
               muplArrayToSwiftArray(.apair(.int(4), .aunit(())))
           }, expected: [.int(4)])
           
           customTestArray("MUPL array with two elements should return a Swift array with those elements", self, {
               muplArrayToSwiftArray(.apair(.int(3), .apair(.int(4), .aunit(()))))
           }, expected: [.int(3), .int(4)])
       }
       
       func testEnvlookup() {
           customTest("envlookup test", self, {
               envlookup([*("x", .int(6))], "x")
           }, expected: .int(6))
           
           customTest("envlookup test", self, {
               envlookup([*("w", .int(3)), *("y", .int(10))], "y")
           }, expected: .int(10))
           
       }
       
       func testIfgreater() {
           customTest("ifgreater test", self, {
               evalExp(.ifgreater(.int(3), .int(4), .int(3), .int(2)))
           }, expected: .int(2))
           
           customTest("ifgreater test", self, {
               evalExp(.ifgreater(.int(4), .int(3), .int(3), .int(2)))
           }, expected: .int(3))
       }
       
       
       // In Swift, when you have a name conflict between a struct and a method (especially in the context of a test case class inheriting from
       // XCTestCase), the method name takes precedence. This can lead to issues when you want to refer to the struct with the same name. (this case add)
       func testMlet() {
           customTest("mlet test", self, {
               evalExp(.mlet("x", .int(1), .addE(.int(5), .vaar("x"))))
           }, expected: .int(6))
           
           customTest("mlet test", self, {
               evalExp(.mlet("x", .int(1), .addE(.vaar("x"), .vaar("x"))))
           }, expected: .int(2))
       }
       
       func testCall() {
           customTest("call test", self, {
               evalExp(.call(.fun("#f", "x", .int(7)), .int(1)))
           }, expected: .int(7))
           
           customTest("call test", self, {
               evalExp(.call(.fun("#f", "x", .addE(.vaar("x"), .int(7))), .int(1)))
           }, expected: .int(8))
           
           customTest("call test", self, {
               evalExp(.call(.closure([], .fun("#f", "x", .addE(.vaar("x"), .int(7)))), .int(1)))
           }, expected: .int(8))
           
           customTest("call test", self, {
               evalExp(.call(.closure([*("y", .int(7))], .fun("#f", "x", .addE(.vaar("x"), .vaar("y")))), .int(1)))
           }, expected: .int(8))
           
           customTest("call test", self, {
               evalExp(.call(.closure([], .fun("hello", "x", .addE(.vaar("x"), .int(7)))), .int(1)))
           }, expected: .int(8))
       }
       
       func testApair() {
           customTest("pair test", self, {
               evalExp(.apair(.int(2), .int(1)))
           }, expected: .apair(.int(2), .int(1)))
           
           customTest("pair test", self, {
               evalExp(.apair(.addE(.int(2), .int(3)), .int(1)))
           }, expected: .apair(.int(5), .int(1)))
           
           customTest("pair test", self, {
               evalExp(.apair(.int(1), .addE(.int(2), .int(3))))
           }, expected: .apair(.int(1), .int(5)))
           
           customTest("apair test", self, {
               evalExp(.apair(.fun("#f", "x", .addE(.vaar("x"), .int(7))), .int(5)))
           }, expected: .apair(.closure([], .fun("#f", "x", .addE(.vaar("x"), .int(7)))), .int(5)))
       }
       
       func testFst() {
           customTest("fst test", self, {
               evalExp(.fst(.apair(.int(2), .int(1))))
           }, expected: .int(2))
           
           customTest("fst test", self, {
               evalExp(.fst(.apair(.addE(.int(2), .int(3)), .int(1))))
           }, expected: .int(5))
           
           customTest("fst test", self, {
               evalExp(.fst(.apair(.fun("#f", "x", .addE(.vaar("x"), .int(7))), .int(5))))
           }, expected: .closure([], .fun("#f", "x", .addE(.vaar("x"), .int(7)))))
       }
       
       func testSnd() {
           customTest("snd test", self, {
               evalExp(.snd(.apair(.int(1), .int(2))))
           }, expected: .int(2))
           
           customTest("snd test", self, {
               evalExp(.snd(.apair(.addE(.int(2), .int(3)), .int(1))))
           }, expected: .int(1))
           
           customTest("snd test", self, {
               evalExp(.snd(.apair(.fun("#f", "x", .addE(.vaar("x"), .int(7))), .int(5))))
           }, expected: .int(5))
       }
       
       func testIsaunit() {
           customTest("isaunit test", self, {
               evalExp(.isaunit(.closure([], .fun("#f", "x", .aunit(())))))
           }, expected: .int(0))
           
           customTest("isaunit test", self, {
               evalExp(.isaunit(.addE(.int(2), .int(3))))
           }, expected: .int(0))
           
           customTest("isaunit test", self, {
               evalExp(.isaunit(.aunit(())))
           }, expected: .int(1))
       }
       
       func testIfaunit() {
           customTest("ifaunit test", self, {
               evalExp(ifaunit(.int(1), .int(2), .int(3)))
           }, expected: .int(3))
           
           customTest("ifaunit test", self, {
               evalExp(ifaunit(.aunit(()), .int(2), .int(3)))
           }, expected: .int(2))
           
           customTest("ifaunit test", self, {
               evalExp(ifaunit(.aunit(()), .addE(.int(2), .int(3)), .int(3)))
           }, expected: .int(5))
       }
       
       func testMletStar() {
           // fatalError("unbound variable during evaluation")
           /*
           customTest("mlet* test", self, {
               evalExp(mletStar([], vaar("x")))
           }, expected: vaar("x"))
           */
           
           customTest("mlet* test", self, {
               evalExp(mletStar([*("x", .int(10))], .vaar("x")))
           }, expected: .int(10))
           
           
           customTest("mlet* test", self, {
               evalExp(mletStar([
                 *("x", .int(10)),
                 *("y", .int(5)),
                 *("z", .int(2))], .vaar("z")))
           }, expected: .int(2))
           
           // simple translation of the above test
           customTest("mlet* test", self, {
               evalExp(.mlet("x", .int(10), .mlet("y", .int(5), .mlet("z", .int(2), .vaar("z")))))
           }, expected: .int(2))
           
           customTest("mlet* test", self, {
               evalExp(mletStar([
                 *("x", .int(10)),
                 *("y", .int(5)),
                 *("z", .int(2))], .vaar("y")))
           }, expected: .int(5))
           
           customTest("mlet* test", self, {
               evalExp(mletStar([
                 *("x", .int(10)),
                 *("y", .int(1))], .addE(.vaar("x"), .vaar("y"))))
           }, expected: .int(11))
       }
       
       func testIfeq() {
           customTest("ifeq test", self, {
               evalExp(ifeq(.int(1), .int(2), .int(3), .int(4)))
           }, expected: .int(4))
           
           customTest("ifeq test", self, {
               evalExp(ifeq(.int(2), .int(2), .int(3), .int(4)))
           }, expected: .int(3))
           
           customTest("ifeq test", self, {
               evalExp(ifeq(.int(2), .int(1), .int(3), .int(4)))
           }, expected: .int(4))
           
           customTest("ifeq test", self, {
               evalExp(ifeq(.int(3), .int(2), .int(3), .int(4)))
           }, expected: .int(4))
           
           customTest("ifeq test", self, {
               evalExp(ifeq(.int(2), .int(3), .int(3), .int(4)))
           }, expected: .int(4))
           
           customTest("ifeq test", self, {
               evalExp(ifeq(.addE(.int(3), .int(1)), .addE(.int(2), .int(2)), .addE(.int(3), .int(2)), .int(4)))
           }, expected: .int(5))
       }
       
       func testMuplMap() {
           customTest("muplMap test", self, {
               evalExp(.call(.call(muplMap, .fun("#f", "x", .addE(.vaar("x"), .int(7)))), .apair(.int(1), .aunit(()))))
           }, expected: .apair(.int(8), .aunit(())))
       }
       
       func testMuplMapAddN() {
           customTestArray("combined test", self, {
               muplArrayToSwiftArray(evalExp(.call(.call(muplMapAddN, .int(7)),
                                                   swiftArrayToMuplArray([.int(3), .int(4), .int(9)]))))
           }, expected: [.int(10), .int(11), .int(16)])
       }
       
       func testComputeFreeVars() {
           customTest("compute-free-vars Variable Expression test", self, {
               computeFreeVars(.vaar("x"))
           }, expected: .vaar("x"))
           
           customTest("compute-free-vars Integer Expression test", self, {
               computeFreeVars(.int(5))
           }, expected: .int(5))
           
           customTest("compute-free-vars Addition Expression test", self, {
               computeFreeVars(.addE(.vaar("x"), .vaar("y")))
           }, expected: .addE(.vaar("x"), .vaar("y")))

           customTest("compute-free-vars Conditional (ifgreater) Expression test", self, {
               computeFreeVars(.ifgreater(.vaar("x"), .vaar("y"), .vaar("z"), .int(0)))
           }, expected: .ifgreater(.vaar("x"), .vaar("y"), .vaar("z"), .int(0)))
           
           customTest("compute-free-vars Function Expression with a Name test", self, {
               computeFreeVars(.fun("#f", "x", .addE(.vaar("x"), .vaar("y"))))
           }, expected: .funChallenge("#f", "x", .addE(.vaar("x"), .vaar("y")), ["y"]))
           
           customTest("compute-free-vars Function Expression with a Name test", self, {
               computeFreeVars(.fun("f", "x", .addE(.vaar("x"), .vaar("y"))))
           }, expected: .funChallenge("f", "x", .addE(.vaar("x"), .vaar("y")), ["y"]))
           
           customTest("compute-free-vars Function Call Expression test", self, {
               computeFreeVars(.call(.vaar("f"), .vaar("x")))
           }, expected: .call(.vaar("f"), .vaar("x")))
           
           customTest("compute-free-vars Let Binding (mlet) Expression test", self, {
               computeFreeVars(.mlet("y", .vaar("x"), .addE(.vaar("y"), .vaar("z"))))
           }, expected: .mlet("y", .vaar("x"), .addE(.vaar("y"), .vaar("z"))))
           
           customTest("compute-free-vars Pair Expression (apair) test", self, {
               computeFreeVars(.apair(.vaar("x"), .vaar("y")))
           }, expected: .apair(.vaar("x"), .vaar("y")))
           
           customTest("compute-free-vars First Element of a Pair (fst) test", self, {
               computeFreeVars(.fst(.vaar("p")))
           }, expected: .fst(.vaar("p")))
           
           customTest("compute-free-vars Second Element of a Pair (snd) test", self, {
               computeFreeVars(.snd(.vaar("p")))
           }, expected: .snd(.vaar("p")))
           
           customTest("compute-free-vars Unit Expression (aunit) test", self, {
               computeFreeVars(.aunit(()))
           }, expected: .aunit(()))
           
           customTest("compute-free-vars Is-a-Unit Check (isaunit) test", self, {
               computeFreeVars(.isaunit(.vaar("x")))
           }, expected: .isaunit(.vaar("x")))
           

           // The variables y and z are free because they are not bound by the function's formal parameter x or the function name f.
           customTest("Function with Multiple Free Variables", self, {
               computeFreeVars(.fun("f", "x", .addE(.vaar("x"), .addE(.vaar("y"), .vaar("z")))))
           }, expected: .funChallenge("f", "x", .addE(.vaar("x"), .addE(.vaar("y"), .vaar("z"))), ["y", "z"]))
           
           // The variable y is bound in the mlet expression, so it is not considered free in the body. However, x and z remain free.
           customTest("Let Binding with Free Variable Removal", self, {
               computeFreeVars(.mlet("y", .addE(.vaar("x"), .vaar("z")), .addE(.vaar("y"), .vaar("z"))))
           }, expected: .mlet("y", .addE(.vaar("x"), .vaar("z")), .addE(.vaar("y"), .vaar("z"))))
           
           // In the outer mlet, y is bound, so it isn't free in the inner expressions.
           // In the inner mlet, z is bound, so it isn't free in the body.
           // x and w remain free as they are not bound in any scope.
           customTest("Nested Let Bindings", self, {
               computeFreeVars(.mlet("y", .vaar("x"),
                                     .mlet("z", .addE(.vaar("y"), .vaar("w")),
                                           .addE(.vaar("x"), .vaar("z")))))
           }, expected: .mlet("y", .vaar("x"),
                              .mlet("z", .addE(.vaar("y"), .vaar("w")),
                                    .addE(.vaar("x"), .vaar("z")))))
           
           // The function itself has y as a free variable.
           // The function call has a and b as free variables from the argument.
           customTest("Function Call with Free Variables in Arguments", self, {
               computeFreeVars(.call(.fun("#f", "x", .addE(.vaar("x"), .vaar("y"))),
                                     .addE(.vaar("a"), .vaar("b"))))
           }, expected: .call(.funChallenge("#f", "x", .addE(.vaar("x"), .vaar("y")), ["y"]),
                             .addE(.vaar("a"), .vaar("b"))))
           
           // All variables x, y, f, and z are free in their respective sub-expressions and are unioned together.
           customTest("Pair Expression with Nested Free Variables", self, {
               computeFreeVars(.apair(.addE(.vaar("x"), .vaar("y")), .call(.vaar("f"), .vaar("z"))))
           }, expected: .apair(.addE(.vaar("x"), .vaar("y")), .call(.vaar("f"), .vaar("z"))))
           
           // z is bound in the mlet within the else branch of the ifgreater, so it's not free there.
           // x, y, and w remain free.
           customTest("Complex Ifgreater Expression", self, {
               computeFreeVars(.ifgreater(.vaar("x"), .int(0),
                                          .addE(.vaar("y"), .vaar("z")),
                                          .mlet("z", .vaar("x"), .vaar("w"))))
           }, expected: .ifgreater(.vaar("x"), .int(0),
                                   .addE(.vaar("y"), .vaar("z")),
                                   .mlet("z", .vaar("x"), .vaar("w"))))

           // g (the function's name) and x (the formal parameter) are bound and thus not free in the body.
           // z remains free since it is only bound within the mlet's right-hand side.
           customTest("Removal of Free Variables in Named Function", self, {
               computeFreeVars(.fun("g", "x",
                                    .mlet("y", .vaar("z"),
                                          .addE(.vaar("x"), .vaar("g")))))
           }, expected: .funChallenge("g", "x",
                                     .mlet("y", .vaar("z"), .addE(.vaar("x"), .vaar("g"))), ["z"]))
           
           customTest("Unit and Isaunit Combination", self, {
               computeFreeVars(.isaunit(.mlet("x", .aunit(()), .addE(.vaar("y"), .vaar("x")))))
           }, expected: .isaunit(.mlet("x", .aunit(()), .addE(.vaar("y"), .vaar("x")))))
       }
       
       func testEvalUnderEvnC() {
           customTest("Basic Integer", self, {
               evalExpC(.int(42))
           }, expected: .int(42))
           
           customTest("Variable Binding and Lookup", self, {
               evalExpC(.mlet("x", .int(10), .vaar("x")))
           }, expected: .int(10))

           customTest("Addition", self, {
               evalExpC(.addE(.int(3), .int(4)))
           }, expected: .int(7))
           
           customTest("If Greater (true branch)", self, {
               evalExpC(.ifgreater(.int(5), .int(3), .int(10), .int(0)))
           }, expected: .int(10))
           
           customTest("If Greater (false branch)", self, {
               evalExpC(.ifgreater(.int(2), .int(3), .int(10), .int(0)))
           }, expected: .int(0))
           
           customTest("Function Closure Pre-Transformation", self, {
               evalExpC(.fun("#f", "x", .addE(.vaar("x"), .int(5))))
           }, expected: .closure([], .funChallenge("#f", "x", .addE(.vaar("x"), .int(5)), [])))
           
           customTest("Function Closure Post-Transformation", self, {
               evalExpC(.fun("#f", "x", .addE(.int(3), .int(5))))
           }, expected: .closure([], .funChallenge("#f", "x", .addE(.int(3), .int(5)), [])))
           
           customTest("Function Call", self, {
               evalExpC(.call(.fun("#f", "x", .addE(.vaar("x"), .int(5))), .int(3)))
           }, expected: .int(8))
           
           customTest("Recursive Function", self, {
               evalExpC(.call(.fun("fact", "n", .ifgreater(.vaar("n"), .int(1),
                                                           .call(.vaar("fact"), .addE(.vaar("n"), .int(-1))),
                                                           .vaar("n"))), .int(3)))
           }, expected: .int(1))
           
           customTest("Let Binding", self, {
               evalExpC(.mlet("y", .int(5), .addE(.vaar("y"), .int(3))))
           }, expected: .int(8))
           
           customTest("Pair Creation", self, {
               evalExpC(.apair(.int(1), .int(2)))
           }, expected: .apair(.int(1), .int(2)))
           
           customTest("First of Pair", self, {
               evalExpC(.fst(.apair(.int(1), .int(2))))
           }, expected: .int(1))

           customTest("Second of Pair", self, {
               evalExpC(.snd(.apair(.int(1), .int(2))))
           }, expected: .int(2))
           
           customTest("Unit Value", self, {
               evalExpC(.aunit(()))
           }, expected: .aunit(()))
           
           customTest("IsAUnit (true case)", self, {
               evalExpC(.isaunit(.aunit(())))
           }, expected: .aunit(()))
           
           customTest("IsAUnit (false case)", self, {
               evalExpC(.isaunit(.int(42)))
           }, expected: .int(0))
       }
}
