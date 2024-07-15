//
//  inputTranslationHandlers.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import Foundation
import SwiftUI

struct inputTranslationHandlers: View {
    @AppStorage("selectedPlan") private var selectedPlan: String = ""
    @AppStorage("languageDirection") var languageDirection: Bool = true
    
    @AppStorage("continueConversation") var continueConversation: Bool = false
    
    @ObservedObject var viewModel: mainViewModel
    @ObservedObject var newviewModel: premiumViewModel

    var body: some View {
        if selectedPlan == "Free Plan" {
            HStack {
                Button(action: {
                    viewModel.isListening.toggle()
                    if viewModel.isListening {
                        viewModel.clearText()
                        viewModel.startListening()
                    } else {
                        viewModel.stopListening()
                        viewModel.translationText()
                        
                    }
                }) {
                    Image(systemName: viewModel.isListening ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(viewModel.isListening ? .green : .txtColors)
                }
                
                
                Button {
                    withAnimation {
                        languageDirection.toggle()
                    }
                } label: {
                    Image(systemName: languageDirection ? "arrow.down" : "arrow.up")
                }
                .foregroundColor(.highlighting)
                .font(.system(size: 20))
                
                
                Button(action: viewModel.clearText) {
                    Image(systemName: "trash.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(.txtColors)
                }
            }
        }
        
        else if selectedPlan == "Premium Plan" {
            HStack {
                Button(action: {
                    continueConversation.toggle()
                    if continueConversation {
                        newviewModel.conversation()
                    }
                    else {
                        print("Variable is false")
                    }
                    print(continueConversation)
                }) {
                    Image(systemName: continueConversation ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(continueConversation ? .green : .txtColors)
                }
                
                
                Button {
                    withAnimation {
                        languageDirection.toggle()
                    }
                } label: {
                    Image(systemName: languageDirection ? "arrow.down" : "arrow.up")
                }
                .foregroundColor(.highlighting)
                .font(.system(size: 20))
                
                Button(action: {
                    continueConversation = false
                    print(continueConversation)
                    print(newviewModel.continueConversation)
                }) {
                    Image(systemName: continueConversation ? "stop.circle" : "stop.circle.fill")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(.txtColors)
                }
                
//                Button(action: newviewModel.getAudioInfo) {
//                    Image(systemName: "questionmark.circle")
//                        .padding()
//                        .font(.system(size: 40))
//                        .foregroundColor(.txtColors)
//                }
//                
//                Button(action: {
//                    if let audioData = newviewModel.audioFileToArray() {
//                        print(audioData)
//                    }
//                }) {
//                    Image(systemName: "questionmark.diamond")
//                        .padding()
//                        .font(.system(size: 40))
//                        .foregroundColor(.txtColors)
//                }

            }
        }
    }
}
