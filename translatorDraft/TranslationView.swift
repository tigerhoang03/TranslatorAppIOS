import SwiftUI
import Speech
import AVFoundation

struct TranslationView: View {
    @State private var sourceLanguageIndex = 0
    @State private var targetLanguageIndex = 1
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var tempBox = ""
    @State private var isListening = false
    @State private var audioEngine = AVAudioEngine()
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var translatePressed = false
    @State private var clearPressed = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var languageDirection = true
    @State private var showStroke1 = false
    @State private var showStroke2 = false
    
    let emptyTranslation = "NO QUERY SPECIFIED. EXAMPLE REQUEST: GET?Q=HELLO&LANGPAIR=EN|IT"

    let languages = ["English", "Spanish", "Vietnamese", "Turkish", "German", "Italian", "Russian", "Arabic"]
    let languageCodes = ["en", "es", "vi", "tr", "de", "it", "ru", "ar"]
    

    var body: some View {
        VStack {
            ZStack {
                    Color(#colorLiteral(red: 0.3843, green: 0.4471, blue: 0.3294, alpha: 1))
                    .edgesIgnoringSafeArea(.all)
                VStack() {
                    HStack() {
                        Text("Communicator")
                            .font(.system(size: 29))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                            
                        
                        
                        Image(systemName: "bell.badge")
                            .padding()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            clearText()
                        }) {
                            Text("Clear")
                                .padding()
                                .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                                .scaleEffect(clearPressed ? 1.2 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            withAnimation {
                                                clearPressed = true
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                clearPressed = false
                                            }
                                            clearText()
                                        }
                                )
                        }
                    }
                    VStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 373, height: 1)
                            .background(.white.opacity(0.33))
                    }
                    
                    HStack(alignment: .top, spacing: 30.0) {
                        Picker("Source Language", selection: $sourceLanguageIndex) {
                                ForEach(0..<languages.count, id: \.self) { index in
                                    Text(languages[index])
                                }
                        }
                        .padding(/*@START_MENU_TOKEN@*/.all, 6.0/*@END_MENU_TOKEN@*/)
                        .pickerStyle(MenuPickerStyle())
                        .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                        .foregroundColor(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        
                        
                        Button(action: {
                            self.languageDirection.toggle()
                        }) {
                            Image(systemName: languageDirection ? "arrow.right" : "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                                .padding()
                                .frame(width: 50.0)
                                
                                
                        }
                        
                        
                        Picker("Target Language", selection: $targetLanguageIndex) {
                                ForEach(0..<languages.count, id: \.self) { index in
                                    Text(languages[index])
                                }
                        }
                        .padding(/*@START_MENU_TOKEN@*/.all, 6.0/*@END_MENU_TOKEN@*/)
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                            .foregroundColor(Color("color"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        .pickerStyle(MenuPickerStyle())
                        
                    }
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    VStack {
                        Text("Language 1: \(languages[sourceLanguageIndex])")
                            .font(Font.custom("Inter", size: 17).weight(.light))
                            .foregroundColor(.white.opacity(0.43))
//                            .padding()
                            .padding(/*@START_MENU_TOKEN@*/)
                            .offset(x: -90)
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 373, height: 208)
                                .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1)))
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white, lineWidth: 3)
                                        .opacity(showStroke1 ? 0 : 1)
                                    
                                )
                                .onChange(of: languageDirection) { newValue in
                                    if newValue {
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            showStroke1 = true
                                        }
                                    } else {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showStroke1 = false
                                        }
                                    }
                                }
                            
                            
                            VStack {
                                HStack {
                                    TextEditor(text: $inputText)
                                        .font(.title2)
                                        .frame(width: 360)
                                        .foregroundColor(Color.white)
                                        .scrollContentBackground(.hidden) // hides the default bg
                                        .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1) /* #76885b */)) // actual bg color to change
                                        .cornerRadius(10)
                                                                        
                                }
                                .overlay(
                                    Button(action: {
                                        self.speak(text: self.inputText, languageCode: self.languageCodes[self.sourceLanguageIndex])
                                    }) {
                                        Image(systemName: "speaker.wave.2")
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 25, height: 25)
                                            .aspectRatio(contentMode: .fit)
                                    }, alignment: .bottomTrailing

                                ).padding()
                            }
                            .padding([.trailing] , 10)
                        }
                    }
                    
                    HStack{
                        
                        Button(action: {
                            self.isListening.toggle()
                            print(isListening)
                            if self.isListening {
                                self.startListening()
                            } else {
                                self.stopListening()
                            }
                            
                        }) {
                            Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 40.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/40.0)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            translationText()
                        }) {
                            Text("Translate")
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                                .scaleEffect(translatePressed ? 1.2 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            withAnimation {
                                                translatePressed = true
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                translatePressed = false
                                            }
                                            translationText()
                                        }
                                )
                        }
                    }
                    .padding(/*@START_MENU_TOKEN@*/.horizontal, 50.0/*@END_MENU_TOKEN@*/)
                    
                    
                    VStack {
                        Text("Language 2: \(languages[targetLanguageIndex])")
                            .font(Font.custom("Inter", size: 17).weight(.light))
                            .foregroundColor(.white.opacity(0.43))
//                            .padding()
                            .padding(/*@START_MENU_TOKEN@*/.top/*@END_MENU_TOKEN@*/)
                            .offset(x: -90)
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 373, height: 208)
                                .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1)))
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white, lineWidth: 3)
                                        .opacity(showStroke2 ? 1 : 0)
                                )
                                .onChange(of: languageDirection) { newValue in
                                    if newValue {
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            showStroke2 = true
                                        }
                                    } else {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showStroke2 = false
                                        }
                                    }
                                }
                
                            
                            HStack{
                                TextEditor(text: $outputText)
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                                    .scrollContentBackground(.hidden) // hides the default bg
                                    .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1))) // actual bg color to change
                                    .cornerRadius(10)
                                
                            }.padding().overlay(
                                Button(action: {
                                    self.speak(text: self.outputText, languageCode: self.languageCodes[self.targetLanguageIndex])
                                }) {
                                    Image(systemName: "speaker.wave.2")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 25, height: 25)
                                        .aspectRatio(contentMode: .fit)
                                }
                                .padding([.bottom], 10),
                                alignment: .bottomTrailing
                            )
                            .padding([.trailing], 25) .padding([.bottom], 10)
                        }
                    }
                }
                
            }
        }
    }
    
    func translationText() {
        let sourceLanguageCode = languageDirection ? languageCodes[sourceLanguageIndex] : languageCodes[targetLanguageIndex]
        let targetLanguageCode = languageDirection ? languageCodes[targetLanguageIndex] : languageCodes[sourceLanguageIndex]
        
        translationWithAPI(inputText: languageDirection ? inputText : outputText, sourceLanguage: languageDirection ? sourceLanguageCode : targetLanguageCode, targetLanguage: languageDirection ? targetLanguageCode : sourceLanguageCode)
        
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
//        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=\(sourceLanguage)|\(targetLanguage)"
        let sourceLang1 = languageDirection ? sourceLanguage : targetLanguage
        let targetLang1 = languageDirection ? targetLanguage : sourceLanguage
        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText)&langpair=\(sourceLang1)|\(targetLang1)"
        
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
                    if languageDirection{
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
                    print(translatedText)
                    DispatchQueue.main.async {
                        if translatedText == emptyTranslation && languageDirection == false {
                            self.inputText = "Empty Input. Please Translate Again"
                        } else if translatedText == emptyTranslation && languageDirection {
                            self.outputText = "Empty Input. Please Translate Again"
                        } else if languageDirection == false {
                            self.inputText = translatedText
                        } else {
                            self.outputText = translatedText
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if languageDirection == false {
                            self.inputText = "Translation not found."
                        }
                        else {
                            self.outputText = "Translation not found."
                        }
                        
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.tempBox = "JSON parsing error: \(error.localizedDescription)"
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
                if languageDirection {
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
                if languageDirection {
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
                if languageDirection {
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
        isListening = false
    }
    
    func clearText() {
        inputText = ""
        outputText = ""
    }
    
    func speak(text: String, languageCode: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.5

        speechSynthesizer.speak(utterance)
    }

}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
            .preferredColorScheme(.dark)
    }
}

