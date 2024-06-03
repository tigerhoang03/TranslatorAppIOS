//import SwiftUI
//import Speech
//import AVFoundation
//
//struct TranslationView: View {
//    @StateObject private var viewModel = TranslationViewModel()
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                Color.background
//                    .edgesIgnoringSafeArea(.all)
//                VStack {
//                    HeadingView(viewModel : viewModel)
//                    Divider()
//                    LangaugeSelector(viewModel : viewModel)
//                    MainContainer(viewModel : viewModel)
//                }
//            }
//        }
//    }
//}
//
//
//struct MainContainer: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    @State var showStroke1 = true
//    @State var showStroke2 = false
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                GeometryReader { geometry in
//                    Rectangle()
//                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .foregroundColor(.clear)
//                        .background(Color.textBoxColors)
//                        .cornerRadius(22)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 22)
//                                .stroke(Color.highlighting, lineWidth: 3)
//                                .opacity(showStroke1 ? 0 : 1)
//                        )
//                        .onChange(of: viewModel.languageDirection) { newValue in
//                            if newValue {
//                                withAnimation(.easeIn(duration: 0.2)) {
//                                    showStroke1 = true
//                                }
//                            } else {
//                                withAnimation(.easeOut(duration: 0.2)) {
//                                    showStroke1 = false
//                                }
//                            }
//                        }
//                }
//                
//                VStack {
//                    LanguageHeading(viewModel: viewModel, languageHeadingType: true)
//                    GeometryReader{ geometry in
//                        TextEditor(text: $viewModel.inputText)
//                            .font(.title2)
//                            .frame(width: geometry.size.width, height:geometry.size.height)
//                            .foregroundColor(Color.white)
//                            .scrollContentBackground(.hidden) // hides the default bg
//                            .background(Color.textBoxColors) // actual bg color to change
//                            .cornerRadius(10)
//                    }
//                    .padding([.leading, .bottom, .trailing])
//                    
//                }
//            }
//            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            
//            
//            AudioTranslationHandler(viewModel: viewModel)
//            
//            ZStack{
//                GeometryReader { geometry in
//                    Rectangle()
//                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .foregroundColor(.clear)
//                        .background(Color.textBoxColors)
//                        .cornerRadius(22)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 22)
//                                .stroke(Color.highlighting, lineWidth: 3)
//                                .opacity(showStroke2 ? 1 : 0)
//                        )
//                        .onChange(of: viewModel.languageDirection) { newValue in
//                            if newValue {
//                                withAnimation(.easeIn(duration: 0.2)) {
//                                    showStroke2 = true
//                                }
//                            } else {
//                                withAnimation(.easeOut(duration: 0.2)) {
//                                    showStroke2 = false
//                                }
//                            }
//                        }
//                }
//                
//                VStack {
//                    LanguageHeading(viewModel: viewModel, languageHeadingType: false)
//                    GeometryReader { geometry in
//                        TextEditor(text: $viewModel.outputText)
//                            
//                            .font(.title2)
//                            .frame(width: geometry.size.width, height: geometry.size.height)
//                            .foregroundColor(Color.white)
//                            .scrollContentBackground(.hidden) // hides the default bg
//                            .background(Color.textBoxColors) // actual bg color to change
//                            .cornerRadius(10)
//                    }
//                    .padding(/*@START_MENU_TOKEN@*/[.leading, .bottom, .trailing]/*@END_MENU_TOKEN@*/)
//                }
//            }
//            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//        }
//    }
//}
//
//
//struct HeadingView: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        HStack {
//            Text("Communicator")
//                .font(.system(size: 29))
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .multilineTextAlignment(.leading)
//                .padding()
//            
//            Image(systemName: "bell.badge")
//                .padding()
//                .frame(width: 45, height: 45)
//                .foregroundColor(.white)
//            
//            Button(action: {
//                viewModel.clearText()
//            }
//            ) {
//                Text("Clear")
//                    .padding()
//                    .background(Color.btnColors)
//                    .foregroundColor(.white)
//                    .cornerRadius(15)
//                    .scaleEffect(viewModel.clearPressed ? 1.2 : 1.0)
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { _ in
//                                withAnimation {
//                                    viewModel.clearPressed = true
//                                }
//                            }
//                            .onEnded { _ in
//                                withAnimation {
//                                    viewModel.clearPressed = false
//                                }
//                                viewModel.clearText()
//                            }
//                    )
//            }
//        }
//    }
//}
//
//struct Divider: View {
//    var body: some View {
//        VStack {
//            Rectangle()
//                .foregroundColor(.clear)
//                .frame(width: 373, height: 1)
//                .background(.white.opacity(0.33))
//        }
//    }
//}
//
//struct LanguageHeading: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    var languageHeadingType : Bool
//    
//    var body: some View {
//        HStack{
//            Text("Language \(languageHeadingType ? 1 : 2): \(viewModel.languages[languageHeadingType ? viewModel.sourceLanguageIndex : viewModel.targetLanguageIndex])")
//                .font(.system(size: 17, weight: .semibold))
//                .foregroundColor(.white.opacity(0.8))
//                .padding()
//                .offset(x: -50)
//        }
//    }
//}
//
//struct LangaugeSelector: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 30.0) {
//            Picker("Source Language", selection: $viewModel.sourceLanguageIndex) {
//                ForEach(0..<viewModel.languages.count, id: \.self) { index in
//                    Text(viewModel.languages[index])
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.all, 6.0)
//            .pickerStyle(MenuPickerStyle())
//            .background(Color.txtColors)
//            .foregroundColor(Color.white)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.black, lineWidth: 2)
//            )
//            
//            Button(action: {
//                viewModel.languageDirection.toggle()
//            }) {
//                Image(systemName: viewModel.languageDirection ? "arrow.right" : "arrow.left")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(.txtColors)
//                }
//            .frame(width: 40.0, height: 40.0)
//            .background(.clear)
//            
//            Picker("Target Language", selection: $viewModel.targetLanguageIndex) {
//                ForEach(0..<viewModel.languages.count, id: \.self) { index in
//                    Text(viewModel.languages[index])
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.all, 6.0)
//            .pickerStyle(MenuPickerStyle())
//            .background(Color.txtColors)
//            .foregroundColor(Color.white)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.black, lineWidth: 2)
//            )
//        }
//        .padding()
//    }
//}
//
//struct AudioTranslationHandler: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        HStack {
//            Button(action: {
//                viewModel.isListening.toggle()
//                if viewModel.isListening {
//                    viewModel.startListening()
//                } else {
//                    viewModel.stopListening()
//                }
//            }) {
//                Image(systemName: viewModel.isListening ? "mic.circle.fill" : "mic.circle")
//                    .padding()
//                    .font(.system(size: 40))
//                    .foregroundColor(viewModel.isListening ? .green : .white)
//            }
//            
//            Button(action: {
//                viewModel.speak(text: viewModel.languageDirection ? viewModel.outputText : viewModel.inputText, languageCode: viewModel.languageCodes[viewModel.languageDirection ? viewModel.targetLanguageIndex : viewModel.sourceLanguageIndex])
//            }) {
//                Image(systemName: "speaker.wave.2.circle")
//                    .padding()
//                    .font(.system(size: 40))
//                    .foregroundColor(.white)
//            }
//            Button(action: {
//                viewModel.translationText()
//            }) {
//                Text("Translate")
//                    .padding()
//                    .background(Color.btnColors)
//                    .foregroundColor(.white)
//                    .cornerRadius(15)
//                    .scaleEffect(viewModel.translatePressed ? 1.2 : 1.0)
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { _ in
//                                withAnimation {
//                                    viewModel.translatePressed = true
//                                }
//                            }
//                            .onEnded { _ in
//                                withAnimation {
//                                    viewModel.translatePressed = false
//                                }
//                                viewModel.translationText()
//                            }
//                    )
//            }
//        }
//    }
//}
//
//struct TranslationView_Previews: PreviewProvider {
//    static var previews: some View {
//        TranslationView()
//            .preferredColorScheme(.dark)
//    }
//}
