import SwiftUI
import SwiftData

/// The root view of the application, containing a tab-based navigation structure.
/// This view manages the app's main navigation between the Applications list
/// and the Profile section. It also handles seeding demo data in debug builds.
struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ApplicationView()
            }
            .tabItem {
                Label("Applications", systemImage: "list.bullet")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
