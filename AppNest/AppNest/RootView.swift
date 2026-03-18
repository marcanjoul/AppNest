import SwiftUI

/// The root view of the application, containing a tab-based navigation structure.
/// This view manages the app's main navigation between the Applications list
/// and the Profile section. It also handles seeding demo data in debug builds.
struct RootView: View {
    @StateObject private var viewModel = JobViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                ApplicationView(viewModel: viewModel)
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
        .task {
            #if DEBUG
            seedDemoDataIfNeeded()
            #endif
        }
    }
    
    // MARK: - Debug Helpers
    
    /// Seeds the view model with demo job applications for testing and development.
    /// Only runs in debug builds when the applications list is empty.
    private func seedDemoDataIfNeeded() {
        guard viewModel.applications.isEmpty else { return }
        
        let companies = createDemoCompanies()
        viewModel.applications = createDemoApplications(from: companies)
    }
    
    /// Creates a collection of demo companies with their logo asset names.
    private func createDemoCompanies() -> [Company] {
        [
            Company(name: "Meta", logoName: "meta"),
            Company(name: "Uber", logoName: "uber"),
            Company(name: "JPMorgan Chase", logoName: "jpmorganchase"),
            Company(name: "Honeywell", logoName: "honeywell"),
            Company(name: "Johnson & Johnson", logoName: "jnj"),
            Company(name: "Amgen", logoName: "amgen"),
            Company(name: "Google", logoName: "google"),
            Company(name: "Amazon", logoName: "amazon"),
            Company(name: "Netflix", logoName: "netflix")
        ]
    }
    
    /// Creates demo job applications with varying application dates.
    private func createDemoApplications(from companies: [Company]) -> [JobApplication] {
        let positions = [
            "Software Engineering Intern - 2026",
            "iOS Engineer Intern",
            "Software Engineer Intern",
            "Embedded Systems Intern",
            "Data Science Intern",
            "Bioinformatics Intern",
            "SWE Intern, iOS",
            "SDE Intern",
            "Mobile Engineering Intern"
        ]
        
        return zip(companies, positions).enumerated().map { index, pair in
            let (company, position) = pair
            let daysAgo = 5 + (index * 2)
            return JobApplication(
                company: company,
                position: position,
                jobType: .internship,
                status: .applied,
                season: .summer,
                dateApplied: Date().addingTimeInterval(-86_400 * TimeInterval(daysAgo))
            )
        }
    }
}

#Preview {
    RootView()
}
