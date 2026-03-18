import SwiftUI
import SwiftData
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

struct ProfileView: View {
    @Query(sort: \JobApplication.dateApplied, order: .reverse) private var applications: [JobApplication]
    
    @State private var defaultResumeFileName: String? = nil
    @State private var defaultResumeBookmark: Data? = nil
    @State private var isShowingDocumentPicker = false
    @State private var isShowingShareSheet = false
    @State private var csvFileURL: URL? = nil
    
    // MARK: - Computed Stats
    
    private var totalCount: Int { applications.count }
    
    private var statusCounts: [(ApplicationStatus, Int)] {
        ApplicationStatus.allCases.compactMap { status in
            let count = applications.filter { $0.status == status }.count
            return count > 0 ? (status, count) : nil
        }
    }
    
    private var topCompanies: [(String, Int)] {
        let grouped = Dictionary(grouping: applications, by: { $0.companyName })
        return grouped
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { ($0.0, $0.1) }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: Stats Overview
                VStack(spacing: 16) {
                    HStack {
                        Label("Overview", systemImage: "chart.bar.fill")
                            .font(.title3.weight(.semibold))
                        Spacer()
                    }
                    
                    // Big number
                    VStack(spacing: 4) {
                        Text("\(totalCount)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        Text("Total Applications")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Status breakdown pills
                    if !statusCounts.isEmpty {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(statusCounts, id: \.0) { status, count in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(status.color)
                                        .frame(width: 10, height: 10)
                                    Text(status.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(status.color.opacity(0.1))
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                
                // MARK: Top Companies
                if !topCompanies.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            Label("Top Companies", systemImage: "building.2.fill")
                                .font(.title3.weight(.semibold))
                            Spacer()
                        }
                        
                        ForEach(topCompanies, id: \.0) { name, count in
                            HStack {
                                Text(name)
                                    .font(.body)
                                Spacer()
                                Text("\(count) app\(count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // MARK: Default Resume
                VStack(spacing: 16) {
                    HStack {
                        Label("Default Resume", systemImage: "doc.richtext")
                            .font(.title3.weight(.semibold))
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                        Text(defaultResumeFileName ?? "No file selected")
                            .foregroundStyle(defaultResumeFileName == nil ? .secondary : .primary)
                        Spacer()
                        if defaultResumeFileName != nil {
                            Button(role: .destructive) {
                                defaultResumeFileName = nil
                                defaultResumeBookmark = nil
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        Button {
                            isShowingDocumentPicker = true
                        } label: {
                            Image(systemName: "paperclip")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                
                // MARK: Export
                VStack(spacing: 16) {
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.title3.weight(.semibold))
                        Spacer()
                    }
                    
                    Button {
                        exportCSV()
                    } label: {
                        HStack {
                            Image(systemName: "tablecells")
                            Text("Export as CSV")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(applications.isEmpty)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Profile")
        .sheet(isPresented: $isShowingDocumentPicker) {
            ProfileDocumentPicker { result in
                switch result {
                case .success(let picked):
                    defaultResumeFileName = picked.fileName
                    defaultResumeBookmark = picked.bookmark
                case .failure:
                    break
                }
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let url = csvFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - CSV Export
    
    private func exportCSV() {
        var csv = "Company,Position,Type,Status,Season,Date Applied,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        for app in applications {
            let fields = [
                escapeCSV(app.companyName),
                escapeCSV(app.position),
                escapeCSV(app.jobType?.rawValue ?? ""),
                escapeCSV(app.status?.rawValue ?? ""),
                escapeCSV(app.season?.rawValue ?? ""),
                escapeCSV(dateFormatter.string(from: app.dateApplied)),
                escapeCSV(app.jobNotes ?? "")
            ]
            csv += fields.joined(separator: ",") + "\n"
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppNest_Export.csv")
        
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            csvFileURL = tempURL
            isShowingShareSheet = true
        } catch {
            print("CSV export failed: \(error)")
        }
    }
    
    private func escapeCSV(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
}

// MARK: - Document Picker

private struct ProfileDocumentPicker: UIViewControllerRepresentable {
    struct PickedFile {
        let fileName: String
        let bookmark: Data
    }
    
    var completion: (Result<PickedFile, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .plainText, .rtf, .data], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (Result<PickedFile, Error>) -> Void
        init(completion: @escaping (Result<PickedFile, Error>) -> Void) { self.completion = completion }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }
                let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
                completion(.success(PickedFile(fileName: url.lastPathComponent, bookmark: bookmark)))
            } catch {
                completion(.failure(error))
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack { ProfileView() }
        .modelContainer(for: JobApplication.self, inMemory: true)
}
