//
//  inputTranslationHandlers.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import Foundation
import SwiftUI

class Conversation: ObservableObject {
    private var voiceNote: VoiceRecording? = VoiceRecording()
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
//                    self.languageDirection.toggle()
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
    
    //do not change, required for text in main screen
    @ObservedObject var freemodel: freeModel
    
    @ObservedObject var voiceNote: VoiceRecording
    
    var body: some View {
        if selectedPlan == "Free Plan" {
            HStack {
                Button(action: {
                    freemodel.isListening.toggle()
                    if freemodel.isListening {
                        freemodel.clearText()
                        freemodel.startListening()
                    } else {
                        freemodel.stopListening()
                        freemodel.translationText()
                        
                    }
                }) {
                    Image(systemName: freemodel.isListening ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(freemodel.isListening ? .green : .txtColors)
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
                
                
                Button(action: freemodel.clearText) {
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
                    voiceNote.isRecordingVoice.toggle()
                    if voiceNote.isRecordingVoice {
                        voiceNote.startRecording() {
                            print("Stopping Recording...")
                            voiceNote.getAudioInfo()
                            voiceNote.translationAudioFile()
                            languageDirection.toggle()
                        }
                    }
                    else {
                        voiceNote.stopRecording()
                        voiceNote.getAudioInfo()
//                            conversation = nil
                    }
                    
                }) {
                    Image(systemName: voiceNote.isRecordingVoice ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(voiceNote.isRecordingVoice ? .green : .txtColors)
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
                
            }
        }
    }
}
