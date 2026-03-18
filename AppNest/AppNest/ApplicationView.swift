//
//  ApplicationView.swift
//  Job Application Tracker
//
//  Displays a list of job applications, allows searching/filtering through them,
//  and supports adding new job applications.
//

import SwiftUI
import SwiftData

/// The main view displaying all job applications, supporting search functionality,
/// and providing an interface to add new applications.
struct ApplicationView: View {
    @Environment(\.modelContext) private var modelContext // Accesses the current SwiftData model context for data operations.
    @Query(sort: \JobApplication.dateApplied, order: .reverse) private var applications: [JobApplication] // Fetches all job applications from the model, sorted by most recent.
    
    @State private var searchText: String = "" // User input for searching/filtering applications.
    @State private var isPresentingNewApplication: Bool = false // Controls presentation of the new application sheet.
    
    /// Returns the filtered applications matching the user's search query (case-insensitive).
    private var filteredApplications: [JobApplication] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return applications }
        return applications.filter { app in
            let fields = [
                app.position.lowercased(),
                app.companyName.lowercased(),
                app.jobType?.rawValue.lowercased() ?? ""
            ]
            return fields.contains { $0.contains(query) }
        }
    }
    
    private func deleteApplications(at offsets: IndexSet) {
        for index in offsets {
            let job = filteredApplications[index]
            modelContext.delete(job)
        }
    }
    
    var body: some View {
        // Main background gradient and content.
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
                // Shown when there are no applications and no search text.
                if applications.isEmpty && searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No applications yet")
                            .font(.title3.weight(.semibold))
                        Text("Tap + to add your first application.")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                // Shown when search has no matches.
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
                // Shows the filtered list of job applications.
                else {
                    // Scrollable list of job application cards.
                    List {
                        ForEach(filteredApplications) { job in
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: JobDetailView(job: job)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                JobCardView(job: job)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteApplications)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Applications")
        // Toolbar with button to add a new application.
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewApplication = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Application")
            }
        }
        // Adds search bar at the top for filtering applications.
        .searchable(text: $searchText, prompt: "Search by title or company")
        // Presents a sheet to add a new job application.
        .sheet(isPresented: $isPresentingNewApplication) {
            NavigationStack {
                JobDetailView(job: nil)
            }
        }
    }
}

// Preview with in-memory model container for UI testing.
#Preview {
    NavigationStack {
        ApplicationView()
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
