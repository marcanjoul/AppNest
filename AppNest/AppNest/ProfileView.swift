import SwiftUI

// MARK: - Profile View

/// A placeholder view for the Profile tab in the app.
///
/// This view will eventually display:
/// - User statistics (e.g., total applications, response rate)
/// - Most frequently applied-to companies
/// - Export functionality for application data
/// - Default resume settings and management
///
/// Currently shows a placeholder design with an icon and description text.
struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            /// Large person icon to represent the profile section
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
            
            /// Profile section title
            Text("Profile")
                .font(.title2.weight(.semibold))
            
            /// Description of planned features
            Text("Stats, most-applied companies, exports, and default resume settings will live here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { ProfileView() }
}
