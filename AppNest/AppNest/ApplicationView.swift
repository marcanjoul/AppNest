import SwiftUI

// MARK: - Application View

/// The main view for displaying and managing all job applications.
///
/// This view provides:
/// - A searchable list of all job applications
/// - Filtering by position, company name, and job type
/// - Navigation to detailed views for each application
/// - Quick access to create new applications via toolbar button
///
/// The view handles three states:
/// 1. Empty state (no applications yet)
/// 2. No search results state
/// 3. List of application cards with search/filter applied
struct ApplicationView: View {
    /// The shared view model that manages all job application data
    @ObservedObject var viewModel: JobViewModel
    
    /// The current search query text
    @State private var searchText: String = ""
    
    /// Controls whether the new application sheet is displayed
    @State private var isPresentingNewApplication: Bool = false
    
    /// Returns filtered applications based on the search query.
    ///
    /// Searches across:
    /// - Job position title
    /// - Company name
    /// - Job type (full-time, internship, etc.)
    ///
    /// Returns all applications when search text is empty.
    private var filteredApplications: [JobApplication] {
        let apps = viewModel.applications
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // If no search query, return all applications
        guard !query.isEmpty else { return apps }
        
        // Filter applications by checking if query matches any searchable field
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
                // Subtle gradient background for visual interest
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
                    // MARK: Empty State
                    // Show when user has no applications and isn't searching
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
                    }
                    // MARK: No Search Results State
                    // Show when search returns no matches
                    else if filteredApplications.isEmpty {
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
                    }
                    // MARK: Application List
                    // Display filtered applications as cards in a scrollable list
                    else {
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Add button to create new applications
                    Button {
                        isPresentingNewApplication = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Application")
                }
            }
            .searchable(text: $searchText, prompt: "Search by title or company")
            .sheet(isPresented: $isPresentingNewApplication) {
                // Create a new blank application with default values
                // The JobDetailView will handle saving it to the viewModel
                let newApplication = JobApplication(
                    company: Company(name: "", logoName: ""),
                    position: "",
                    jobType: nil,
                    status: .applied,
                    season: nil,
                    dateApplied: Date()
                )
                JobDetailView(job: newApplication, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = JobViewModel()

    // Demo companies with logo asset names
    let meta = Company(name: "Meta", logoName: "meta")
    let uber = Company(name: "Uber", logoName: "uber")
    let jpmc = Company(name: "JPMorgan Chase", logoName: "jpmorganchase")
    let honeywell = Company(name: "Honeywell", logoName: "honeywell")
    let jnj = Company(name: "Johnson & Johnson", logoName: "jnj")
    let amgen = Company(name: "Amgen", logoName: "amgen")
    let google = Company(name: "Google", logoName: "google")
    let amazon = Company(name: "Amazon", logoName: "amazon")
    let netflix = Company(name: "Netflix", logoName: "netflix")

    // Populate view model with sample applications for preview
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

    return NavigationStack { ApplicationView(viewModel: vm) }
}
