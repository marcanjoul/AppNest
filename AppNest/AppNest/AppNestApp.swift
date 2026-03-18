import SwiftUI

/// The main entry point for the AppNest application.
/// This struct conforms to the App protocol and defines the app's scene structure.
@main
struct AppNestApp: App {
    /// The app's scene configuration.
    /// Returns a WindowGroup containing the root view of the application.
    var body: some Scene {
        // WindowGroup manages a group of windows with the same content
        WindowGroup {
            // RootView serves as the initial view displayed when the app launches
            RootView()
        }
    }
}
