//
//  ContentView.swift
//  SwiftPythonAddition
//
//  Created by Adrian on 6/13/24.
//

import SwiftUI


struct ContentView: View {
    @State private var valueOne = 0
    @State private var valueTwo = 0
    @State private var userInput = ""
    @State private var message = ""
    @State private var correctCount = 0
    @State private var showAlert = false
    @State private var isGameWon = false
    @State private var isSubmited = true
    
    private let runPythonScript = RunPythonScript()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Addition")
                .font(.system(size: 50))
                .fontDesign(.serif)
                .bold()
                .padding(.top, 20)
            
            Spacer(minLength: 50)
            
            Text("What is \(valueOne) + \(valueTwo)?")
                .font(.title)
            
            TextField("Your answer", text: $userInput)
                .padding()
                .border(Color.gray, width: 1)
                .padding()
            
            Button(action: {
                isSubmited = false
                
                if let userAnswer = Int(userInput) {
                    let (isCorrect, expected) = runPythonScript.checkAnswer(valueOne: valueOne, valueTwo: valueTwo, userInput: userAnswer)
                    if isCorrect {
                        correctCount += 1
                        message = "Correct! You've gotten \(correctCount) correct in a row."
                        if correctCount == 3 {
                            message = "Congratulations! You mastered addition."
                            showAlert = true // Show the alert for winning
                            isGameWon = true
                        }
                    } else {
                        correctCount = 0
                        message = "Incorrect. The expected answer is \(expected)."
                        showAlert = true // Show the alert for incorrect answer
                    }
                }
            }) {
                Label("Submit", systemImage: "square.and.arrow.up.fill")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.blue)
                    
            }.disabled(!(!isGameWon && isSubmited)) // Disable button when game is won
        
            Button(action: {
                isSubmited = true
                nextQuestion()
            }) {
                Label("New Question", systemImage: "rectangle.portrait.and.arrow.forward.fill")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.green)
                    .cornerRadius(8)
                    
            }.disabled(isGameWon) // Disable button when game is won
            
            
            Button(action: {
                resetGame()
            }) {
                Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.red)
                    
            }.disabled(correctCount != 3) // Disable reset button unless 3 correct answers are achieved
            
            Text(message)
                .padding()
            
            Spacer()
            
            // Display correct count if more than 0
            if correctCount > 0 {
                Text("Consecutive Correct Answers: \(correctCount)")
                    .padding()
            }
        }
        .padding()
        .frame(width: 400, height: 600)
        .onAppear {
            nextQuestion() // Load the first question
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Result"), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to load the next question
    private func nextQuestion() {
        let question = runPythonScript.generateQuestion()
        valueOne = question.0
        valueTwo = question.1
        userInput = ""
        message = ""
    }
    
    // Function to reset the game
    private func resetGame() {
        correctCount = 0
        isGameWon = false
    }
}

#Preview {
    ContentView()
}
