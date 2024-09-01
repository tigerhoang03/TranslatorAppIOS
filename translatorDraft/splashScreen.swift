//
//  SplashScreen.swift
//  translatorDraft
//
//  Created by Andrew Hoang on 6/3/24.
//

import SwiftUI


/**
 A `View` representing a splash screen that displays a loading animation before transitioning to the main screen.

 The splash screen features a gradient background, an app logo, and a title. It initially appears with a smaller scale and reduced opacity, then animates to full size and opacity. After a brief delay, it transitions to the main content of the app.
 
 - Properties:
    - `isActive`: A `State` variable that determines whether the splash screen is active or has transitioned to the main screen.
    - `size`: A `State` variable that controls the scaling effect of the splash screen content.
    - `opacity`: A `State` variable that controls the opacity of the splash screen content.
 
 - Body:
    - If `isActive` is `true`, the view transitions to the `mainScreen`. Otherwise, the splash screen is displayed with the animated content.
 */
struct splashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive{
            mainScreen()
        }else{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color.background, Color.black]),
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


/**
 A preview provider for the `splashScreen` view, enabling design-time preview.
 */
struct splashScreen_Previews: PreviewProvider{
    static var previews: some View{
        splashScreen()
    }
}
