//
//  inputTranslationHandlers.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import Foundation
import SwiftUI

class Conversation: ObservableObject {
    var voiceNote: VoiceRecording? = VoiceRecording()
    var timer: Timer?
    @AppStorage("languageDirection") var languageDirection: Bool = true
    @AppStorage("continueConversation") var continueConversation: Bool = false
        
        func startConversation() {
            print("Started recording Conversation")
            DispatchQueue.global().async {
                while self.continueConversation {
                    DispatchQueue.main.async {
                        self.voiceNote?.startRecording {
                            print(self.continueConversation ? "Continuing" : "Exiting")
                            self.voiceNote?.getAudioInfo()
                            //implement grab languages
                            //implement send audio array
                            guard self.continueConversation else { return }
                        }
                        self.languageDirection.toggle()
                        print(Thread.isMainThread)
                    }
    
    
                    Thread.sleep(forTimeInterval: 1.0)
                }
            }
        }
    
        func stopConversation() {
            continueConversation = false
            print("Conversation has been stopped")
        }
        
        //    func startConversation() {
        //        DispatchQueue.global().async {
        //            while self.continueConversation {
        //                DispatchQueue.main.async {
        //                    self.voiceNote?.startRecording {
        //                        print("Started recording conversation")
        //                        self.voiceNote?.getAudioInfo()
        //                        self.languageDirection.toggle()
        //                        guard self.continueConversation else { return }
        //                        print(self.continueConversation ? "Continuing" : "Exiting")
        //                    }
        //                }
        //                // Sleep for a short duration to prevent tight looping
        //                Thread.sleep(forTimeInterval: 1.0)
        //            }
        //        }
        //    }
        //
        //    func stopConversation() {
        //        self.continueConversation = false
        //        print("Conversation stopped")
        //    }
        
        //    deinit {
        //        // imcomplete
        //        print("ConversationHandler deinitialized")
        //    }
    }
    
    
    struct inputTranslationHandlers: View {
        @AppStorage("selectedPlan") private var selectedPlan: String = ""
        @AppStorage("languageDirection") var languageDirection: Bool = true
        @AppStorage("continueConversation") var continueConversation: Bool = false
        
        @ObservedObject var viewModel: mainViewModel
        
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
                    var conversation: Conversation? = Conversation()
                    
                    Button(action: {
                        continueConversation.toggle()
                        if continueConversation {
                            conversation?.startConversation()
                        }
                        else {
                            conversation?.stopConversation()
                            conversation = nil
                        }
                        
                    }) {
                        Image(systemName: "mic.circle")
                            .padding()
                            .font(.system(size: 40))
                            .foregroundColor(continueConversation ? .green : .txtColors)
                            .opacity(continueConversation ? 0.0 : 1.0)
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
                        conversation?.stopConversation()
                        conversation = nil
                    }) {
                        Image(systemName: continueConversation ? "stop.circle" : "stop.circle.fill")
                            .padding()
                            .font(.system(size: 40))
                            .foregroundColor(.txtColors)
                            .opacity(continueConversation ? 1.0 : 0)
                    }
                    
                }
            }
        }
    }