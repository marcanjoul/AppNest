import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: JobViewModel
    
    @State private var searchText: String = ""
    
    private var filteredApplications: [JobApplication] {
        let apps = viewModel.applications
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return apps }
        return apps.filter { app in
            let fields = [
                app.position.lowercased(),
                app.company.name.lowercased(),
                app.jobType?.rawValue.lowercased() ?? ""
            ]
            return fields.contains { $0.contains(query) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Group {
                    if viewModel.applications.isEmpty && searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No applications yet")
                                .font(.title3.weight(.semibold))
                            Text("Add your first application from the Add tab.")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if filteredApplications.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No results")
                                .font(.title3.weight(.semibold))
                            Text("No matches for \"\(searchText)\".")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredApplications) { job in
                                    NavigationLink {
                                        JobDetailView(job: job, viewModel: viewModel)
                                    } label: {
                                        JobCardView(job: job)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Applications")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by title or company")
        }
    }
}

#Preview {
    let vm = JobViewModel()

    // Demo companies
    let meta = Company(name: "Meta", logoName: "meta")
    let uber = Company(name: "Uber", logoName: "uber")
    let jpmc = Company(name: "JPMorgan Chase", logoName: "jpmorganchase")
    let honeywell = Company(name: "Honeywell", logoName: "honeywell")
    let jnj = Company(name: "Johnson & Johnson", logoName: "jnj")
    let amgen = Company(name: "Amgen", logoName: "amgen")
    let google = Company(name: "Google", logoName: "google")
    let amazon = Company(name: "Amazon", logoName: "amazon")
    let netflix = Company(name: "Netflix", logoName: "netflix")

    vm.applications = [
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

    return NavigationStack { HomeView(viewModel: vm) }
}
