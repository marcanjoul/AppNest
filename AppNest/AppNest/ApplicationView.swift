import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case dateNewest = "Newest"
    case dateOldest = "Oldest"
    case companyAZ = "Company A-Z"
    case companyZA = "Company Z-A"
}

struct ApplicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JobApplication.dateApplied, order: .reverse) private var applications: [JobApplication]
    
    @State private var searchText: String = ""
    @State private var isPresentingNewApplication: Bool = false
    @State private var selectedStatus: ApplicationStatus? = nil
    @State private var sortOption: SortOption = .dateNewest
    
    private var filteredAndSorted: [JobApplication] {
        var result = applications
        
        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        // Filter by search
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { app in
                app.position.lowercased().contains(query) ||
                app.companyName.lowercased().contains(query) ||
                (app.jobType?.rawValue.lowercased().contains(query) ?? false)
            }
        }
        
        // Sort
        switch sortOption {
        case .dateNewest:
            result.sort { $0.dateApplied > $1.dateApplied }
        case .dateOldest:
            result.sort { $0.dateApplied < $1.dateApplied }
        case .companyAZ:
            result.sort { $0.companyName.localizedCompare($1.companyName) == .orderedAscending }
        case .companyZA:
            result.sort { $0.companyName.localizedCompare($1.companyName) == .orderedDescending }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            DarkTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AppNest")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(DarkTheme.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Search Bar
                    searchBar
                    
                    // Statistics
                    statsSection
                    
                    // Applications section
                    VStack(alignment: .leading, spacing: 16) {
                        if applications.isEmpty {
                            emptyState
                        } else if filteredAndSorted.isEmpty {
                            noResultsState
                        } else {
                            ForEach(filteredAndSorted) { job in
                                NavigationLink(destination: JobDetailView(job: job)) {
                                    DarkJobCardView(job: job)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 100) // Space for FAB
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        isPresentingNewApplication = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(Circle().fill(Color.accentColor))
                            .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $isPresentingNewApplication) {
            NavigationStack {
                JobDetailView(job: nil)
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DarkTheme.textSecondary)
                .font(.system(size: 16))
            
            TextField("Search applications...", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(DarkTheme.textPrimary)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DarkTheme.textSecondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DarkTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(DarkTheme.cardBorder, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatChip(
                number: applications.filter { $0.status == .applied }.count,
                label: "Applied"
            )
            StatChip(
                number: applications.filter { $0.status == .interview }.count,
                label: "Interviewing"
            )
            StatChip(
                number: applications.filter { $0.status == .offer }.count,
                label: "Offers"
            )
            StatChip(
                number: applications.filter { $0.status == .rejected }.count,
                label: "Rejected"
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Empty States
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(DarkTheme.textSecondary)
            Text("No applications yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DarkTheme.textPrimary)
            Text("Tap + to add your first application.")
                .foregroundStyle(DarkTheme.textSecondary)
        }
        .padding()
        .padding(.horizontal, 20)
    }
    
    private var noResultsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(DarkTheme.textSecondary)
            Text("No results")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DarkTheme.textPrimary)
            Text("No matches for your search or filter.")
                .foregroundStyle(DarkTheme.textSecondary)
        }
        .padding()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Actions
    
    private func deleteApplications(at offsets: IndexSet) {
        for index in offsets {
            let job = filteredAndSorted[index]
            modelContext.delete(job)
        }
    }
}

#Preview {
    NavigationStack {
        ApplicationView()
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
