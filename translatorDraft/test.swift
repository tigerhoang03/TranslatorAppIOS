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
                    HStack {
                        Spacer()
                        Text("Communicator")
                            .frame(width: 220, height: 50)
                            .font(.title.bold())
                            .foregroundColor(.txtColors)
                        
                        Spacer()
                        
                        NavigationLink(destination: AboutScreen()) {
                            Image(systemName: "info.circle")
                                .resizable(resizingMode: .tile)
                                .foregroundColor(.highlighting)
                                .frame(width: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/)
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
  
                    // First TextField (Language 1)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.regularMaterial)
                            .frame(width: 375, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.highlighting, lineWidth: 3)
                                    .opacity(viewModel.languageDirection ? 0 : 1)
                            )
                            .animation(.easeInOut, value: viewModel.languageDirection)
                        
                        VStack(alignment: .leading) {
                            Picker("FIRST LANGUAGE", selection: $viewModel.selectedSourceLanguage) {
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
                            
                            TextField("", text: $viewModel.inputText, axis: .vertical)
                                .lineLimit(7)
                                .padding(.leading)
                                .focused($isFocused1)
                        }
                        
                        
                    }.overlay(
                        VStack() {
                            if isFocused1 {
                                Button("Done") {
                                    hideKeyboard()
                                    viewModel.translationText()
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 15)
                                .transition(.opacity) // Optional: Add a fade transition
                            }
                        }, alignment: .bottomTrailing
                    )
                    .padding()
                    
                    
                    Button {
                        withAnimation {
                            viewModel.languageDirection.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.languageDirection ? "arrow.down" : "arrow.up")
                    }
                    .foregroundColor(.highlighting)
                    
                    
                    // Second TextField (Language 2)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.regularMaterial)
                            .frame(width: 375, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.highlighting, lineWidth: 3)
                                    .opacity(viewModel.languageDirection ? 1 : 0)
                            )
                            .animation(.easeInOut, value: viewModel.languageDirection)
                        
                        VStack(alignment: .leading) {
                            Picker("SECOND LANGUAGE", selection: $viewModel.selectedTargetLanguage) {
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
                            
                            
                            TextField("", text: $viewModel.outputText , axis: .vertical)
                                .lineLimit(7)
                                .padding(.leading)
                                .focused($isFocused2) // Bind the focus state
                        }
                    }.overlay(
                        VStack() {
                            if isFocused2 {
                                Button("Done") {
                                    hideKeyboard()
                                    viewModel.translationText()
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 15)
                                .transition(.opacity) // Optional: Add a fade transition
                            }
                        }, alignment: .topTrailing
                    )
                    .padding()
                    
                    HStack {
                        testAudioTranslationHandler(viewModel: viewModel)
//                            .frame(maxWidth: .infinity)
//                            .background(Color.highlighting)
                    }
                }
            }
        }.tint(.highlighting) // for back buttons
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
