//
//  settingScreen.swift
//  translatorDraft
//
//  Created by Aman Sahu on 6/4/24.
//

import SwiftUI

struct SettingScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                List {
                    Section(header: Text("General")) {
                        NavigationLink(destination: AboutScreen()) {
                            Text("How To Use")
                        }
                        NavigationLink(destination: underConstructionScreen()) {
                            Text("Account")
                        }
                        NavigationLink(destination: underConstructionScreen()) {
                            Text("Themes")
                        }
                    }
                    
                    
                    Section(header: Text("Legal")) {
                        NavigationLink(destination: underConstructionScreen()) {
                            Text("Licensing")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingScreen()
    }
}
