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
//            Color.background.ignoresSafeArea()
            LinearGradient(gradient: Gradient(colors: [Color.background, Color.highlighting]),
                                   startPoint: .topLeading,
                           endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionView(systemName: "questionmark.circle", title: "How To Use", color: .txtColors) {
                        VStack(alignment: .leading) {
                            Text("Welcome to Communicator! Click on the")
                            Image(systemName: "mic.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.txtColors)
                                
                            Text("to start recording your speech you want to translate.")
                            Text("Click on the")
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            Text("to stop recording and get your translated speech output.")
                        }
                    }
                    
                    SectionView(systemName: "globe", title: "Language Selector and Direction", color: .txtColors) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Select languages from the drop-down menus.")
                            Text("To change the direction of the translation, click on the arrow between the language selectors. It will look like")
                            HStack {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.highlighting)
                                Text("or")
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.highlighting)
                            }
                            Text("arrow to switch translation direction.")
                        }
                    }
                    
                    SectionView(systemName: "trash", title: "Clearing Existing Text", color: .txtColors) {
                        Text("To clear text, simply click on the 'Clear' button next to the microphone button.")
                    }
                    
                    SectionView(systemName: "waveform", title: "How it Works", color: .txtColors) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Once you click the microphone icon to start recording, it will look like:")
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            Text("Your speech will appear in the non-highlighted box. Click the microphone again to stop, it will look like:")
                            Image(systemName: "mic.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.txtColors)
                            Text("The translated text will appear in the highlighted box. After the text has been successfully translated, a speech output will be heard of the translated text.")
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
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
            )
            
            content()
                .padding()
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
