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
            VStack{
                        VStack{
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.textBoxColors)
                            Text("Communicator")
                                .font(.title)
                                .foregroundStyle(.black.opacity(0.80))
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear{
                            withAnimation(.easeIn(duration: 1.2)){
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
