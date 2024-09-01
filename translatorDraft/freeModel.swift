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



/**
 The `freeModel` class is an `ObservableObject` that manages various functionalities related to speech recognition, text translation, and speech synthesis within the translator app. It interacts with Firebase, handles text file operations, and manages the audio engine for recording and playback.

 - Properties:
   - `firestoreManager`: An observed object managing interactions with Firebase Firestore.
   - `fileHandler`: An instance of `TextFileHandler` to manage file operations.
   - `languageDirection`: A boolean flag indicating the direction of translation (e.g., English to Spanish or vice versa).
   - `conversationNumber`: An integer to track the current conversation number.
   - `targetLanguageIndex`, `inputText`, `outputText`: Published properties for managing language indices and text input/output.
   - `isListening`, `isSpeaking`: Flags to manage the state of speech recognition and speech synthesis.
   - `audioEngine`: An instance of `AVAudioEngine` to manage audio input for speech recognition.
   - `speechRecognizer`, `recognitionRequest`, `recognitionTask`: Published properties to handle the speech recognition process.
   - `translatePressed`, `clearPressed`: Flags to track the state of translation and clear operations.
   - `speechSynthesizer`: An instance of `AVSpeechSynthesizer` for text-to-speech synthesis.
   - `sourceLanguageIndex`, `selectedSourceLanguage`, `selectedTargetLanguage`: Properties to manage language selection.
   - `emptyTranslation`: A constant string to indicate an empty translation request.
   - `language`: A dictionary mapping language names to their respective codes.
   - `sourceLanguageCode`, `targetLanguageCode`: Computed properties to determine the appropriate language codes for translation based on the `languageDirection`.

 - Methods:
   - `translationText()`: Initiates the translation process based on the current `inputText` or `outputText` and the selected languages.
   - `translationWithAPI(inputText:sourceLanguage:targetLanguage:)`: Calls an external translation API to translate the provided text and updates the UI accordingly.
   - `startListening()`: Starts the speech recognition process by configuring the audio session and setting up the speech recognizer.
   - `stopListening()`: Stops the speech recognition process and updates the state of the app.
   - `clearText()`: Clears the `inputText` and `outputText` properties.
   - `writeDoctorTranslation(data:)`: Appends translated text to a "doctor.txt" file.
   - `writePatientTranslation(data:)`: Appends translated text to a "patient.txt" file.
   - `sendTranslationToFirestore(user:)`: Sends the translated text to Firebase Firestore under the specified user's conversation.
   - `speak(text:languageCode:)`: Converts the given text to speech using the specified language code and plays it back.

 This class is central to the translator app's core functionality, managing both the input/output of translations and the corresponding audio processes.
 */
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

    // ensures the correct source and target language will always be selected
    public var sourceLanguageCode: String { languageDirection ? language[selectedSourceLanguage]! : language[selectedTargetLanguage]! }
    public var targetLanguageCode: String { languageDirection ? language[selectedTargetLanguage]! : language[selectedSourceLanguage]! }


    /**
     Initiates the translation process based on the current `inputText` or `outputText`
     and the selected source and target languages.
     */
    func translationText() {
        translationWithAPI(inputText: languageDirection ? inputText : outputText, sourceLanguage: sourceLanguageCode , targetLanguage:targetLanguageCode)
    }

    
    /**
     Calls an external translation API to translate the provided text and updates the UI accordingly.

     - Parameters:
        - inputText: The text to be translated.
        - sourceLanguage: The language code of the source language.
        - targetLanguage: The language code of the target language.
     */
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
                            self.writePatientTranslation(data: translatedText)
                            self.speak(text: translatedText, languageCode: self.targetLanguageCode)
                        } else {
                            self.outputText = translatedText
                            self.writeDoctorTranslation(data: translatedText)
                            self.speak(text: translatedText, languageCode: self.targetLanguageCode)
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

    
    /**
     Starts the speech recognition process by configuring the audio session,
     setting up the speech recognizer, and handling the input audio.
     
     This method prepares the audio engine for recording and starts listening to the user’s speech.
     It also processes and updates the transcription results in real-time.
     */
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

        let inputNode = audioEngine.inputNode
        
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
    
    
    /**
     Stops the speech recognition process and updates the state of the app.
     This method halts the audio engine, ends the recognition request, and clears the recognition task.
     */
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

    
    /**
     Clears the `inputText` and `outputText` properties.
     This method is typically called when the user wants to reset the translation fields.
     */
    func clearText() {
        self.inputText = ""
        self.outputText = ""
        print(languageDirection)
    }

    
    /**
     Appends translated text to a "doctor.txt" file.
     
     - Parameter data: The translated text to be written to the file.
     */
    func writeDoctorTranslation(data: String) {
        let patientFileURL = fileHandler.createFileURL(fileName: "doctor.txt")
        if fileHandler.appendTextToFile(text: data, fileURL: patientFileURL) {
          print("Text appended to doctor.txt successfully!")
        } else {
          print("Error appending text to doctor.txt.")
        }
    }

    
    /**
     Appends translated text to a "patient.txt" file.
     
     - Parameter data: The translated text to be written to the file.
     */
    func writePatientTranslation(data: String) {
        let patientFileURL = fileHandler.createFileURL(fileName: "patient.txt")
        if fileHandler.appendTextToFile(text: data, fileURL: patientFileURL) {
          print("Text appended to patient.txt successfully!")
        } else {
          print("Error appending text to patient.txt.")
        }
    }

    
    /**
     Sends the translated text to Firebase Firestore under the specified user's conversation.
     
     - Parameter user: The user whose conversation is being updated with the translated text.
     */
    func sendTranslationToFirestore(user: String) {
        let fileURL = fileHandler.createFileURL(fileName: "\(user).txt")

        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)

            let fileTranslationData: [String: Any] = [
                "value": data
            ]
            firestoreManager.addDataToConversation(data: fileTranslationData, conversationNumber: conversationNumber, user: user)
            
        } catch {
            print("Error reading file: \(error)")
        }
    }

    
    /**
     Converts the given text to speech using the specified language code and plays it back.
     
     - Parameters:
        - text: The text to be spoken.
        - languageCode: The language code for the speech synthesis voice.
     */
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
        self.languageDirection.toggle()
        
    }
}
