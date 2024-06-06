//
//  settingScreen.swift
//  translatorDraft
//
//  Created by Aman Sahu on 6/4/24.
//

import SwiftUI

struct SettingScreen: View {
    
    @State private var selectedPlan: String? = nil
    let plans = ["Free Plan", "Premium Plan"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                List {
                    Section(header: Text("Plan")) {
                        ScrollView(.vertical) {
                            LazyHGrid(rows: [GridItem(.flexible())], spacing: 20) {
                                ForEach(plans, id: \.self) { plan in
                                    CardView(plan: plan, isSelected: plan == selectedPlan)
                                        .onTapGesture {
                                            selectedPlan = plan
                                        }
                                }
                            }
                            .padding()
                            
                        }
                    }
                    
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
                            Text("Liscensing")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle("Settings")
        }
    }
}


struct CardView: View {
    let plan: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(plan)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.txtColors)
                .padding()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.highlighting)
                    .font(.title)
                    .padding(.bottom, 5)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.txtColors)
                    .font(.title)
                    .padding(.bottom, 5)
            }
        }
        .background(Color.background)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
        .padding([.horizontal, .top])
    }
}

struct SettingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingScreen()
    }
}
