import SwiftUI
import Speech

struct TranslationView: View {
    @State private var sourceLanguageIndex = 0
    @State private var targetLanguageIndex = 1
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var isListening = false
    @State private var audioEngine = AVAudioEngine()
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?

    let languages = ["English", "Spanish", "Turkish", "German", "Italian", "Russian", "Arabic", "Vietnamese"]
    let languageCodes = ["en", "es", "tr", "de", "it", "ru", "ar", "vi"]
    
    @State private var isPressed = false

    var body: some View {
        VStack {
            ZStack {
                Color("color")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack() {
                        Text("Text Translation")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        //                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        Spacer()
                        
                        Image(systemName: "bell.badge")
                            .padding()
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
                            ForEach(0..<languages.count, id: \.self) { index in
                                Text(languages[index])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                            .frame(width: 30.0)
                        
                        
                        Picker("Target Language", selection: $targetLanguageIndex) {
                            ForEach(0..<languages.count, id: \.self) { index in
                                Text(languages[index])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                    }
                    VStack {
                        Text("Translation From \(languages[sourceLanguageIndex])")
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
                                //                                Rectangle()
                                //                                    .foregroundColor(.clear)
                                //                                    .frame(width: 373, height: 1)
                                //                                    .background(.white.opacity(0.33))
                                HStack() {
                                    TextField("Enter Text", text: $inputText)
                                        .font(.title2)
                                        .frame(maxWidth: 300)
                                    
                                    Button(action: {
                                        self.isListening.toggle()
                                        if self.isListening {
                                            self.startListening()
                                        } else {
                                            self.stopListening()
                                        }
                                    }) {
                                        Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 20.0, height: 20.0)
                                    }
                                    
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Button(action: {
                        translationText()
                    }) {
                        Text("Translate")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color("black"), radius: 5, x: 5, y: 5)
                            .scaleEffect(isPressed ? 1.2 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        withAnimation {
                                            isPressed = true
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            isPressed = false
                                        }
                                        translationText()
                                    }
                            )
                    }
                    
                    
                    VStack {
                        Text("Translation To \(languages[targetLanguageIndex])")
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
                            TextField("Translated Text", text: $outputText)
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    func translationText() {
        let sourceLanguageCode = languageCodes[sourceLanguageIndex]
        let targetLanguageCode = languageCodes[targetLanguageIndex]
        
        translationWithAPI(inputText: inputText, sourceLanguage: sourceLanguageCode, targetLanguage: targetLanguageCode)
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
//        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=\(sourceLanguage)|\(targetLanguage)"
        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText)&langpair=\(sourceLanguage)|\(targetLanguage)"
        guard let url = URL(string: urlStr) else {
            outputText = "Invalid URL"
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.outputText = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["responseData"] as? [String: Any],
                   let translatedText = responseData["translatedText"] as? String {
                    DispatchQueue.main.async {
                        self.outputText = translatedText
                    }
                } else {
                    DispatchQueue.main.async {
                        self.outputText = "Translation not found."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.outputText = "JSON parsing error: \(error.localizedDescription)"
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

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.outputText = "Failed to set up audio session."
            }
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode // Directly using the inputNode as it's no longer optional
        
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
            var isFinal = false

            if let result = result {
                self.inputText = result.bestTranscription.formattedString
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
                self.outputText = "Audio engine could not start."
            }
        }
    }

    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
            .preferredColorScheme(.dark)
    }
}
