//
//  communicatorApp.swift
//  communicatorApp
//
//  Created by Andrew Hoang on 5/18/24.
// 

import SwiftUI
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct communicatorApp: App {
    //registering app delegate for firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            splashScreen()
        }
    }
}
