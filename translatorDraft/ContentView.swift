//
//  ContentView.swift
//  translatorDraft
//
//  Created by Andrew Hoang on 5/18/24.
//

import SwiftUI

struct ContentView: View {
    @State private var sourceLanguageIndex = 0
    @State private var targetLanguageIndex = 1
    @State private var inputText = ""
    @State private var outputText = ""
    let language = ["English", "Turkish", "German", "Spanish", "Italian", "Russian", "Arabic"]
    
    var body: some View {
        VStack {
            ZStack {
                Color("color")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("Text Translation")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                        
                        Image(systemName: "bell.badge")
                            .frame(width: 45, height: 45)
                            .foregroundColor(.white)
                    }
                    VStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 373, height: 1)
                            .background(.white.opacity(0.33))
                    }
                    HStack {
                        Picker("Source Language", selection: $sourceLanguageIndex) {
                            ForEach(0..<language.count, id: \.self) { index in
                                Text(language[index])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        
                        Image(systemName: "arrow.left.arrow.right")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Picker("Target Language", selection: $targetLanguageIndex) {
                            ForEach(0..<language.count, id: \.self) { index in
                                Text(language[index])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                    }
                    VStack {
                        Text("Translation From \(language[sourceLanguageIndex])")
                            .font(Font.custom("Inter", size: 17).weight(.light))
                            .foregroundColor(.white.opacity(0.43))
                            .padding()
                            .offset(x: -80)
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 373, height: 208)
                                .background(Color(red: 0.14, green: 0.15, blue: 0.15))
                                .cornerRadius(22)
                            VStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 373, height: 1)
                                    .background(.white.opacity(0.33))
                                    .offset(y: 55)
                                HStack {
                                    Button {
                                        // Button action
                                    } label: {
                                        Text("0/500")
                                            .font(Font.custom("Inter", size: 20))
                                            .foregroundColor(.white.opacity(0.43))
                                            .offset(x: -90, y: 60)
                                    }
                                    
                                    Button {
                                        // Button action
                                    } label: {
                                        Image(systemName: "pencil.line")
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(.white)
                                            .offset(x: -90, y: 60)
                                    }
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 1, height: 18.02776)
                                        .background(.white.opacity(0.43))
                                        .offset(x: 90, y: 60)
                                    
                                    Image(systemName: "speaker.wave.2.fill")
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.white)
                                        .offset(x: 100, y: 60)
                                }
                            }
                            TextField("Enter Text", text: $inputText)
                                .font(.title2)
                                .offset(x: 45, y: -85)
                        }
                    }
                    Button("Translation", action: translationText)
                        .padding()
                    
                    VStack {
                        Text("Translation To \(language[targetLanguageIndex])")
                            .font(Font.custom("Inter", size: 17).weight(.light))
                            .foregroundColor(.white.opacity(0.43))
                            .padding()
                            .offset(x: -80)
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 373, height: 208)
                                .background(Color(red: 0.14, green: 0.15, blue: 0.15))
                                .cornerRadius(22)
                            VStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 373, height: 1)
                                    .background(.white.opacity(0.33))
                                    .offset(y: 55)
                                HStack {
                                    Button {
                                        // Button action
                                    } label: {
                                        Text("0/500")
                                            .font(Font.custom("Inter", size: 20))
                                            .foregroundColor(.white.opacity(0.43))
                                            .offset(x: -90, y: 60)
                                    }
                                    
                                    Button {
                                        // Button action
                                    } label: {
                                        Image(systemName: "pencil.line")
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(.white)
                                            .offset(x: -90, y: 60)
                                    }
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 1, height: 18.02776)
                                        .background(.white.opacity(0.43))
                                        .offset(x: 90, y: 60)
                                    
                                    Image(systemName: "speaker.wave.2.fill")
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.white)
                                        .offset(x: 100, y: 60)
                                }
                            }
                            TextField("Enter Text", text: $outputText)
                                .font(.title2)
                                .foregroundColor(.white)
                                .offset(x: 45, y: -85)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    func translationText() {
        let sourceLanguage = language[sourceLanguageIndex]
        let targetLanguage = language[targetLanguageIndex]
        
        // API call
        translationWithAPI(inputText: inputText, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
        // Example translation with no API
        
        let translations = [
            "Merhaba": ["English": "Hello", "German": "Hallo"],
            "Nasilsin": ["English": "How Are You", "German": "Wie geht es dir"]
        ]
        if let translation = translations[inputText]?[targetLanguage] {
            outputText = translation
        } else {
            outputText = "Translation not found."
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
