//
//  ComfirmView.swift
//  CubeScene
//
//  Created by yanguo sun on 2024/8/2.
//

import Foundation
import SwiftUI
import SwiftUI
import Mixpanel

struct Question {
    let question: String
    let answer: String
}

struct ParentalGateView: View {
    @State private var userInput: String = ""
    @State private var showAlert: Bool = false
    @State private var currentQuestion: Question?
    
    var onCorrectAnswer: () -> Void
    
    private let questions: [Question] = [
        Question(question: "What is 7 + 5?", answer: "12"),
        Question(question: "What is 6 + 8?", answer: "14"),
        Question(question: "What is 9 + 3?", answer: "12"),
        Question(question: "What is 5 + 7?", answer: "12"),
        Question(question: "What is 4 + 6?", answer: "10"),
        Question(question: "What is 8 + 2?", answer: "10"),
        Question(question: "What is 3 + 7?", answer: "10"),
        Question(question: "What is 2 + 9?", answer: "11"),
        Question(question: "What is 5 + 6?", answer: "11"),
        Question(question: "What is 6 + 7?", answer: "13")
    ]
    
    var body: some View {
        VStack {
            Text("Parental Gate")
                .font(.largeTitle)
                .foregroundColor(Color.primary)  // 自动适应颜色
                .padding()
            Image(uiImage: UIImage(named: "Cube")!)
            if let currentQuestion = currentQuestion {
                Text(currentQuestion.question)
                    .font(.title2)
                    .foregroundColor(Color.primary)  // 自动适应颜色
                    .padding()
            }
            
            TextField("Enter your answer", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.primary)  // 自动适应颜色
                .keyboardType(.numberPad)
                .padding()
            
            Button(action: {
                verifyAnswer()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incorrect"), message: Text("Please try again."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))  // 使用系统颜色
        .cornerRadius(15)
        .shadow(radius: 10)
        .onAppear {
            selectRandomQuestion()
        }
    }
    
    private func selectRandomQuestion() {
        if let question = questions.randomElement() {
            currentQuestion = question
        }
    }
    
    private func verifyAnswer() {
        if userInput == currentQuestion?.answer {
            onCorrectAnswer()
        } else {
            showAlert = true
        }
    }
}


import SwiftUI

struct ConfirmView: View {
    @State private var showParentalGate: Bool = false
    @State private var navigateToRestrictedContent: Bool = false
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    NavigationLink(destination: RestrictedContentView(), isActive: $navigateToRestrictedContent) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        showParentalGate = true
                    }) {
                        Text("Access Restricted Content")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .fullScreenCover(isPresented: $showParentalGate) {
                    ParentalGateView(onCorrectAnswer: {
                        showParentalGate = false
                        navigateToRestrictedContent = true
                    })
                }
            }
        }
    }
}

struct RestrictedContentView: View {
    var body: some View {
        VStack {
            Text("Restricted Content")
                .font(.largeTitle)
                .padding()
            
            Text("This content is protected by a parental gate.")
                .font(.title2)
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView()
    }
}
