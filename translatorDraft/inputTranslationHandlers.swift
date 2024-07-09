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
                        viewModel.languageDirection.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.languageDirection ? "arrow.down" : "arrow.up")
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
                    newviewModel.isRecording.toggle()
                    if newviewModel.isRecording {
                        newviewModel.startRecording()
                    } else {
                        newviewModel.stopRecording()
                    }
                }) {
                    Image(systemName: newviewModel.isRecording ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(newviewModel.isRecording ? .green : .txtColors)
                }
                
                
                Button {
                    withAnimation {
                        viewModel.languageDirection.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.languageDirection ? "arrow.down" : "arrow.up")
                }
                .foregroundColor(.highlighting)
                .font(.system(size: 20))
                
                Button(action: viewModel.clearText) {
                    Image(systemName: "trash.circle")
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
