//
//  testViewModel.swift
//  translatorDraft
//
//  Created by Andrew Hoang on 6/2/24.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

class testViewModel: ObservableObject {
    @Published var targetLanguageIndex = 1
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isListening = false
    @Published var audioEngine = AVAudioEngine()
    @Published var speechRecognizer = SFSpeechRecognizer()
    @Published var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @Published var recognitionTask: SFSpeechRecognitionTask?
    @Published var translatePressed = false
    @Published var clearPressed = false
    @Published var speechSynthesizer = AVSpeechSynthesizer()
    @Published var languageDirection = true
    @Published var sourceLanguageIndex = 0
//    @Published var sourceLanguageCode = ""
//    @Published var targetLanguageCode = ""

    @Published var selectedSourceLanguage = "English"
    @Published var selectedTargetLanguage = "Spanish"
    
    let emptyTranslation = "NO QUERY SPECIFIED. EXAMPLE REQUEST: GET?Q=HELLO&LANGPAIR=EN|IT"
    
    //let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Turkish", "German", "Italian", "Russian", "Arabic"]
    let language = ["English":"en", "Spanish":"es", "Hindi":"hi", "Vietnamese":"vi", "Turkish":"tr", "German":"de", "Italian":"it", "Russian":"ru", "Arabic":"ar"]
    
   public var sourceLanguageCode: String { languageDirection ? language[selectedSourceLanguage]! : language[selectedTargetLanguage]! }
   public var targetLanguageCode: String { languageDirection ? language[selectedTargetLanguage]! : language[selectedSourceLanguage]! }
    
    func translationText() {
        
        translationWithAPI(inputText: languageDirection ? inputText : outputText, sourceLanguage: sourceLanguageCode , targetLanguage:targetLanguageCode)
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
        let sourceLang1 = languageDirection ? sourceLanguage : targetLanguage
        let targetLang1 = languageDirection ? targetLanguage : sourceLanguage
        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText)&langpair=\(sourceLanguage)|\(targetLanguage)"
        
        print(urlStr)
        
        guard let url = URL(string: urlStr) else {
            if languageDirection {
                self.inputText = "Invalid URL"
            } else {
                self.outputText = "Invalid URL"
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    if self.languageDirection {
                        self.inputText = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                    } else {
                        self.outputText = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                    }
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["responseData"] as? [String: Any],
                   let translatedText = responseData["translatedText"] as? String {
                    print(translatedText) //translated output
                    DispatchQueue.main.async {
                        if translatedText == self.emptyTranslation && self.languageDirection == false {
                            self.inputText = "Empty Input. Please Translate Again"
                        } else if translatedText == self.emptyTranslation && self.languageDirection {
                            self.outputText = "Empty Input. Please Translate Again"
                        } else if self.languageDirection == false {
                            self.inputText = translatedText
                        } else {
                            self.outputText = translatedText
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if self.languageDirection == false {
                            self.inputText = "Translation not found."
                        } else {
                            self.outputText = "Translation not found."
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.inputText = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
    
    func startListening() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let localeIdentifier = sourceLanguageCode
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                if self.languageDirection {
                    self.outputText = "Failed to set up audio session."
                } else {
                    self.inputText = "Failed to set up audio session."
                }
            }
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode // Directly using the inputNode as it's no longer optional
        
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
            var isFinal = false

            if let result = result {
                if self.languageDirection {
                    self.inputText = result.bestTranscription.formattedString
                } else {
                    self.outputText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isListening = false
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            DispatchQueue.main.async {
                if self.languageDirection {
                    self.outputText = "Audio engine could not start."
                } else {
                    self.inputText = "Audio engine could not start."
                }
            }
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isListening = false
        // Ensure the text is retained after stopping the recognition
        if recognitionTask == nil {
            if languageDirection {
                inputText = inputText // Retain the transcribed text
            } else {
                outputText = outputText // Retain the transcribed text
            }
        }
    }
    
    func clearText() {
        inputText = ""
        outputText = ""
        
    }
    
    func speak(text: String, languageCode: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session category for playback: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.39
        
        speechSynthesizer.speak(utterance)
    }
}

struct testAudioTranslationHandler: View {
    @ObservedObject var viewModel: testViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.isListening.toggle()
                if viewModel.isListening {
                    viewModel.startListening()
                } else {
                    viewModel.stopListening()
                }
            }) {
                Image(systemName: viewModel.isListening ? "mic.circle.fill" : "mic.circle")
                    .padding()
                    .font(.system(size: 40))
                    .foregroundColor(viewModel.isListening ? .green : .white)
            }
            
            Button(action: {
                viewModel.speak(text: viewModel.languageDirection ? viewModel.outputText : viewModel.inputText, languageCode: viewModel.targetLanguageCode)
            }) {
                Image(systemName: "speaker.wave.2.circle")
                    .padding()
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            Button(action: {
                viewModel.translationText()
            }) {
                Text("Translate")
                    .padding()
                    .background(Color.btnColors)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .scaleEffect(viewModel.translatePressed ? 1.2 : 1.0)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    viewModel.translatePressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    viewModel.translatePressed = false
                                }
                                viewModel.translationText()
                            }
                    )
            }
        }
    }
}
