//
//  mainScreenForm.swift
//  translatorDraft
//
//  Created by Aman Sahu on 8/7/24.
//

import SwiftUI

struct mainScreenForm: View {
    @ObservedObject var freemodel = freeModel()
    @ObservedObject var voiceNote = VoiceRecording()
    @ObservedObject var firestoreManager = FirestoreManager()
    
    @AppStorage("selectedPlan") private var selectedPlan: String = "Free Plan"
    @AppStorage("languageDirection") var languageDirection: Bool = true
    @AppStorage("conversationNumber") private var conversationNumber: Int = 0
    
    @FocusState private var isFocused1: Bool
    @FocusState private var isFocused2: Bool
    @State private var inputText = ""
    @State private var outputText = ""
    
    let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Greek", "Turkish", "German", "Italian", "Russian", "Arabic"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50.0)
                            .fill(Color.btnColors)
                            .frame(maxWidth: 230, maxHeight: 60)
                        HStack {
                            Button(action: {
                                firestoreManager.createNewConversation { newNumber in
                                    if let newNumber = newNumber {
                                        self.conversationNumber = newNumber
                                    }
                                    print(self.conversationNumber)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "plus.square.on.square")
                                        .padding()
                                        .font(.system(size: 30))


                                }
                                Text("Conversation: \(conversationNumber)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    
                    // Doctor TextField (Language 1)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.textBoxColors)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.highlighting, lineWidth: 3)
                                    .opacity(languageDirection ? 0 : 1)
                            )
                            .animation(.easeInOut, value: languageDirection)
                        
                        
                        
                        VStack(alignment: .leading) {
                            Text("Doctor")
                                .padding([.top, .leading], 15.0)
                                .foregroundColor(.highlighting)
                                .fontWeight(.bold)
                            
                            Picker("DOCTOR LANGUAGE", selection: selectedPlan == "Free Plan" ? $freemodel.selectedSourceLanguage : $voiceNote.selectedSourceLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language)
                                        .foregroundColor(.highlighting)
                                }
                            }.tint(.langSelector)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(Color.color)
                            )
                            .padding(5.0)
                            
                            TextField("", text: $freemodel.inputText, axis: .vertical)
                                .lineLimit(7)
                                .padding(.leading)
                                .focused($isFocused1)
                        }
                        
                    }.overlay(
                        VStack() {
                            if isFocused1 {
                                Button("Done") {
                                    hideKeyboard()
                                    freemodel.translationText()
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 15)
                                .transition(.opacity)
                            }
                        }, alignment: .bottomTrailing
                    )
                    .padding()
                    
                    HStack{
                        Spacer()
                        Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 50.0)
                                .fill(Color.btnColors)
                                .frame(maxWidth: 60, maxHeight: 60)
                            
                            NavigationLink(destination: SettingScreen()) {
                                Image(systemName: "gearshape")
                                    .resizable(resizingMode: .tile)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.txtColors)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        ZStack {
                            Divider()
                            
                            RoundedRectangle(cornerRadius: 50.0)
                                .fill(Color.btnColors)
                                .frame(maxWidth: 210, maxHeight: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .stroke(Color.highlighting, lineWidth: 3)
                                        .opacity(freemodel.isListening ? 1 : 0)
                                )
                            
                            inputTranslationHandlers(freemodel: freemodel, voiceNote: voiceNote)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    
                    // Patient TextField (Language 2)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.textBoxColors)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.highlighting, lineWidth: 3)
                                    .opacity(languageDirection ? 1 : 0)
                            )
                            .animation(.easeInOut, value: languageDirection)
                        
                        VStack(alignment: .leading) {
                            Text("Patient")
                                .padding([.top, .leading], 15.0)
                                .foregroundColor(.highlighting)
                                .fontWeight(.bold)
                            
                            Picker("PATIENT LANGUAGE", selection: selectedPlan == "Free Plan" ? $freemodel.selectedTargetLanguage : $voiceNote.selectedTargetLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language)
                                }
                            }
                            .tint(.langSelector)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(Color.color)
                            )
                            .padding(5.0)
                            
                            
                            TextField("", text: $freemodel.outputText , axis: .vertical)
                                .lineLimit(7)
                                .padding(.leading)
                                .focused($isFocused2)
                        }
                    }.overlay(
                        VStack() {
                            if isFocused2 {
                                Button("Done") {
                                    hideKeyboard()
                                    freemodel.translationText()
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 15)
                                .transition(.opacity)
                            }
                        }, alignment: .topTrailing
                    )
                    .padding()
                }
            }
        }.tint(.highlighting) // for back buttons
        .navigationTitle("Home")
        .onAppear {
            firestoreManager.getCurrentConversation { number in
                if let number = number {
                    self.conversationNumber = number
                }
            }
        }
        
    }
    
    func hideKeyboard() {
        isFocused1 = false
        isFocused2 = false
    }
}

#Preview {
    mainScreenForm(freemodel: freeModel())
}
