import SwiftUI
import SwiftData

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
        // modelContainer creates a SQLite file on the user's device and tells every view in the app "here's where your data lives." Any view below this in the hierarchy can now access the database through @Environment(\.modelContext).
        .modelContainer(for: JobApplication.self)
    }
}
