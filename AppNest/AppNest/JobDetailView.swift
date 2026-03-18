import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

/// A screen that lets you view and edit a single `JobApplication`.
///
/// This view makes editable copies of the job's properties using `@State` so the
/// user can make changes locally. When "Save Changes" is tapped, we pass those
/// values back to the `JobViewModel` to update the original job.
struct JobDetailView: View {
    /// The source of truth for jobs across the app. We observe it so the UI can
    /// react to changes coming from the model layer.
    @ObservedObject var viewModel: JobViewModel
    @Environment(\.dismiss) private var dismiss

    /// The job we are editing. We keep the original around so the view model
    /// knows which item to update when saving.
    var job: JobApplication

    // MARK: - Editable local state
    
    /// These `@State` properties are local, editable copies of the job's fields.
    /// We avoid editing the `job` directly so the user can cancel or navigate
    /// away without mutating the shared model until they tap "Save Changes".
    @State private var company: Company
    @State private var position: String
    @State private var type: ApplicationType?
    @State private var status: ApplicationStatus?
    @State private var season: ApplicationSeason?
    @State private var dateApplied = Date()
    @State private var jobNotes: String

    /// Hold the picked file's bookmark until Save is tapped
    @State private var _pendingResumeBookmark: Data? = nil
    @State private var resumeFileName: String? = nil
    @State private var isShowingDocumentPicker = false

    /// Example of creating a Binding to a nested property (company.name).
    /// NOTE: This computed binding is not used in this top-level view because
    /// we pass `company` down to `JobInfoSection` where a similar binding is used.
    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name },
            set: { company.name = $0 }
        )
    }

    /// Disable save when required selections are missing
    private var isSaveDisabled: Bool {
        type == nil || status == nil
    }

    // MARK: - Initializer
    
    /// We initialize our local `@State` properties from the incoming `job` so the
    /// text fields and pickers show the current values when the screen appears.
    init(job: JobApplication, viewModel: JobViewModel) {
        self.job = job
        self.viewModel = viewModel
        _company = State(initialValue: job.company)
        _position = State(initialValue: job.position)
        _type = State(initialValue: job.jobType)
        _status = State(initialValue: job.status)
        _season = State(initialValue: job.season)
        _dateApplied = State(initialValue: job.dateApplied)
        _jobNotes = State(initialValue: job.jobNotes ?? "")
        _resumeFileName = State(initialValue: job.resumeFileName)
    }

    // MARK: - Body
    
    var body: some View {
        ZStack {
            /// Background layer: Frosted glass effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            /// Decorative gradient overlay for visual depth
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
                    JobInfoSection(company: $company, position: $position)
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
                /// Clear season when switching to job types that don't have seasons
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
        /// Present document picker sheet when user wants to attach a resume
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
        /// Floating save button pinned to bottom of screen
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    Button {
                        #if canImport(UIKit)
                        /// Provide haptic feedback when saving
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        #endif
                        /// Update the job in the view model with all edited values
                        viewModel.update(
                            job: job,
                            company: company,
                            position: position,
                            type: type!,
                            status: status!,
                            season: season,
                            dateApplied: dateApplied,
                            jobNotes: jobNotes,
                            resumeFileName: resumeFileName,
                            resumeBookmark: _pendingResumeBookmark
                        )
                        _pendingResumeBookmark = nil
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isSaveDisabled)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        /// Keyboard toolbar with Done button
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    #if canImport(UIKit)
                    /// Dismiss keyboard when Done button is tapped
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    #endif
                }
            }
        }
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Extracted Subviews

/// Displays the company logo and two text fields: position title and company name.
/// This view receives `@Binding` values so edits flow back up to `JobDetailView`'s
/// local `@State` properties.
private struct JobInfoSection: View {
    @Binding var company: Company
    @Binding var position: String

    @State private var pickerItem: PhotosPickerItem? = nil

    /// Creates a two-way binding to the nested company.name property
    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name },
            set: { company.name = $0 }
        )
    }

    #if canImport(UIKit)
    /// Load custom uploaded image if available, otherwise use asset catalog
    private var logoImage: Image {
        if let data = company.logoImageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        } else {
            return Image(company.logoName)
        }
    }
    #else
    /// On non-iOS platforms, always use asset catalog
    private var logoImage: Image { Image(company.logoName) }
    #endif

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            /// Tappable logo with PhotosPicker for choosing a custom image
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
                        /// Edit indicator badge
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
            /// When a new image is picked, load it and save to the company
            .onChange(of: pickerItem) { oldValue, newValue in
                guard let item = newValue else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        company.logoImageData = data
                    }
                }
            }
            /// Long-press menu to remove custom logo
            .contextMenu {
                if company.logoImageData != nil {
                    Button(role: .destructive) {
                        company.logoImageData = nil
                    } label: {
                        Label("Remove Custom Logo", systemImage: "trash")
                    }
                }
            }

            /// Editable text fields with pencil indicators
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
                    TextField("Company Name", text: companyNameBinding)
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

/// Lets the user pick a job type using horizontally scrolling pills.
private struct TypePickerSection: View {
    @Binding var type: ApplicationType?

    /// Puts the selected option first, then the rest in order
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
                                        /// Toggle: tap again to deselect
                                        type = (type == option ? nil : option)
                                    }
                                }
                            )
                            .id(option)
                        }
                    }
                }
                .padding(.vertical)
                /// Auto-scroll to keep selected option visible at the left
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
/// Lets the user pick a job status using horizontally scrolling pills.
private struct StatusPickerSection: View {
    @Binding var status: ApplicationStatus?

    /// Puts the selected option first, then the rest in order
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

/// Lets the user pick a season using horizontally scrolling pills.
private struct SeasonPickerSection: View {
    @Binding var season: ApplicationSeason?

    /// Puts the selected option first, then the rest in order
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

/// A simple date picker limited to dates up to today (can't pick a future date).
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

/// A section that displays the current resume file (if any) and lets the user pick or clear it.
private struct ResumeSection: View {
    var resumeFileName: String?
    var onPick: () -> Void
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

/// A UIKit-based document picker wrapped for SwiftUI that returns a security-scoped bookmark for persistence.
private struct DocumentPicker: UIViewControllerRepresentable {
    /// Structure holding the picked file's information
    struct PickedFile {
        let fileName: String
        let bookmark: Data
    }

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
                /// Request security-scoped access to the file
                let _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }
                /// Create bookmark data that can be saved and used to access this file later
                let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
                completion(.success(PickedFile(fileName: url.lastPathComponent, bookmark: bookmark)))
            } catch {
                completion(.failure(error))
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
}

/// A Text editor section for any notes needed to be added about the job position( benefits, requirements, etc.)
private struct JobNotesSection: View{ 
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
// MARK: - Preview

#Preview {
    let testViewModel = JobViewModel()
    let sampleCompany = Company(name: "Meta", logoName: "meta")
    let sampleJob = JobApplication(
        company: sampleCompany,
        position: "Software Engineering Intern - 2026",
        dateApplied: Date()
    )
    
    return NavigationStack {
        JobDetailView(job: sampleJob, viewModel: testViewModel)
    }
}

