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
    let container = try! ModelContainer(
        for: JobApplication.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let sampleApps: [(String, String, String, ApplicationType, ApplicationStatus, ApplicationSeason, Int)] = [
        ("Meta", "meta", "Software Engineering Intern - 2026", .internship, .applied, .summer, 5),
        ("Uber", "uber", "iOS Engineer Intern", .internship, .interview, .summer, 8),
        ("JPMorgan Chase", "jpmorganchase", "Software Engineer Intern", .internship, .applied, .summer, 10),
        ("Honeywell", "honeywell", "Embedded Systems Intern", .internship, .rejected, .summer, 12),
        ("Google", "google", "SWE Intern, iOS", .internship, .offer, .summer, 20),
        ("Amazon", "amazon", "SDE Intern", .internship, .applied, .summer, 22),
        ("Netflix", "netflix", "Mobile Engineering Intern", .internship, .toApply, .summer, 24),
    ]
    
    for (company, logo, position, type, status, season, daysAgo) in sampleApps {
        context.insert(JobApplication(
            companyName: company,
            companyLogoName: logo,
            position: position,
            jobType: type,
            status: status,
            season: season,
            dateApplied: Date().addingTimeInterval(-86_400 * Double(daysAgo))
        ))
    }
    
    return RootView()
        .modelContainer(container)
}
