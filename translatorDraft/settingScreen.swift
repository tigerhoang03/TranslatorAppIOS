import SwiftUI

struct SettingScreen: View {
    @AppStorage("selectedPlan") private var selectedPlan: String = "Premium Plan"
    let plans = ["Free Plan", "Premium Plan"]
    
    var body: some View {
        ZStack {
            List {
                // Plan Section
                Section(header: Text("Plans")) {
                    ForEach(plans, id: \.self) { plan in
                        HStack {
                            Text(plan)
                            Spacer()
                            if selectedPlan == plan {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPlan = plan
                        }
                    }
                }
                
                // General Section
                Section(header: Text("General")) {
                    NavigationLink(destination: underConstructionScreen()) {
                        Text("Account")
                    }
                    NavigationLink(destination: underConstructionScreen()) {
                        Text("Themes")
                    }
                }
                
                // Legal Section
                Section(header: Text("Legal")) {
                    NavigationLink(destination: underConstructionScreen()) {
                        Text("Licensing")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Settings")
    }
}

struct SettingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingScreen()
        }
    }
}
