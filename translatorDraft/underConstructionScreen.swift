//
//  underConstructionScreen.swift
//  translatorDraft
//
//  Created by Aman Sahu on 6/4/24.
//

import SwiftUI

struct underConstructionScreen: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                Spacer()
                
                Image(systemName: "wrench.and.screwdriver")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                Text("This section is currently under construction.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 10)
                
                Text("Please come back later for more updates.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Image(systemName: "hammer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                
                Text("Thank you for your patience!")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
