import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

/// A form view for creating or editing a job application.
///
/// When `job` is `nil`, the view operates in "create" mode, presenting empty fields
/// and an "Add Application" button. When an existing `JobApplication` is passed in,
/// the view pre-fills all fields and allows editing with a "Save Changes" button.
///
/// The view is composed of extracted subviews for each section (company info,
/// job type, status, season, date, resume, and notes).
struct JobDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The existing job application to edit, or `nil` when creating a new one.
    var job: JobApplication?

    // MARK: - Editable local state
    @State private var companyName: String
    @State private var companyLogoName: String
    @State private var companyLogoImageData: Data?
    @State private var position: String
    @State private var type: ApplicationType?
    @State private var status: ApplicationStatus?
    @State private var season: ApplicationSeason?
    @State private var dateApplied: Date
    @State private var jobNotes: String
    @State private var resumeFileName: String?
    /// Temporarily holds resume bookmark data until save is performed.
    @State private var _pendingResumeBookmark: Data?
    @State private var isShowingDocumentPicker = false
    @State private var pickerItem: PhotosPickerItem? = nil

    /// Whether this view is creating a new application (true) or editing an existing one (false).
    private var isNewApplication: Bool { job == nil }

    /// Save is disabled until the user provides at minimum a company name, position, type, and status.
    private var isSaveDisabled: Bool {
        companyName.trimmingCharacters(in: .whitespaces).isEmpty ||
        position.trimmingCharacters(in: .whitespaces).isEmpty ||
        type == nil || status == nil
    }

    // MARK: - Initializer
    /// Creates a detail view for a new or existing job application.
    /// - Parameter job: An existing application to edit, or `nil` to create a new one.
    init(job: JobApplication?) {
        self.job = job
        _companyName = State(initialValue: job?.companyName ?? "")
        _companyLogoName = State(initialValue: job?.companyLogoName ?? "")
        _companyLogoImageData = State(initialValue: job?.companyLogoImageData)
        _position = State(initialValue: job?.position ?? "")
        _type = State(initialValue: job?.jobType)
        _status = State(initialValue: job?.status ?? .applied)
        _season = State(initialValue: job?.season)
        _dateApplied = State(initialValue: job?.dateApplied ?? Date())
        _jobNotes = State(initialValue: job?.jobNotes ?? "")
        _resumeFileName = State(initialValue: job?.resumeFileName)
        __pendingResumeBookmark = State(initialValue: nil)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.cyan.opacity(0.10),
                    Color.blue.opacity(0.12)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    JobInfoSection(
                        companyName: $companyName,
                        companyLogoName: $companyLogoName,
                        companyLogoImageData: $companyLogoImageData,
                        position: $position,
                        pickerItem: $pickerItem
                    )
                    TypePickerSection(type: $type)
                    StatusPickerSection(status: $status)
                    SeasonPickerSection(season: $season)
                    DateAppliedSection(dateApplied: $dateApplied)
                    ResumeSection(
                        resumeFileName: resumeFileName,
                        onPick: { isShowingDocumentPicker = true },
                        onClear: { resumeFileName = nil }
                    )
                    JobNotesSection(jobNotes: $jobNotes)
                }
                // Clear season when the selected job type doesn't support seasons
                // (only part-time, internship, temporary, and co-op have seasons).
                .onChange(of: type) { oldType, newType in
                    let allowed: [ApplicationType] = [.partTime, .internship, .temporary, .Co_op]
                    if !(newType.map { allowed.contains($0) } ?? false) {
                        season = nil
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentPicker { result in
                switch result {
                case .success(let picked):
                    resumeFileName = picked.fileName
                    self._pendingResumeBookmark = picked.bookmark
                case .failure:
                    break
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        #endif
                        save()
                        dismiss()
                    } label: {
                        Text(isNewApplication ? "Add Application" : "Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .controlSize(.large)
                    .disabled(isSaveDisabled)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    #if canImport(UIKit)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    #endif
                }
            }
            if isNewApplication {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .navigationTitle(isNewApplication ? "New Application" : "Job Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Save
    /// Persists the current form values to the SwiftData model context.
    /// Updates the existing record if editing, or inserts a new one if creating.
    private func save() {
        if let job {
            // Update existing
            job.companyName = companyName
            job.companyLogoName = companyLogoName
            job.companyLogoImageData = companyLogoImageData
            job.position = position
            job.jobType = type
            job.status = status
            job.season = season
            job.dateApplied = dateApplied
            job.jobNotes = jobNotes
            job.resumeFileName = resumeFileName
            job.resumeBookmark = _pendingResumeBookmark ?? job.resumeBookmark
        } else {
            // Create new
            let newJob = JobApplication(
                companyName: companyName,
                companyLogoName: companyLogoName,
                companyLogoImageData: companyLogoImageData,
                position: position,
                jobType: type,
                status: status,
                season: season,
                dateApplied: dateApplied,
                jobNotes: jobNotes,
                resumeFileName: resumeFileName,
                resumeBookmark: _pendingResumeBookmark
            )
            modelContext.insert(newJob)
        }
    }
}

// MARK: - Extracted Subviews

/// Displays and allows editing of the company logo, position title, and company name.
private struct JobInfoSection: View {
    @Binding var companyName: String
    @Binding var companyLogoName: String
    @Binding var companyLogoImageData: Data?
    @Binding var position: String
    @Binding var pickerItem: PhotosPickerItem?

    #if canImport(UIKit)
    private var logoImage: Image {
        if let data = companyLogoImageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        } else if !companyLogoName.isEmpty {
            return Image(companyLogoName)
        } else {
            return Image(systemName: "building.2")
        }
    }
    #else
    private var logoImage: Image { Image(companyLogoName) }
    #endif

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                logoImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 20))
                            .background(
                                Circle().fill(Color(.systemBackground)).frame(width: 16, height: 16).offset(x: -2, y: -2)
                            )
                            .offset(x: 4, y: 4)
                    }
                    .shadow(radius: 2)
            }
            .onChange(of: pickerItem) { oldValue, newValue in
                guard let item = newValue else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        companyLogoImageData = data
                    }
                }
            }
            .contextMenu {
                if companyLogoImageData != nil {
                    Button(role: .destructive) {
                        companyLogoImageData = nil
                    } label: {
                        Label("Remove Custom Logo", systemImage: "trash")
                    }
                }
            }

            VStack {
                HStack {
                    TextField("Position Title", text: $position)
                        .padding(.leading, 12)
                        .padding(.trailing, 36)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .fontWeight(.bold)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 12)
                            }
                        )
                }

                HStack {
                    TextField("Company Name", text: $companyName)
                        .padding(.leading, 12)
                        .padding(.trailing, 36)
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 12)
                            }
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

/// Horizontally scrollable pill picker for selecting the job's employment type.
private struct TypePickerSection: View {
    @Binding var type: ApplicationType?

    private var orderedOptions: [ApplicationType] {
        if let selected = type {
            return [selected] + ApplicationType.allCases.filter { $0 != selected }
        } else {
            return ApplicationType.allCases
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Type", systemImage: "list.bullet")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(orderedOptions, id: \.self) { option in
                            SelectablePill(
                                option: option,
                                isSelected: option == type,
                                color: option.color,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        type = (type == option ? nil : option)
                                    }
                                }
                            )
                            .id(option)
                        }
                    }
                }
                .padding(.vertical)
                .onChange(of: type) { _, _ in
                    if let first = orderedOptions.first {
                        withAnimation(.smooth) {
                            proxy.scrollTo(first, anchor: .leading)
                        }
                    }
                }
            }
        }
    }
}

/// Horizontally scrollable pill picker for selecting the application's current status.
private struct StatusPickerSection: View {
    @Binding var status: ApplicationStatus?

    private var orderedOptions: [ApplicationStatus] {
        if let selected = status {
            return [selected] + ApplicationStatus.allCases.filter { $0 != selected }
        } else {
            return ApplicationStatus.allCases
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Status", systemImage: "rectangle.and.hand.point.up.left.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(orderedOptions, id: \.self) { option in
                            SelectablePill(
                                option: option,
                                isSelected: option == status,
                                color: option.color,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        status = (status == option ? nil : option)
                                    }
                                }
                            )
                            .id(option)
                        }
                    }
                }
                .padding(.vertical)
                .onChange(of: status) { _, _ in
                    if let first = orderedOptions.first {
                        withAnimation(.easeOut) {
                            proxy.scrollTo(first, anchor: .leading)
                        }
                    }
                }
            }
        }
    }
}

/// Horizontally scrollable pill picker for selecting the job's season (e.g., Summer, Fall).
private struct SeasonPickerSection: View {
    @Binding var season: ApplicationSeason?

    private var orderedOptions: [ApplicationSeason] {
        if let selected = season {
            return [selected] + ApplicationSeason.allCases.filter { $0 != selected }
        } else {
            return ApplicationSeason.allCases
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Season", systemImage: "sun.snow.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(orderedOptions, id: \.self) { option in
                            SelectablePill(
                                option: option,
                                isSelected: option == season,
                                color: option.color,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        season = (season == option ? nil : option)
                                    }
                                }
                            )
                            .id(option)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: season) { _, _ in
                    if let first = orderedOptions.first {
                        withAnimation(.easeOut) {
                            proxy.scrollTo(first, anchor: .leading)
                        }
                    }
                }
            }
        }
    }
}

/// A date picker section for selecting when the application was submitted.
private struct DateAppliedSection: View {
    @Binding var dateApplied: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Date Applied", systemImage: "calendar")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            DatePicker(
                "Select a date:",
                selection: $dateApplied,
                in: ...Date(),
                displayedComponents: .date
            )
            .padding(.vertical)
        }
    }
}

/// Displays the attached resume file name and provides buttons to attach or remove a resume.
private struct ResumeSection: View {
    /// The name of the currently attached resume file, or `nil` if none.
    var resumeFileName: String?
    /// Called when the user taps the attach button to pick a new file.
    var onPick: () -> Void
    /// Called when the user taps the trash button to remove the attached resume.
    var onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Resume Used", systemImage: "doc.richtext")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.secondary)
                Text(resumeFileName ?? "No file selected")
                    .foregroundStyle(resumeFileName == nil ? .secondary : .primary)
                Spacer()
                if resumeFileName != nil {
                    Button(role: .destructive) {
                        onClear()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                Button {
                    onPick()
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
    }
}

/// A UIKit document picker wrapped for SwiftUI, allowing the user to select
/// a resume file (PDF, plain text, RTF, image, or raw data).
///
/// Returns the selected file's name and a security-scoped bookmark via the completion handler.
private struct DocumentPicker: UIViewControllerRepresentable {
    /// Represents a successfully picked file with its name and bookmark data.
    struct PickedFile {
        let fileName: String
        let bookmark: Data
    }

    /// Completion handler called with the pick result.
    var completion: (Result<PickedFile, Error>) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.pdf, .plainText, .rtf, .image, .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
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

/// A multi-line text editor section for adding freeform notes about the job application.
private struct JobNotesSection: View {
    @Binding var jobNotes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Job Notes", systemImage: "square.and.pencil")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                if jobNotes.isEmpty {
                    Text("Add notes...")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                TextEditor(text: $jobNotes)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 150)
                    .padding(8)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

#Preview {
    let sampleJob = JobApplication(
        companyName: "Meta",
        companyLogoName: "meta",
        position: "Software Engineering Intern - 2026",
        dateApplied: Date()
    )
    NavigationStack {
        JobDetailView(job: sampleJob)
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
