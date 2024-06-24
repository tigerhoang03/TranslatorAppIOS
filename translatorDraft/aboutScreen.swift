//
//  aboutScreen.swift
//  translatorDraft
//
//  Created by Aman Sahu on 6/4/24.
//

import SwiftUI

struct AboutScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.background, Color.black]),
                           startPoint: .topTrailing,
                           endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionView(systemName: "questionmark.circle", title: "How To Use", color: .txtColors) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Welcome to Communicator!")
                            HStack{
                                Text("Click on the")
                                Image(systemName: "mic.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.txtColors)
                                Text("to start recording")
                            }
                            
                            HStack {
                                Text("Click on the")
                                Image(systemName: "mic.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                Text("to stop recording.")
                            }
                            
                            Text("After you stop recording, the translated text will appear in the highlighted box.")
                            Text("Make sure to have your volume up to hear the translated speech.")
                            
                        }
                    }
                    
                    SectionView(systemName: "globe", title: "Language Direction", color: .txtColors) {
                        VStack(alignment: .center, spacing: 10) {
                            Text("To change the 'direction' of the translation, click on the arrow in the middle of the two language boxes The arrow can have the following orientations:")
                            HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                                Spacer()
                                Spacer()
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.highlighting)
                                Spacer()
                                Image(systemName: "arrow.down")
                                    .foregroundColor(.highlighting)
                                Spacer()
                                Spacer()
                            }
                            Text("The arrow will point towards the text box which will have the translated text.")
                        }
                    }
                    
                    SectionView(systemName: "trash", title: "Clearing Existing Text", color: .txtColors) {
                        HStack {
                            Text("Click on the")
                            Image(systemName: "trash.circle")
                                .foregroundColor(.highlighting)
                            Text("button next to the")
                            Image(systemName: "mic.circle")
                                .foregroundColor(.txtColors)
                        }
                        
                    }
                    
                }
                .padding()
            }
        }
    }
}

struct SectionView<Content: View>: View {
    var systemName: String
    var title: String
    var color: Color
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemName)
                    .foregroundColor(color)
                    .font(.title)
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.background.opacity(0.2))
//            )
            
            content()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                )
        }
        .foregroundColor(color)
    }
}




struct AboutScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutScreen()
        }
    }
}
