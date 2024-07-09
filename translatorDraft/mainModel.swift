import SwiftUI

struct mainModel: View {
    @ObservedObject var viewModel = mainViewModel()
    @ObservedObject var newviewModel = premiumViewModel()
    
    @AppStorage("selectedPlan") private var selectedPlan: String = ""
    
    @State private var selectedSourceLanguage = "English"
    @State private var selectedTargetLanguage = "Spanish"
    @FocusState private var isFocused1: Bool
    @FocusState private var isFocused2: Bool
    @State private var inputText = ""
    @State private var outputText = ""
    
    let languages = ["English", "Spanish", "Hindi", "Vietnamese", "Greek", "Turkish", "German", "Italian", "Russian", "Arabic"]
    let language = ["English":"en", "Spanish":"es", "Hindi":"hi", "Vietnamese":"vi", "Greek":"el","Turkish":"tr", "German":"de", "Italian":"it", "Russian":"ru", "Arabic":"ar"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack {
                    Text("Plan selected: \(selectedPlan)")
                    // First TextField (Language 1)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.textBoxColors)
                            .frame(maxWidth: .infinity)
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
                                        .opacity(viewModel.isListening ? 1 : 0)
                                )
                            
                            inputTranslationHandlers(newviewModel: premiumViewModel())
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
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    mainModel(viewModel: mainViewModel())
}
