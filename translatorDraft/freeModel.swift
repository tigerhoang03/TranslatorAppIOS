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

class freeModel: ObservableObject {
    @ObservedObject var firestoreManager = FirestoreManager()
    let fileHandler = TextFileHandler()
    
    @AppStorage("languageDirection") var languageDirection: Bool = true
    @AppStorage("conversationNumber") private var conversationNumber: Int = 0
    
    @Published var targetLanguageIndex = 1
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isListening = false
    @Published var isSpeaking = false // not being used
    @Published var audioEngine = AVAudioEngine()
    @Published var speechRecognizer = SFSpeechRecognizer()
    @Published var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @Published var recognitionTask: SFSpeechRecognitionTask?
    @Published var translatePressed = false
    @Published var clearPressed = false
    @Published var speechSynthesizer = AVSpeechSynthesizer()
    
    @Published var sourceLanguageIndex = 0

    @Published var selectedSourceLanguage = "English"
    @Published var selectedTargetLanguage = "Spanish"
    
    let emptyTranslation = "NO QUERY SPECIFIED. EXAMPLE REQUEST: GET?Q=HELLO&LANGPAIR=EN|IT"
    
    let language = ["English":"en", "Spanish":"es", "Hindi":"hi", "Vietnamese":"vi", "Greek":"el","Turkish":"tr", "German":"de", "Italian":"it", "Russian":"ru", "Arabic":"ar"]
    
    //the correct source and target language will always be selected 
   public var sourceLanguageCode: String { languageDirection ? language[selectedSourceLanguage]! : language[selectedTargetLanguage]! }
   public var targetLanguageCode: String { languageDirection ? language[selectedTargetLanguage]! : language[selectedSourceLanguage]! }
    
    func translationText() {
        translationWithAPI(inputText: languageDirection ? inputText : outputText, sourceLanguage: sourceLanguageCode , targetLanguage:targetLanguageCode)
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
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
                    print(translatedText) // translated text output
                    
                    DispatchQueue.main.async {
                        if translatedText == self.emptyTranslation && self.languageDirection == false {
                            self.inputText = "Empty Input. Please Translate Again"
                            self.speak(text: "Empty Input. Please Translate Again", languageCode: self.targetLanguageCode)
                        } else if translatedText == self.emptyTranslation && self.languageDirection {
                            self.outputText = "Empty Input. Please Translate Again"
                            self.speak(text: "Empty Input. Please Translate Again", languageCode: self.targetLanguageCode)
                        } else if self.languageDirection == false {
                            self.inputText = translatedText
                            self.speak(text: translatedText, languageCode: self.targetLanguageCode)
                        } else {
                            self.outputText = translatedText
                            self.speak(text: translatedText, languageCode: self.targetLanguageCode)
                        }
                        
                        self.languageDirection.toggle()
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
        
        if recognitionTask == nil {
            if languageDirection {
                self.inputText = inputText
            } else {
                self.outputText = outputText
            }
        }
    }
    
    func clearText() {
        self.inputText = ""
        self.outputText = ""
    }
    
    func writePatientTranslation(data: String) {
        let patientFileURL = fileHandler.createFileURL(fileName: "patient.txt")
        if fileHandler.appendTextToFile(text: data, fileURL: patientFileURL) {
          print("Text appended successfully!")
        } else {
          print("Error appending text to file.")
        }
    }
    
    func sendPatientTranslation() {
        let patientFileURL = fileHandler.createFileURL(fileName: "patient.txt")

        do {
            let data = try String(contentsOf: patientFileURL, encoding: .utf8)

            let fileTranslationData: [String: Any] = [
                "value": data
            ]
            firestoreManager.addDataToConversation(data: fileTranslationData, conversationNumber: conversationNumber)
            
        } catch {
            print("Error reading file: \(error)")
        }
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
