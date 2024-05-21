import SwiftUI
import Speech
import AVFoundation

let languages = ["English", "Spanish", "Vietnamese", "Turkish", "German", "Italian", "Russian", "Arabic"]
let languageCodes = ["en", "es", "vi", "tr", "de", "it", "ru", "ar"]

struct TranslationView: View {
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                Color(#colorLiteral(red: 0.3843, green: 0.4471, blue: 0.3294, alpha: 1))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HeadingView(viewModel : viewModel)
                    Divider()
                    LangaugeSelector(viewModel : viewModel)
                    MainContainer(viewModel : viewModel)
                }
            }
        }
    }
}


struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
            .preferredColorScheme(.dark)
    }
}

struct MainContainer: View {
    @ObservedObject var viewModel: TranslationViewModel
    @State var showStroke1 = true
    @State var showStroke2 = false
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(.clear)
                        .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1)))
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white, lineWidth: 3)
                                .opacity(showStroke1 ? 0 : 1)
                        )
                        .onChange(of: viewModel.languageDirection) { newValue in
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
                }
                
                
                VStack {
                    LanguageHeading(viewModel: viewModel, languageHeadingType: true)
                    TextEditor(text: $viewModel.inputText)
                        .font(.title2)
                        .frame(width: 330.0)
                        .foregroundColor(Color.white)
                        .scrollContentBackground(.hidden) // hides the default bg
                        .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1) /* #76885b */)) // actual bg color to change
                        .cornerRadius(10)
                }
                
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            
            HStack {
                Button(action: {
                    viewModel.isListening.toggle()
                    if viewModel.isListening {
                        viewModel.startListening()
                    } else {
                        viewModel.stopListening()
                    }
                }) {
                    Image(systemName: viewModel.isListening ? "mic.circle.fill" : "mic.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(viewModel.isListening ? .green : .white)
                }
                
                Button(action: {
                    viewModel.speak(text: viewModel.languageDirection ? viewModel.inputText : viewModel.outputText, languageCode: viewModel.languageCodes[viewModel.languageDirection ? viewModel.sourceLanguageIndex : viewModel.targetLanguageIndex])
                }) {
                    Image(systemName: "speaker.wave.2.circle")
                        .padding()
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                Button(action: {
                    viewModel.translationText()
                }) {
                    Text("Translate")
                        .padding()
                        .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .scaleEffect(viewModel.translatePressed ? 1.2 : 1.0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation {
                                        viewModel.translatePressed = true
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        viewModel.translatePressed = false
                                    }
                                    viewModel.translationText()
                                }
                        )
                }
            }
            
            ZStack{
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(.clear)
                        .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1)))
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white, lineWidth: 3)
                                .opacity(showStroke2 ? 1 : 0)
                        )
                        .onChange(of: viewModel.languageDirection) { newValue in
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
                }
                
                VStack {
                    LanguageHeading(viewModel: viewModel, languageHeadingType: false)
                    TextEditor(text: $viewModel.outputText)
                        .font(.title2)
                        .frame(width: 330.0)
                        .foregroundColor(Color.white)
                        .scrollContentBackground(.hidden) // hides the default bg
                        .background(Color(#colorLiteral(red: 0.4627, green: 0.5333, blue: 0.3569, alpha: 1) /* #76885b */)) // actual bg color to change
                        .cornerRadius(10)
                        
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
        }
    }
}


struct HeadingView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        HStack {
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
                viewModel.clearText()
            }) {
                Text("Clear")
                    .padding()
                    .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                    .foregroundColor(.black)
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
        }
    }
}

struct Divider: View {
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 373, height: 1)
                .background(.white.opacity(0.33))
        }
    }
}

struct LanguageHeading: View {
    @ObservedObject var viewModel: TranslationViewModel
    var languageHeadingType : Bool
    
    var body: some View {
        HStack{
            Text("Language \(languageHeadingType ? 1 : 2): \(languages[languageHeadingType ? viewModel.sourceLanguageIndex : viewModel.targetLanguageIndex])")
                .font(Font.custom("Inter", size: 17).weight(.light))
                .foregroundColor(.white.opacity(0.43))
                .padding()
                .offset(x: -90)
        }
    }
}

struct LangaugeSelector: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 30.0) {
            Picker("Source Language", selection: $viewModel.sourceLanguageIndex) {
                ForEach(0..<viewModel.languages.count, id: \.self) { index in
                    Text(viewModel.languages[index])
                        .foregroundColor(.white)
                }
            }
            .padding(.all, 6.0)
            .pickerStyle(MenuPickerStyle())
            .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
            .foregroundColor(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 2)
            )
            
            Button(action: {
                viewModel.languageDirection.toggle()
            }) {
                Image(systemName: viewModel.languageDirection ? "arrow.right" : "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
                        .frame(width: 20.0)
                }
            .frame(width: 40.0, height: 40.0)
            .background(Color(#colorLiteral(red: 0.3843, green: 0.4471, blue: 0.3294, alpha: 1)))
            
            Picker("Target Language", selection: $viewModel.targetLanguageIndex) {
                ForEach(0..<viewModel.languages.count, id: \.self) { index in
                    Text(viewModel.languages[index])
                        .foregroundColor(.white)
                }
            }
            .padding(.all, 6.0)
            .pickerStyle(MenuPickerStyle())
            .background(Color(#colorLiteral(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1)))
            .foregroundColor(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .padding()
    }
}
