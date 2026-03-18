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
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Group {
                if applications.isEmpty && searchText.isEmpty {
                    emptyState
                } else if filteredAndSorted.isEmpty {
                    noResultsState
                } else {
                    applicationList
                }
            }
        }
        .navigationTitle("Applications")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    sortMenu
                    Button {
                        isPresentingNewApplication = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.medium)
                    }
                    .accessibilityLabel("Add Application")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search by title or company")
        .sheet(isPresented: $isPresentingNewApplication) {
            NavigationStack {
                JobDetailView(job: nil)
            }
        }
    }
    
    // MARK: - Sort Menu
    
    private var sortMenu: some View {
        Menu {
            Section("Sort by") {
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
            }
            
            Section("Filter by status") {
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
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Application List
    
    private var applicationList: some View {
        List {
            // Status filter chips
            if !applications.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(label: "All", isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }
                        ForEach(ApplicationStatus.allCases, id: \.self) { status in
                            let count = applications.filter { $0.status == status }.count
                            if count > 0 {
                                filterChip(
                                    label: "\(status.rawValue) (\(count))",
                                    isSelected: selectedStatus == status
                                ) {
                                    selectedStatus = (selectedStatus == status) ? nil : status
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            
            ForEach(filteredAndSorted) { job in
                ZStack(alignment: .leading) {
                    NavigationLink(destination: JobDetailView(job: job)) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    JobCardView(job: job)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteApplications)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Filter Chip
    
    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? Theme.accent : Color(.tertiarySystemFill))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty States
    
    private var emptyState: some View {
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
    
    private var noResultsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No results")
                .font(.title3.weight(.semibold))
            Text("No matches for your search or filter.")
                .foregroundStyle(.secondary)
        }
        .padding()
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
