import SwiftUI

struct test: View {
    @ObservedObject var viewModel = testViewModel()
    
    @State private var selectedSourceLanguage = "English"
    @State private var selectedTargetLanguage = "Spanish"
    @FocusState private var isFocused: Bool
    @State private var inputText = ""
    @State private var outputText = ""
    
    let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Turkish", "German", "Italian", "Russian", "Arabic"]
    let language = ["English":"en", "Spanish":"es", "Hindi":"hi", "Vietnamese":"vi", "Turkish":"tr", "German":"de", "Italian":"it", "Russian":"ru", "Arabic":"ar"]
    
    //@State private var languageDirection = true // true means left language -> right language
    
//    var sourceLanguageCode: String { languageDirection ? language[selectedSourceLanguage]! : language[selectedTargetLanguage]! }
//    var targetLanguageCode: String { languageDirection ? language[selectedTargetLanguage]! : language[selectedSourceLanguage]! }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                HStack{
                    Spacer()
                    Text("Communicator")
                        .frame(width: 220, height: 50)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Image(systemName: "bell.badge")
                        .padding()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.white)
                    
                    Button(action: viewModel.clearText) {
                        Text("Clear")
                            .padding()
                            .background(Color.btnColors)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .scaleEffect(viewModel.clearPressed ? 1.2 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        withAnimation {
                                            viewModel.clearPressed = true
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            viewModel.clearPressed = false
                                        }
                                        viewModel.clearText()
                                    }
                            )
                    }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Picker("FIRST LANGUAGE", selection: $viewModel.selectedSourceLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }.padding(EdgeInsets())
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color(red: 0.12, green: 0.262, blue: 0.386))
                        )
                    
                    Button {
                        withAnimation {
                            viewModel.languageDirection.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.languageDirection ? "arrow.right" : "arrow.left")
                    }
                    
                    Picker("SECOND LANGUAGE", selection: $viewModel.selectedTargetLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }.padding(EdgeInsets())
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color(red: 0.12, green: 0.262, blue: 0.386))
                        )
                }.padding()
                
                Text("first: \(viewModel.sourceLanguageCode),\nsecond: \(viewModel.targetLanguageCode),\ndirection:\(viewModel.languageDirection)")
                    .font(.caption2)
                
                // First TextField (Language 1)
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color(red: 0.12, green: 0.262, blue: 0.386))
                        .frame(width: 375, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.highlighting, lineWidth: 3)
                                .opacity(viewModel.languageDirection ? 0 : 1)
                        )
                        .animation(.easeInOut, value: viewModel.languageDirection)
                    
                    TextField("", text: $viewModel.inputText, prompt: Text("Language 1 \(viewModel.selectedSourceLanguage)").foregroundColor(.gray), axis: .vertical)
                        .lineLimit(7)
                        .padding()
                        .focused($isFocused) // Bind the focus state
                }.overlay(
                    VStack() {
                        if isFocused {
                            Button("Done") {
                                hideKeyboard()
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 15)
                            .transition(.opacity) // Optional: Add a fade transition
                                                }
                }, alignment: .bottomTrailing
                )
                .padding()
                
                testAudioTranslationHandler(viewModel: viewModel)
                
                // Second TextField (Language 2)
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color(red: 0.12, green: 0.262, blue: 0.386))
                        .frame(width: 375, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.highlighting, lineWidth: 3)
                                .opacity(viewModel.languageDirection ? 1 : 0)
                        )
                        .animation(.easeInOut, value: viewModel.languageDirection)
                    
                    TextField("", text: $viewModel.outputText, prompt: Text("Language 2 \(viewModel.selectedTargetLanguage)").foregroundColor(.gray), axis: .vertical)
                        .lineLimit(7)
                        .padding()
                        .focused($isFocused) // Bind the focus state
                }
                .padding()
                
                
            }
        }
    }
    
    func hideKeyboard() {
        isFocused = false // Remove focus from the TextField
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    test(viewModel: testViewModel())
}
