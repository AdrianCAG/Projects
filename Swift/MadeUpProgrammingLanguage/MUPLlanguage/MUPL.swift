//
//  MUPL.swift
//  MUPLtest
//
//  Created by Adrian Ghita on 8/18/24.
//

import Foundation





protocol MUPL: CustomStringConvertible {}


// definition of structures for MUPL programs - Do NOT change


// a variable, e.g., (var "foo")
struct vaar: MUPL {
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    var description: String {
        return "var(\(string))"
    }
}

//  a constant number, e.g., (int 17)
struct int: MUPL {
    let num: Int
    
    init(_ num: Int) {
        self.num = num
    }
    
    var description: String {
        return "int(\(num))"
    }
}

// add two expressions
struct addE: MUPL {
    let e1: MUPL
    let e2: MUPL
    
    
    init(_ e1: MUPL, _ e2: MUPL) {
        self.e1 = e1
        self.e2 = e2
    }
    
    var description: String {
        return "add(\(e1), \(e2))"
    }
}

// if e1 > e2 then e3 else e4
struct ifgreater: MUPL {
    let e1: MUPL
    let e2: MUPL
    let e3: MUPL
    let e4: MUPL

    init(_ e1: MUPL, _ e2: MUPL, _ e3: MUPL, _ e4: MUPL) {
        self.e1 = e1
        self.e2 = e2
        self.e3 = e3
        self.e4 = e4
    }
    
    var description: String {
        return "ifgreater(\(e1), \(e2), \(e3), \(e4))"
    }
}

// a recursive(?) 1-argument function
struct fun: MUPL {
    let nameopt: String
    let formal: String
    let body: MUPL
    
    init(_ nameopt: String, _ formal: String, _ body: MUPL) {
        self.nameopt = nameopt
        self.formal = formal
        self.body = body
    }
    
    var description: String {
        return "fun(\(nameopt), \(formal), \(body))"
    }
}

// function call
struct call: MUPL {
    let funexp: MUPL
    let actual: MUPL
    
    init(_ funexp: MUPL, _ actual: MUPL) {
        self.funexp = funexp
        self.actual = actual
    }
    
    var description: String {
        return "call(\(funexp), \(actual))"
    }
}

// a local binding (let var = e in body)
struct mlet: MUPL {
    let vaar: String
    let e: MUPL
    let body: MUPL
    
    init(_ vaar: String, _ e: MUPL, _ body: MUPL) {
        self.vaar = vaar
        self.e = e
        self.body = body
    }
    
    var description: String {
        return "mlet(\(vaar), \(e), \(body))"
    }
}

// make a new pair
struct apair: MUPL {
    let e1: MUPL
    let e2: MUPL
    
    init(_ e1: MUPL, _ e2: MUPL) {
        self.e1 = e1
        self.e2 = e2
    }
    
    var description: String {
        return "call(\(e1), \(e2))"
    }
}

// get first part of a pair
struct fst: MUPL {
    let e: MUPL
    
    init(_ e: MUPL) {
        self.e = e
    }
    
    var description: String {
        return "fst(\(e))"
    }
}

// get second part of a pair
struct snd: MUPL {
    let e: MUPL
    
    init(_ e: MUPL) {
        self.e = e
    }
    
    var description: String {
        return "snd(\(e))"
    }
}

// unit value -- good for ending a list
struct aunit: MUPL {
    var description: String {
        return "aunit()"
    }
}

// evaluate to 1 if e is unit else 0
struct isaunit: MUPL {
    let e: MUPL
    
    init(_ e: MUPL) {
        self.e = e
    }
    
    var description: String {
        return "isaunit(\(e))"
    }
}


protocol funProtocol: MUPL {}


// a closure is not in "source" programs but /is/ a MUPL value; it is what functions evaluate to
struct closure<T: funProtocol>: MUPL {
    let env: [(String, MUPL)]
    let fun: T
    
    init(_ env: [(String, MUPL)], _ fun: T) {
        self.env = env
        self.fun = fun
    }
    
    var description: String {
        return "closure(\(env), \(fun))"
    }
}



// MUPL custom tuple
prefix operator *
prefix func *<A, B>(pair: (A, B)) -> (A, B){
    return (pair.0, pair.1)
//    return MUPLTuple(first: pair.0, second: pair.1)
}





func swiftArrayToMuplArray(_ arr: [MUPL]) -> MUPL {
    if arr.isEmpty {
        return aunit()
    } else {
        return apair(arr.first!, swiftArrayToMuplArray(Array(arr[1...])))
    }
}


func muplArrayToSwiftArray(_ arr: MUPL) -> [MUPL] {
    if arr is aunit {
        return []
    } else if let arr = arr as? apair {
        return [arr.e1] + muplArrayToSwiftArray(arr.e2)
    } else {
        fatalError("Expected an apair, but got \(arr)")
    }
}


// lookup a variable in an environment
func envlookup(_ env: ArraySlice<(String, MUPL)>, _ str: String) -> MUPL {
    guard let firstPair = env.first else { fatalError("unbound variable during evaluation") }
    
    let (first, rest) = (firstPair.0, firstPair.1)
    
    if first == str {
        return rest
    } else {
        return envlookup(env.dropFirst(), str)
    }
}
 

// Overloaded version to allow initial call with full array
func envlookup(_ env: [(String, MUPL)], _ str: String) -> MUPL {
    return envlookup(env[...], str) // Pass the full array as a slice
}
 

func evalUnderEnv(_ e: MUPL, _ env: [(String, MUPL)] = []) -> MUPL {
    switch e {
    case let exp as vaar:
        return envlookup(env, exp.string)
        
    case _ as aunit, _ as int:
        return e
    
    case let exp as fun:
        return closure(env, exp)
    
    case _ as closure<fun>:
        return e
    
    case let exp as addE:
        guard let v1 = evalUnderEnv(exp.e1, env) as? int,
              let v2 = evalUnderEnv(exp.e2, env) as? int else {
            fatalError("MUPL addition applied to non-number")
        }
        return int(v1.num + v2.num)
    
    case let exp as ifgreater:
        guard let v1 = evalUnderEnv(exp.e1, env) as? int,
              let v2 = evalUnderEnv(exp.e2, env) as? int else {
            fatalError("MUPL ifgreater applied to non-number")
        }
        return evalUnderEnv(v1.num > v2.num ? exp.e3 : exp.e4, env)
    
    case let exp as mlet:
        let v1 = evalUnderEnv(exp.e, env)
        return evalUnderEnv(exp.body, [*(exp.vaar, v1)] + env)
    
    case let exp as call:
        let v1 = evalUnderEnv(exp.funexp, env)
        let v2 = evalUnderEnv(exp.actual, env)
        
        guard let closureValue = v1 as? closure<fun> else {
            fatalError("MUPL call applied to non-closure")
        }
        
        let funClosure = closureValue.fun
        let restEnv = (funClosure.nameopt != "#f") ? [*(funClosure.nameopt, v1)] + closureValue.env : closureValue.env
        let newEnv = [*(funClosure.formal, v2)] + restEnv
        return evalUnderEnv(funClosure.body, newEnv)
    
    case let exp as apair:
        let v1 = evalUnderEnv(exp.e1, env)
        let v2 = evalUnderEnv(exp.e2, env)
        return apair(v1, v2)
    
    case let exp as fst:
        guard let pairValue = evalUnderEnv(exp.e, env) as? apair else {
            fatalError("MUPL fst applied to non-pair")
        }
        return pairValue.e1
    
    case let exp as snd:
        guard let pairValue = evalUnderEnv(exp.e, env) as? apair else {
            fatalError("MUPL snd applied to non-pair")
        }
        return pairValue.e2
    
    case let exp as isaunit:
        let v = evalUnderEnv(exp.e, env)
        return int(v is aunit ? 1 : 0)
    
    default:
        fatalError("bad MUPL expression: \(e)")
    }
}


func evalExp(_ e: MUPL) -> MUPL {
    return evalUnderEnv(e)
}


func ifaunit(_ e1: MUPL, _ e2: MUPL, _ e3: MUPL) -> MUPL {
    ifgreater(isaunit(e1), int(0), e2, e3)
}


func mletStar(_ lstlst: [(String, MUPL)], _ e2: MUPL) -> MUPL {
    if lstlst.isEmpty {
        return e2
    } else {
        let v = lstlst.first!
        return mlet(v.0, v.1, mletStar(Array(lstlst.dropFirst()), e2))
    }
}


func ifeq(_ e1: MUPL, _ e2: MUPL, _ e3: MUPL, _ e4: MUPL) -> MUPL {
    return mletStar([*("_x", e1), *("_y", e2)],
                    ifgreater(vaar("_x"), vaar("_y"), e4,
                              ifgreater(vaar("_y"), vaar("_x"), e4, e3)))
}



let muplMap = {
    return fun("fun", "x", fun("funLst", "lst",
                              ifeq(isaunit(vaar("lst")), int(1), aunit(),
                                   apair(call(vaar("x"), fst(vaar("lst"))),
                                        call(vaar("funLst"), snd(vaar("lst")))))))
}()


let muplMapAddN = {
    return mlet("map", muplMap,
                fun("muplFunInt", "i",
                   fun("muplFunList", "mplInt",
                      call(call(vaar("map"), fun("addI", "x", addE(vaar("x"), vaar("i")))),
                          vaar("mplInt")))))
}()





// a recursive(?) 1-argument function
struct funChallenge: MUPL {
    let nameopt: String
    let formal: String
    let body: MUPL
    let freevars: Set<String>
    
    init(_ nameopt: String, _ formal: String, _ body: MUPL, _ freevars: Set<String>) {
        self.nameopt = nameopt
        self.formal = formal
        self.body = body
        self.freevars = freevars
    }
    
    var description: String {
        return "funChallenge(\(nameopt), \(formal), \(body), \(freevars))"
    }
}

func computeFreeVars(_ e: MUPL) -> MUPL {
    // result
    struct res: MUPL, CustomStringConvertible {
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
        case let exp as vaar:
            return res(e, Set([exp.string]))
        case _ as int:
            return res(e, [])
        case let exp as addE:
            let r1: res = f(exp.e1)
            let r2: res = f(exp.e2)
            return res(addE(r1.e, r2.e), r1.fvs.union(r2.fvs))
        case let exp as ifgreater:
            let r1: res = f(exp.e1)
            let r2: res = f(exp.e2)
            let r3: res = f(exp.e3)
            let r4: res = f(exp.e4)
            return res(ifgreater(r1.e, r2.e, r3.e, r4.e),
                       r1.fvs.union(r2.fvs).union(r3.fvs).union(r4.fvs))
        case let exp as fun:
            let r: res = f(exp.body)
            var fsv = r.fvs.subtracting([exp.formal])
            fsv = {
                if exp.nameopt != "#f" {
                    return fsv.subtracting([exp.nameopt])
                } else {
                    return fsv
                }
            }()
            return res(funChallenge(exp.nameopt, exp.formal, r.e, fsv), fsv)
        case let exp as call:
            let r1: res = f(exp.funexp)
            let r2: res = f(exp.actual)
            return res(call(r1.e, r2.e), r1.fvs.union(r2.fvs))
        case let exp as mlet:
            let r1 = f(exp.e)
            let r2 = f(exp.body)
            return res(mlet(exp.vaar, r1.e, r2.e),
                       r1.fvs.union(r2.fvs.subtracting([exp.vaar])))
        case let exp as apair:
            let r1 = f(exp.e1)
            let r2 = f(exp.e2)
            return res(apair(r1.e, r2.e),
                       r1.fvs.union(r2.fvs))
        case let exp as fst:
            let r = f(exp.e)
            return res(fst(r.e), r.fvs)
        case let exp as snd:
            let r = f(exp.e)
            return res(snd(r.e), r.fvs)
        case _ as aunit:
            return res(e, [])
        case let exp as isaunit:
            let r = f(exp.e)
            return res(isaunit(r.e), r.fvs)
        default:
            fatalError("bad MUPL expression: \(e)")
        }
    }
    
    return f(e).e
}


extension fun: funProtocol {}
extension funChallenge: funProtocol {}


func evalUnderEvnC(_ e: MUPL, _ env: [(String, MUPL)]) -> MUPL {
    switch e {
    case let exp as int:
        return exp
        
    case let exp as vaar:
        return envlookup(env, exp.string)
        
    case let exp as funChallenge:
        return closure(exp.freevars.map({ s in
            let newEnv = envlookup(env, s)
            return *(s, newEnv)
        }), exp)
        
    case let exp as addE:
        let lhs = evalUnderEvnC(exp.e1, env)
        let rhs = evalUnderEvnC(exp.e2, env)
        if let lhsInt = lhs as? int, let rhsInt = rhs as? int {
            return int(lhsInt.num + rhsInt.num)
        } else {
            fatalError("addE operands must be integers")
        }
        
    case let exp as call:
        let funExp = evalUnderEvnC(exp.funexp, env)
        let argVal = evalUnderEvnC(exp.actual, env)
        
        if let funClosure = funExp as? closure<funChallenge> {
            var extendedEnv = funClosure.env
            extendedEnv.append(*(funClosure.fun.formal, argVal))
            if funClosure.fun.nameopt != "#f" {
                extendedEnv.append(*(funClosure.fun.nameopt, funClosure))
            }
            return evalUnderEvnC(funClosure.fun.body, extendedEnv)
        } else {
            fatalError("call should be applied to a function closure")
        }
        
    case let exp as ifgreater:
        let e1 = evalUnderEvnC(exp.e1, env)
        let e2 = evalUnderEvnC(exp.e2, env)
        if let e1Int = e1 as? int, let e2Int = e2 as? int {
            if e1Int.num > e2Int.num {
                return evalUnderEvnC(exp.e3, env)
            } else {
                return evalUnderEvnC(exp.e4, env)
            }
        } else {
            fatalError("Non-integer values in ifgreater")
        }
        
    case let exp as mlet:
        let evalExp = evalUnderEvnC(exp.e, env)
        var newEnv = env
        newEnv.append(*(exp.vaar, evalExp))
        return evalUnderEvnC(exp.body, newEnv)
            
    case let exp as apair:
        let e1 = evalUnderEvnC(exp.e1, env)
        let e2 = evalUnderEvnC(exp.e2, env)
        return apair(e1, e2)
            
    case let exp as fst:
        let pairVal = evalUnderEvnC(exp.e, env)
        if let apairVal = pairVal as? apair {
            return apairVal.e1
        } else {
            fatalError("fst applied to non-pair")
        }
    
    case let exp as snd:
        let pairVal = evalUnderEvnC(exp.e, env)
        if let apairVal = pairVal as? apair {
            return apairVal.e2
        } else {
            fatalError("snd applied to non-pair")
        }
            
    case _ as aunit:
        return aunit()
        
    case let exp as isaunit:
        let evalExp = evalUnderEvnC(exp.e, env)
        return (evalExp is aunit) ? aunit() : int(0)
        
    default:
        fatalError("bad MUPL expression: \(e)")
    }
}


func evalExpC(_ e: MUPL) -> MUPL {
    evalUnderEvnC(computeFreeVars(e), [])
}

