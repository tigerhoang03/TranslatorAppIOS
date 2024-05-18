import SwiftUI

struct TranslationView: View {
    @State private var sourceLanguageIndex = 0
    @State private var targetLanguageIndex = 1
    @State private var inputText = ""
    @State private var outputText = ""
    let languages = ["English", "Turkish", "German", "Spanish", "Italian", "Russian", "Arabic"]
    let languageCodes = ["en", "tr", "de", "es", "it", "ru", "ar"] // Corresponding language codes for API

    var body: some View {
        VStack {
            ZStack {
                Color("color") // Ensure you have this color defined in your asset catalog
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
                            ForEach(0..<languages.count, id: \.self) { index in
                                Text(languages[index])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        
                        Image(systemName: "arrow.left.arrow.right")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
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
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 373, height: 1)
                                    .background(.white.opacity(0.33))
                                    .offset(y: 55)
                                TextField("Enter Text", text: $inputText)
                                    .font(.title2)
                                    .offset(x: 45, y: -85)
                            }
                        }
                    }
                    Button("Translation", action: translationText)
                        .padding()
                    
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
        let sourceLanguageCode = languageCodes[sourceLanguageIndex]
        let targetLanguageCode = languageCodes[targetLanguageIndex]
        
        translationWithAPI(inputText: inputText, sourceLanguage: sourceLanguageCode, targetLanguage: targetLanguageCode)
    }
    
    func translationWithAPI(inputText: String, sourceLanguage: String, targetLanguage: String) {
        let urlStr = "https://api.mymemory.translated.net/get?q=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=\(sourceLanguage)|\(targetLanguage)"
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
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
            .preferredColorScheme(.dark)
    }
}
