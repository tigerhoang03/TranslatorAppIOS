import SwiftUI



/**
 The `mainScreen` struct represents the main user interface of the translation app.
 It provides fields for input and output text, language selection, and controls for translation and settings navigation.

 This view is designed to work with two `ObservableObject`s: `freeModel` and `VoiceRecording`.
 */
struct mainScreen: View {
    @ObservedObject var freemodel = freeModel()
    @ObservedObject var voiceNote = VoiceRecording()
    
    @AppStorage("selectedPlan") private var selectedPlan: String = "Free Plan"
    @AppStorage("languageDirection") var languageDirection: Bool = true
    
    
    @FocusState private var isFocused1: Bool
    @FocusState private var isFocused2: Bool
    @State private var inputText = ""
    @State private var outputText = ""
    
    // Supported Langauges
    let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Greek", "Turkish", "German", "Italian", "Russian", "Arabic"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    // First TextField (Language 1)
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
                            Picker("FIRST LANGUAGE", selection: selectedPlan == "Free Plan" ? $freemodel.selectedSourceLanguage : $voiceNote.selectedSourceLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language)
                                        .foregroundColor(.highlighting)
                                }
                            }.tint(.langSelector)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(Color.color)
                            )
                            .padding([.top, .leading], 10.0)
                            
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
                        ZStack{
                            RoundedRectangle(cornerRadius: 50.0)
                                .fill(Color.btnColors)
                                .frame(maxWidth: 60, maxHeight: 60)
                            
                            NavigationLink(destination: AboutScreen()) {
                                Image(systemName: "info.circle")
                                    .resizable(resizingMode: .tile)
                                    .foregroundColor(.txtColors)
                                    .frame(width: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/)
                            }
                        }
                        Spacer()
                        Spacer()
                    }
                    
                    // Second TextField (Language 2)
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
                            Picker("SECOND LANGUAGE", selection: selectedPlan == "Free Plan" ? $freemodel.selectedTargetLanguage : $voiceNote.selectedTargetLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language)
                                }
                            }
                            .tint(.langSelector)
                            .background(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(Color.color)
                            )
                            .padding([.top, .leading], 10.0)
                            
                            
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
        
    }
    
    func hideKeyboard() {
        isFocused1 = false
        isFocused2 = false
    }
}

#if canImport(UIKit)
extension View {
    /**
     An extension to hide the keyboard in iOS applications.
     */
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    mainScreen(freemodel: freeModel())
}
