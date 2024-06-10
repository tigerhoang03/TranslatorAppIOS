//
//  SplashScreen.swift
//  translatorDraft
//
//  Created by Andrew Hoang on 6/3/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive{
            test()
        }else{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color.highlighting, Color.background]),
                                       startPoint: .top,
                               endPoint: .bottomTrailing).ignoresSafeArea()
                VStack{
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 10, x: 5, y: 2)
                        .padding()
                    
                    
                    Text("Communicator")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.txtColors)
                        .kerning(1.2)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.7)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
        
    }
}

struct SplashScreen_Previews: PreviewProvider{
    static var previews: some View{
        SplashScreen()
    }
}
