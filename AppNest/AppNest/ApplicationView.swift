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
            
            List {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("AppNest")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(DarkTheme.textPrimary)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Search Bar
                searchBar
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                // Statistics
                statsSection
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                // Applications section
                if applications.isEmpty {
                    emptyState
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else if filteredAndSorted.isEmpty {
                    noResultsState
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredAndSorted) { job in
                        ZStack {
                            NavigationLink(destination: JobDetailView(job: job)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            DarkJobCardView(job: job)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(job)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                
                // Spacer for FAB
                Color.clear
                    .frame(height: 100)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
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
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DarkTheme.textSecondary)
                TextField("Search applications...", text: $searchText)
                    .foregroundStyle(DarkTheme.textPrimary)
                    .tint(Color.accentColor)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DarkTheme.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(DarkTheme.cardFill)
            .cornerRadius(12)
            
            // Filter and Sort
            HStack(spacing: 12) {
                Menu {
                    Button {
                        selectedStatus = nil
                    } label: {
                        HStack {
                            Text("All")
                            if selectedStatus == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    ForEach(ApplicationStatus.allCases, id: \.self) { status in
                        Button {
                            selectedStatus = status
                        } label: {
                            HStack {
                                Text(status.rawValue)
                                if selectedStatus == status {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedStatus?.rawValue ?? "All")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DarkTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DarkTheme.cardFill)
                    .cornerRadius(8)
                }
                
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DarkTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DarkTheme.cardFill)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
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
