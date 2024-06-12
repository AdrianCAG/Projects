//
//  RunPythonScript.swift
//  SwiftPythonAddition
//
//  Created by Adrian on 6/13/24.
//

import Foundation
import PythonKit

struct RunPythonScript {
    private let file: PythonObject

    init() {
        let sys = Python.import("sys")
        
        // Access the PROJECT_DIR environment variable
        guard let projectDir = ProcessInfo.processInfo.environment["PROJECT_DIR"] else {
            fatalError("PROJECT_DIR environment variable not set")
        }
        
        // Construct the path to the Python script
        let scriptPath = "\(projectDir)/SwiftPythonAddition/"
    
        sys.path.append(scriptPath)
        file = Python.import("PythonScript")
    }

    func generateQuestion() -> (Int, Int) {
        let question = file.generate_question()
        let valueOne = Int(question[0])!
        let valueTwo = Int(question[1])!
        return (valueOne, valueTwo)
    }

    func checkAnswer(valueOne: Int, valueTwo: Int, userInput: Int) -> (Bool, Int) {
        let result = file.check_answer(valueOne, valueTwo, userInput)
        let isCorrect = Bool(result[0])!
        let expected = Int(result[1])!
        return (isCorrect, expected)
    }
}
