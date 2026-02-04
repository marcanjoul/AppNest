import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = JobViewModel()
    

    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                HomeView(viewModel: viewModel)
            }
            .tabItem {
                Label("Home", systemImage: "list.bullet")
            }

            // Add Tab (placeholder for paste email/link/manual entry flows)
            NavigationStack {
                AddView()
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle")
            }

            // Profile Tab (placeholder for stats, default resume, exports)
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .task {
            #if DEBUG
            if viewModel.applications.isEmpty {
                // Seed demo companies and applications for development/testing
                let meta = Company(name: "Meta", logoName: "meta")
                let uber = Company(name: "Uber", logoName: "uber")
                let jpmc = Company(name: "JPMorgan Chase", logoName: "jpmorganchase")
                let honeywell = Company(name: "Honeywell", logoName: "honeywell")
                let jnj = Company(name: "Johnson & Johnson", logoName: "jnj")
                let amgen = Company(name: "Amgen", logoName: "amgen")
                let google = Company(name: "Google", logoName: "google")
                let amazon = Company(name: "Amazon", logoName: "amazon")
                let netflix = Company(name: "Netflix", logoName: "netflix")

                viewModel.applications = [
                    JobApplication(company: meta, position: "Software Engineering Intern - 2026", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 5)),
                    JobApplication(company: uber, position: "iOS Engineer Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 8)),
                    JobApplication(company: jpmc, position: "Software Engineer Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 10)),
                    JobApplication(company: honeywell, position: "Embedded Systems Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 12)),
                    JobApplication(company: jnj, position: "Data Science Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 14)),
                    JobApplication(company: amgen, position: "Bioinformatics Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 16)),
                    JobApplication(company: google, position: "SWE Intern, iOS", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 20)),
                    JobApplication(company: amazon, position: "SDE Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 22)),
                    JobApplication(company: netflix, position: "Mobile Engineering Intern", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 24))
                ]
            }
            #endif
        }
    }
}

#Preview {
    RootView()
}
