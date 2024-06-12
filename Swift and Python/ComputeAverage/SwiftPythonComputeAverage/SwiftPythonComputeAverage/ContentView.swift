//
//  ContentView.swift
//  SwiftPythonComputeAverage
//
//  Created by Adrian on 6/12/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userInput = ""
    @State private var values: [Int] = []
    @State private var average: Double?
    private let runPythonScript = RunPythonScript()
    
    var body: some View {
            VStack {
                TextField("Add integer value: ", text: $userInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button {
                        if let intValue = Int(userInput) {
                            runPythonScript.insert(userInput: intValue)
                            values = runPythonScript.read()
                            userInput = ""
                        }
                    } label: {
                        Text("Insert Value")
                    }
                    
                    Button {
                        average = runPythonScript.compute()
                    } label: {
                        Text("Compute Average")
                    }
                }
                .padding()

                Text("You have inserted: \(values.count) values")
                
                if let average = average {
                    Text("Average: \(String(format: "%.1f", average))")
                }
            }
            .padding()
        }
    }

#Preview {
    ContentView()
}
