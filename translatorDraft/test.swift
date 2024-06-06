import SwiftUI

struct test: View {
    @ObservedObject var viewModel = testViewModel()
    
    @State private var selectedSourceLanguage = "English"
    @State private var selectedTargetLanguage = "Spanish"
    @FocusState private var isFocused1: Bool
    @FocusState private var isFocused2: Bool
    @State private var inputText = ""
    @State private var outputText = ""
    
    
    let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Greek", "Turkish", "German", "Italian", "Russian", "Arabic"]
    let language = ["English":"en", "Spanish":"es", "Hindi":"hi", "Vietnamese":"vi", "Greek":"el","Turkish":"tr", "German":"de", "Italian":"it", "Russian":"ru", "Arabic":"ar"]
    
    
    //@State private var languageDirection = true // true means left language -> right language
    
//    var sourceLanguageCode: String { languageDirection ? language[selectedSourceLanguage]! : language[selectedTargetLanguage]! }
//    var targetLanguageCode: String { languageDirection ? language[selectedTargetLanguage]! : language[selectedSourceLanguage]! }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                VStack {
                    HStack{
                        Spacer()
                        Text("Communicator")
                            .frame(width: 220, height: 50)
                            .font(.title.bold())
                            .foregroundColor(.txtColors)
                        
                        Spacer()
                        Button(action: viewModel.clearText) {
                            Text("Clear")
                                .padding()
                                .background(Color.btnColors)
                                .foregroundColor(.txtColors)
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
                        NavigationLink(destination: SettingScreen()) {
                            Image(systemName: "gear")
                                .resizable(resizingMode: .tile)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.txtColors)
                                .frame(width: 30, height: 30)
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
                                    .fill(.textBoxColors)
                            )
                        
                        Button {
                            withAnimation {
                                viewModel.languageDirection.toggle()
                            }
                        } label: {
                            Image(systemName: viewModel.languageDirection ? "arrow.right" : "arrow.left")
                        }
                        .foregroundColor(.highlighting)
                        
                        Picker("SECOND LANGUAGE", selection: $viewModel.selectedTargetLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language)
                            }
                        }.padding(EdgeInsets())
                            .background(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .fill(.textBoxColors)
                            )
                    }.padding()
                    
                    //                Text("first: \(viewModel.sourceLanguageCode),\nsecond: \(viewModel.targetLanguageCode),\ndirection:\(viewModel.languageDirection)")
                    //                    .font(.caption2)
                    
                    // First TextField (Language 1)
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 25.0)
//                            .fill(.textBoxColors)
                            .fill(.regularMaterial)
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
                            .focused($isFocused1) // Bind the focus state
                    }.overlay(
                        VStack() {
                            if isFocused1 {
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
//                            .fill(.textBoxColors)
                            .fill(.regularMaterial)
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
                            .focused($isFocused2) // Bind the focus state
                    }.overlay(
                        VStack() {
                            if isFocused2 {
                                Button("Done") {
                                    hideKeyboard()
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 15)
                                .transition(.opacity) // Optional: Add a fade transition
                            }
                        }, alignment: .topTrailing
                    )
                    .padding()
                    
                    
                }
            }
        }
        .navigationTitle("Home")
    }
    
    func hideKeyboard() {
        isFocused1 = false // Remove focus from the TextField
        isFocused2 = false
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
