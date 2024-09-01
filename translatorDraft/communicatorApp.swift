//
//  communicatorApp.swift
//  communicatorApp
//
//  Created by Andrew Hoang on 5/18/24.
// 

import SwiftUI
import Firebase


/**
 The `AppDelegate` class is responsible for handling the app's lifecycle events and configuring Firebase during the app's launch.

 - Properties:
   - `window`: An optional `UIWindow` property for managing and coordinating the app's visible and interactive content.
 
 - Methods:
   - `application(_:didFinishLaunchingWithOptions:)`: Configures Firebase when the app finishes launching and returns a Boolean indicating whether the launch was successful.
 */
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


/**
 The main entry point for the Communicator app.

 The `communicatorApp` struct sets up the app's scene and registers the `AppDelegate` for Firebase initialization. It displays the splash screen when the app launches.
 
 - Properties:
   - `appDelegate`: An instance of `AppDelegate`, registered with `UIApplicationDelegateAdaptor` to ensure Firebase is configured when the app starts.
 
 - Body:
   - The `body` property defines the app's main scene, which displays the `splashScreen` view in a `WindowGroup`.
 */
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
