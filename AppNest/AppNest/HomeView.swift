//
//  ContentView.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//

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
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by title or company")
    }
}

#Preview {
    let vm = JobViewModel()
    let meta = Company(name: "Meta", logoName: "meta")
    vm.applications = [
        JobApplication(company: meta, position: "Software Engineering Intern - 2026", jobType: .internship, status: .applied, season: .summer, dateApplied: Date().addingTimeInterval(-86_400 * 5))
    ]
    return NavigationStack { HomeView(viewModel: vm) }
}
