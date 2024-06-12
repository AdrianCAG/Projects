//
//  RunPythonScript.swift
//  SwiftPythonComputeAverage
//
//  Created by Adrian on 6/12/24.
//

import Foundation
import PythonKit



protocol PythonProject {
    func compute() -> Double
    func insert(userInput: Int)
    func read() -> [Int]
}


struct RunPythonScript: PythonProject {
    private let file: PythonObject
    
    init() {
        let sys = Python.import("sys")
        
        // Access the PROJECT_DIR environment variable
        guard let projectDir = ProcessInfo.processInfo.environment["PROJECT_DIR"] else {
            fatalError("PROJECT_DIR environment variable not set")
        }
        
        // Construct the path to the Python script
        let scriptPath = "\(projectDir)/SwiftPythonComputeAverage/"
    
        sys.path.append(scriptPath)
        file = Python.import("PythonScript")
    }
    
    func compute() -> Double {
        let result = file.compute_average()
        return Double(result)!
    }
    
    func insert(userInput: Int) {
        file.insert(userInput)
    }
    
    func read() -> [Int] {
        let result = file.lst_of_variable
        return Array(result)!
    }
}
