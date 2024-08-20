//
//  MUPL.swift
//  testMUPL
//
//  Created by Adrian Ghita on 8/19/24.
//


import Foundation





indirect enum MUPL: CustomStringConvertible{
    // a variable, e.g., (var "foo")
    case vaar(String)
    //  a constant number, e.g., (int 17)
    case int(Int)
    // add two expressions
    case addE(MUPL, MUPL)
    // if e1 > e2 then e3 else e4
    case ifgreater(MUPL, MUPL, MUPL, MUPL)
    // a recursive(?) 1-argument function
    case fun(String, String, MUPL)
    // function call
    case call(MUPL, MUPL)
    // a local binding (let var = e in body)
    case mlet(String, MUPL, MUPL)
    // make a new pair
    case apair(MUPL, MUPL)
    // get first part of a pair
    case fst(MUPL)
    // get second part of a pair
    case snd(MUPL)
    // unit value -- good for ending a list
    case aunit(())
    // evaluate to 1 if e is unit else 0
    case isaunit(MUPL)
    // a closure is not in "source" programs but /is/ a MUPL value; it is what functions evaluate to
    case closure([MUPLTuple<String, MUPL>], MUPL)
    // a recursive(?) 1-argument function
    case funChallenge(String, String, MUPL, Set<String>)
    
    var description: String {
         switch self {
         case .vaar(let name):
             return "var(\(name))"
         case .int(let num):
             return "int(\(num))"
         case .addE(let e1, let e2):
             return "add(\(e1), \(e2))"
         case .ifgreater(let e1, let e2, let e3, let e4):
             return "ifgreater(\(e1), \(e2), \(e3), \(e4))"
         case .fun(let nameopt, let formal, let body):
             return "fun(\(nameopt), \(formal), \(body))"
         case .call(let funexp, let actual):
             return "call(\(funexp), \(actual))"
         case .mlet(let vaar, let e, let body):
             return "mlet(\(vaar), \(e), \(body))"
         case .apair(let e1, let e2):
             return "pair(\(e1), \(e2))"
         case .fst(let e):
             return "fst(\(e))"
         case .snd(let e):
             return "snd(\(e))"
         case .aunit:
             return "unit"
         case .isaunit(let e):
             return "isaunit(\(e))"
         case .closure(let env, let fun):
             return "closure(\(env), \(fun))"
         case.funChallenge(let nameopt, let formal, let body, let freevars):
             return "funChallenge(\(nameopt), \(formal), \(body), \(freevars))"
         }
     }
}


struct MUPLTuple<A, B> {
    let first: A
    let second: B
}

// MUPL custom tuple
prefix operator *
prefix func *<A, B>(pair: (A, B)) -> MUPLTuple<A, B> {
    return MUPLTuple(first: pair.0, second: pair.1)
}



func swiftArrayToMuplArray(_ arr: [MUPL]) -> MUPL {
    if arr.isEmpty {
        return .aunit(())
    } else {
        return .apair(arr.first!, swiftArrayToMuplArray(Array(arr[1...])))
    }
}


func muplArrayToSwiftArray(_ arr: MUPL) -> [MUPL] {
    if case .aunit(_) = arr {
        return []
    } else if case .apair(let e1, let e2) = arr {
        return [e1] + muplArrayToSwiftArray(e2)
    } else {
        fatalError("Expected an apair, but got \(arr)")
    }
}


// lookup a variable in an environment
func envlookup(_ env: ArraySlice<MUPLTuple<String, MUPL>>, _ str: String) -> MUPL {
    guard let firstPair = env.first else { fatalError("unbound variable during evaluation") }
    
    let (first, rest) = (firstPair.first, firstPair.second)
    
    if first == str {
        return rest
    } else {
        return envlookup(env.dropFirst(), str)
    }
}
 

// Overloaded version to allow initial call with full array
func envlookup(_ env: [MUPLTuple<String, MUPL>], _ str: String) -> MUPL {
    return envlookup(env[...], str) // Pass the full array as a slice
}
 
func evalUnderEnv(_ e: MUPL, _ env: [MUPLTuple<String, MUPL>] = []) -> MUPL {
    switch e {
    case let .vaar(string):
        return envlookup(env, string)
        
    case .aunit, .int:
        return e
        
    case let .fun(nameopt, formal, body):
        return .closure(env, .fun(nameopt, formal, body))
        
    case let .closure(env, fun):
        return .closure(env, fun)
        
    case let .addE(e1, e2):
        guard case let .int(v1) = evalUnderEnv(e1, env),
              case let .int(v2) = evalUnderEnv(e2, env) else {
            fatalError("MUPL addition applied to non-number")
        }
        return .int(v1 + v2)
        
    case let .ifgreater(e1, e2, e3, e4):
        guard case let .int(v1) = evalUnderEnv(e1, env),
              case let .int(v2) = evalUnderEnv(e2, env) else {
            fatalError("MUPL ifgreater applied to non-number")
        }
        return evalUnderEnv(v1 > v2 ? e3 : e4, env)
        
    case let .mlet(vaar, e, body):
        let v1 = evalUnderEnv(e, env)
        return evalUnderEnv(body, [*(vaar, v1)] + env)
        
    case let .call(funexp, actual):
        let v1 = evalUnderEnv(funexp, env)
        let v2 = evalUnderEnv(actual, env)
        
        guard case let .closure(closureEnv, .fun(nameopt, formal, body)) = v1 else {
            fatalError("MUPL call applied to non-closure")
        }
        
        let restEnv = (nameopt != "#f") ? [*(nameopt, v1)] + closureEnv : closureEnv
        let newEnv = [*(formal, v2)] + restEnv
        return evalUnderEnv(body, newEnv)
        
    case let .apair(e1, e2):
        let v1 = evalUnderEnv(e1, env)
        let v2 = evalUnderEnv(e2, env)
        return .apair(v1, v2)
        
    case let .fst(e):
        guard case let .apair(e1, _) = evalUnderEnv(e, env) else {
            fatalError("MUPL fst applied to non-pair")
        }
        return e1
        
    case let .snd(e):
        guard case let .apair(_, e2) = evalUnderEnv(e, env) else {
            fatalError("MUPL snd applied to non-pair")
        }
        return e2
        
    case let .isaunit(e):
        let v = evalUnderEnv(e, env)
        switch v {
        case .aunit:
            return .int(1)
        default:
            return .int(0)
        }
        
    default:
        fatalError("bad MUPL expression: \(e)")
    }
        
}


func evalExp(_ e: MUPL) -> MUPL {
    return evalUnderEnv(e)
}


func ifaunit(_ e1: MUPL, _ e2: MUPL, _ e3: MUPL) -> MUPL {
    .ifgreater(.isaunit(e1), .int(0), e2, e3)
}


func mletStar(_ lstlst: [MUPLTuple<String, MUPL>], _ e2: MUPL) -> MUPL {
    if lstlst.isEmpty {
        return e2
    } else {
        let v: MUPLTuple = lstlst.first!
        return .mlet(v.first, v.second, mletStar(Array(lstlst.dropFirst()), e2))
    }
}


func ifeq(_ e1: MUPL, _ e2: MUPL, _ e3: MUPL, _ e4: MUPL) -> MUPL {
    return mletStar([*("_x", e1), *("_y", e2)],
                    .ifgreater(.vaar("_x"), .vaar("_y"), e4,
                               .ifgreater(.vaar("_y"), .vaar("_x"), e4, e3)))
}



let muplMap: MUPL = {
    return .fun("fun", "x", .fun("funLst", "lst",
                                 ifeq(.isaunit(.vaar("lst")), .int(1), .aunit(()),
                                      .apair(.call(.vaar("x"), .fst(.vaar("lst"))),
                                             .call(.vaar("funLst"), .snd(.vaar("lst")))))))
}()


let muplMapAddN: MUPL = {
    return .mlet("map", muplMap,
                 .fun("muplFunInt", "i",
                      .fun("muplFunList", "mplInt",
                           .call(.call(.vaar("map"), .fun("addI", "x", .addE(.vaar("x"), .vaar("i")))),
                                 .vaar("mplInt")))))
}()


func computeFreeVars(_ e: MUPL) -> MUPL {
    // result
    struct res: CustomStringConvertible {
        let e: MUPL
        let fvs: Set<String>
        
        init(_ e: MUPL, _ fvs: Set<String>) {
            self.e = e
            self.fvs = fvs
        }
        
        var description: String {
            return "funChallange(\(e), \(fvs))"
        }
    }
    
    func f(_ e: MUPL) -> res {
        switch e {
        case let .vaar(string):
            return res(e, Set([string]))
        case .int:
            return res(e, [])
        case let .addE(e1, e2):
            let r1: res = f(e1)
            let r2: res = f(e2)
            return res(.addE(r1.e, r2.e), r1.fvs.union(r2.fvs))
        case let .ifgreater(e1, e2, e3, e4):
            let r1: res = f(e1)
            let r2: res = f(e2)
            let r3: res = f(e3)
            let r4: res = f(e4)
            return res(.ifgreater(r1.e, r2.e, r3.e, r4.e),
                       r1.fvs.union(r2.fvs).union(r3.fvs).union(r4.fvs))
        case let .fun(nameopt, formal, body):
            let r: res = f(body)
            var fsv = r.fvs.subtracting([formal])
            fsv = {
                if nameopt != "#f" {
                    return fsv.subtracting([nameopt])
                } else {
                    return fsv
                }
            }()
            return res(.funChallenge(nameopt, formal, r.e, fsv), fsv)
        case let .call(funexp, actual):
            let r1: res = f(funexp)
            let r2: res = f(actual)
            return res(.call(r1.e, r2.e), r1.fvs.union(r2.fvs))
        case let .mlet(vaar, e, body):
            let r1 = f(e)
            let r2 = f(body)
            return res(.mlet(vaar, r1.e, r2.e),
                       r1.fvs.union(r2.fvs.subtracting([vaar])))
        case let .apair(e1, e2):
            let r1 = f(e1)
            let r2 = f(e2)
            return res(.apair(r1.e, r2.e),
                       r1.fvs.union(r2.fvs))
        case let .fst(e):
            let r = f(e)
            return res(.fst(r.e), r.fvs)
        case let .snd(e):
            let r = f(e)
            return res(.snd(r.e), r.fvs)
        case .aunit(()):
            return res(e, [])
        case let .isaunit(e):
            let r = f(e)
            return res(.isaunit(r.e), r.fvs)
        default:
            fatalError("bad MUPL expression: \(e)")
        }
    }
    
    return f(e).e
}



func evalUnderEvnC(_ e: MUPL, _ env: [MUPLTuple<String, MUPL>]) -> MUPL {
    switch e {
    case .int(_):
        return e
        
    case let .vaar(string):
        return envlookup(env, string)
        
    case let .funChallenge(_, _, _, freevars):
        return .closure(freevars.map({ s in
            let newEnv = envlookup(env, s)
            return *(s, newEnv)
        }), e)
        
    case let .addE(e1, e2):
        let lhs = evalUnderEvnC(e1, env)
        let rhs = evalUnderEvnC(e2, env)
        if case let .int(lhsNum) = lhs, case let .int(rhsNum) = rhs {
            return .int(lhsNum + rhsNum)
        } else {
            fatalError("addE operands must be integers")
        }
        
    case let .call(funexp, actual):
        let funExp = evalUnderEvnC(funexp, env)
        let argVal = evalUnderEvnC(actual, env)
        
        if case let .closure(closureEnv, .funChallenge(nameopt, formal, body, _)) = funExp {
            var extendedEnv = closureEnv
            extendedEnv.append(*(formal, argVal))
            if nameopt != "#f" {
                extendedEnv.append(*(nameopt, funExp))
            }
            return evalUnderEvnC(body, extendedEnv)
        } else {
            fatalError("call should be applied to a function closure")
        }
        
    case let .ifgreater(e1, e2, e3, e4):
        let evalE1 = evalUnderEvnC(e1, env)
        let evalE2 = evalUnderEvnC(e2, env)
        if case let .int(e1Num) = evalE1, case let .int(e2Num) = evalE2 {
            if e1Num > e2Num {
                return evalUnderEvnC(e3, env)
            } else {
                return evalUnderEvnC(e4, env)
            }
        } else {
            fatalError("Non-integer values in ifgreater")
        }
        
    case let .mlet(vaar, e, body):
        let evalExp = evalUnderEvnC(e, env)
        var newEnv = env
        newEnv.append(*(vaar, evalExp))
        return evalUnderEvnC(body, newEnv)
            
    case let .apair(e1, e2):
        let e1 = evalUnderEvnC(e1, env)
        let e2 = evalUnderEvnC(e2, env)
        return .apair(e1, e2)
            
    case let .fst(e):
        let pairVal = evalUnderEvnC(e, env)
        if case let .apair(e1, _) = pairVal {
            return e1
        }else {
            fatalError("fst applied to non-pair")
        }
        
    case let .snd(e):
        let pairVal = evalUnderEvnC(e, env)
        if case let .apair(_, e2) = pairVal {
            return e2
        } else {
            fatalError("snd applied to non-pair")
        }
            
    case .aunit(()):
        return .aunit(())
        
    case let .isaunit(e):
        let evalExp = evalUnderEvnC(e, env)
        if case .aunit = evalExp {
            return .aunit(())
        } else {
            return .int(0)
        }
        
    default:
        fatalError("bad MUPL expression: \(e)")
    }
}


func evalExpC(_ e: MUPL) -> MUPL {
    evalUnderEvnC(computeFreeVars(e), [])
}
