//
//  DynamicDispatchManually.swift
//  DynamicDispatchTest
//
//  Created by Adrian Ghita on 9/28/24.
//

import Foundation




// Somehow mimicking dynamic typing


struct Obj {
    var fields: [String: Any]
    var methods: [String: (inout Obj, Any...) -> Any]
    
    init(_ fields: [String : Any], _ methods: [String : (inout Obj, Any...) -> Any]) {
        self.fields = fields
        self.methods = methods
    }
}

func assocM(_ v: String, _ xs: [String:Any]) -> Any {
    if let value = xs[v] {
        return [v: value]
    } else {
        return false
    }
}

func get(_ obj: Obj, _ fld: String) -> Any {
    let pr = assocM(fld, obj.fields)
    if let pr = pr as? [String: Any], let value = pr.values.first {
        return value
    } else {
        fatalError("field not found")
    }
}

func set(_ obj: inout Obj, _ fld: Any, _ v: Any) {
    let pr = assocM(fld as! String, obj.fields)
    if let _ = pr as? [String: Any] {
        obj.fields[fld as! String] = v // Set the new value for the field
    } else {
        fatalError("field not found")
    }
}

@discardableResult
func send(_ obj: inout Obj, _ msg: String, _ args: Any...) -> Any {
    let pr = assocM(msg, obj.methods)
    if let pr = pr as? [String : (inout Obj, Any...) -> Any], let method = pr.values.first {
        return method(&obj, args)
    } else {
        fatalError("method not found \(msg)")
    }
}

func makePoint(_ _x: Any, _ _y: Any) -> Obj {
    return Obj(["x": _x, "y": _y],
               ["getX": { slf, _ in get(slf, "x") },
                "getY": { slf, _ in get(slf, "y") },
                "setX": { (slf: inout Obj, args: Any...) in set(&slf, "x", args[0]) },
                "setY": { (slf: inout Obj, args: Any...) in set(&slf, "y", args[0]) },
                // Simplified distToOrigin
                "distToOrigin": { (slf: inout Obj, args: Any...) in
                    let a = (send(&slf, "getX") as? Double) ?? Double(send(&slf, "getX") as! Int)
                    let b = (send(&slf, "getY") as? Double) ?? Double(send(&slf, "getY") as! Int)
                    return sqrt(a * a + b * b)
                }])
}

func makeColorPoint(_ _x: Int, _ _y: Int, _ _c: String) -> Obj{
    let pt = makePoint(_x, _y)
    return Obj(["color": _c].merging(pt.fields, uniquingKeysWith: { current, _ in current })
               ,
               ["getColor": { (slf: inout Obj, arg: Any...) in get(slf, "color") },
                "setColor": { (slf: inout Obj, arg: Any...) in set(&slf, "color", arg[0]) }].merging(pt.methods, uniquingKeysWith: { current, _ in current }))
}

func makePolarPoint(_ _r: Double, _ _th: Double) -> Obj {
    let pt = makePoint(false, false)
    return Obj(["r": _r,
                "theta": _th
               ].merging(pt.fields, uniquingKeysWith: { current, _ in current})
               ,
               ["setRTheta": { (slf: inout Obj, args: Any...) in
                                set(&slf, "r", args[0])
                                return set(&slf, "theta", Array(args[1...])[0]) },
                "getX": { (slf: inout Obj, args: Any...) in
                            let r = (get(slf, "r") as? Double) ?? Double(get(slf, "r") as! Int)
                            let theta = (get(slf, "theta") as? Double) ?? Double(get(slf, "theta") as! Int)
                            return r * cos(theta) },
                "getY": { (slf: inout Obj, args: Any...) in
                            let r = (get(slf, "r") as? Double) ?? Double(get(slf, "r") as! Int)
                            let theta = (get(slf, "theta") as? Double) ?? Double(get(slf, "theta") as! Int)
                            return r * sin(theta) },
                "setX": { (slf: inout Obj, args: Any...) in
                            let a = (args[0] as? Double) ?? Double(args[0] as! Int)
                            let b = send(&slf, "getY") as! Double
                            let theta = atan2(b, a)
                            let r = sqrt(a * a + b * b)
                            return send(&slf, "setRTheta", r, theta) },
                "setY": { (slf: inout Obj, args: Any...) in
                            let b = (args[0] as? Double) ?? Double(args[0] as! Int)
                            let a = send(&slf, "getX") as! Double
                            let theta = atan2(b, a)
                            let r = sqrt(a * a + b * b)
                            return send(&slf, "setRTheta", r, theta) },
               ].merging(pt.methods, uniquingKeysWith: { current, _ in current})
    )
}
