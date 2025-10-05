//
//  JobDetailView.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//

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
    // The source of truth for jobs across the app. We observe it so the UI can
    // react to changes coming from the model layer.
    @ObservedObject var viewModel: JobViewModel
    @Environment(\.dismiss) private var dismiss

    // The job we are editing. We keep the original around so the view model
    // knows which item to update when saving.
    var job: JobApplication

    // MARK: - Editable local state
    // These `@State` properties are local, editable copies of the job's fields.
    // We avoid editing the `job` directly so the user can cancel or navigate
    // away without mutating the shared model until they tap "Save Changes".
    @State private var company: Company
    @State private var position: String
    @State private var type: ApplicationType?
    @State private var status: ApplicationStatus?
    @State private var season: ApplicationSeason?
    @State private var dateApplied = Date()
    @State private var jobNotes: String

    // Hold the picked file's bookmark until Save is tapped
    @State private var _pendingResumeBookmark: Data? = nil
    @State private var resumeFileName: String? = nil
    @State private var isShowingDocumentPicker = false

    // Example of creating a Binding to a nested property (company.name).
    // NOTE: This computed binding is not used in this top-level view because
    // we pass `company` down to `JobInfoSection` where a similar binding is used.
    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name }, // what to show in the TextField
            set: { company.name = $0 } // how to update local state when user types
        )
    }

    // Disable save when required selections are missing
    private var isSaveDisabled: Bool {
        type == nil || status == nil
    }

    // MARK: - Initializer
    // We initialize our local `@State` properties from the incoming `job` so the
    // text fields and pickers show the current values when the screen appears.
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
        // Preload existing resume info if present
        // Note: These are non-persisted UI states; they reflect the current job values
        _resumeFileName = State(initialValue: job.resumeFileName)
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

                    // Subview that shows the company logo and lets you edit
                    // the position title and company name.
                    JobInfoSection(company: $company, position: $position)

                    // Horizontal pill selector for job type (e.g., Full-time, Internship).
                    TypePickerSection(type: $type)
                    
                    // Horizontal pill selector for application status (e.g., Applied, Interviewing).
                    StatusPickerSection(status: $status)

                    // Horizontal pill selector for season (e.g., Summer, Fall).
                    if let type, [.partTime, .internship, .temporary, .Co_op].contains(type) {
                        SeasonPickerSection(season: $season)
                    }

                    // Date picker for when the application was submitted.
                    DateAppliedSection(dateApplied: $dateApplied)
                    
                    // File upload section that shows the current resume file and lets the user pick or clear it
                    ResumeSection(
                        resumeFileName: resumeFileName,
                        onPick: { isShowingDocumentPicker = true },
                        onClear: { resumeFileName = nil }
                    )
                    
                    //Text Editor for when user wants to add notes about a position (e.g, benefits, requirements).
                    JobNotesSection(jobNotes: $jobNotes)
                }
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
        .simultaneousGesture(TapGesture().onEnded {
            #if canImport(UIKit)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            #endif
        })
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentPicker { result in
                switch result {
                case .success(let picked):
                    resumeFileName = picked.fileName
                    // Store bookmark data for persistence
                    // (We pass it on save; not persisted in state)
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
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        #endif
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    #if canImport(UIKit)
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

    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name },
            set: { company.name = $0 }
        )
    }

    #if canImport(UIKit)
    private var logoImage: Image {
        if let data = company.logoImageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        } else {
            return Image(company.logoName)
        }
    }
    #else
    private var logoImage: Image { Image(company.logoName) }
    #endif

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                logoImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
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
                        company.logoImageData = data
                    }
                }
            }
            .contextMenu {
                if company.logoImageData != nil {
                    Button(role: .destructive) {
                        company.logoImageData = nil
                    } label: {
                        Label("Remove Custom Logo", systemImage: "trash")
                    }
                }
            }

            // Editable fields for position and company name with a trailing pencil icon.
            VStack {
                HStack {
                    TextField("Position Title", text: $position)
                        .padding(.leading, 12)   // normal padding on the left
                        .padding(.trailing, 36) // extra padding so text doesn't overlap pencil
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
                        .padding(.leading, 12)   // normal padding on the left
                        .padding(.trailing, 36) // extra padding so text doesn't overlap pencil
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

/// A small "pill" view used by the type selector. Highlights when selected.
private struct jobTypePill: View {
    let option: ApplicationType
    let isSelected: Bool
    let onTap: () -> Void
    
    private var jobTypePillColor: Color {
        switch option {
        case .fullTime:
            return .green
        case .partTime:
            return .yellow
        case .internship:
            return .red
        case .contract:
            return .blue
        case .Co_op:
            return .gray
        case .temporary:
            return .purple
        }
    }
    var body: some View {
        Text(option.rawValue)
            .font(isSelected ? .headline.weight(.black) : .subheadline)
            .padding(.horizontal, isSelected ? 15 : 12)
            .padding(.vertical, isSelected ? 9 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobTypePillColor.opacity(0.9) : jobTypePillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                #if canImport(UIKit)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
                onTap()
            }
    }
}

/// A small "pill" view used by the status selector. Highlights when selected.
private struct jobStatusPill: View {
    let option: ApplicationStatus
    let isSelected: Bool
    let onTap: () -> Void
    
    private var jobStatusPillColor: Color {
        switch option {
        case .toApply:
            return .blue
        case .applied:
            return .yellow
        case .interview:
            return .gray
        case .offer:
            return .green
        case .rejected:
            return .red
        }
    }
    var body: some View {
        Text(option.rawValue)
            .font(isSelected ? .headline.weight(.black) : .subheadline)
            .padding(.horizontal, isSelected ? 15 : 12)
            .padding(.vertical, isSelected ? 9 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobStatusPillColor.opacity(0.9) : jobStatusPillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                #if canImport(UIKit)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
                onTap()
            }
    }
}

/// A small "pill" view used by the season selector. Highlights when selected.
private struct jobSeasonPill: View {
    let option: ApplicationSeason
    let isSelected: Bool
    let onTap: () -> Void

    private var jobSeasonPillColor: Color {
        switch option {
        case .spring:
            return .pink
        case .summer:
            return .yellow
        case .fall:
            return .brown
        case .winter:
            return .blue

        }
    }

    var body: some View {
        Text(option.rawValue)
            .font(isSelected ? .headline.weight(.black) : .subheadline)
            .padding(.horizontal, isSelected ? 15 : 12)
            .padding(.vertical, isSelected ? 9 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobSeasonPillColor.opacity(0.9) : jobSeasonPillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                #if canImport(UIKit)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
                onTap()
            }
    }
}
/// Lets the user pick a job type using horizontally scrolling pills.
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
                        // `ApplicationType.allCases` provides the list of options to render.
                        ForEach(orderedOptions, id: \.self) { option in
                            jobTypePill(
                                option: option,
                                isSelected: option == type,
                                onTap: {
                                    // Tapping toggles the selection. If the same pill is tapped again,
                                    // set it to `nil` to represent "no selection".
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
/// Lets the user pick a job status using horizontally scrolling pills.
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
                        // `ApplicationStatus.allCases` provides the list of options to render.
                        ForEach(orderedOptions, id: \.self) { option in
                            jobStatusPill(
                                option: option,
                                isSelected: option == status,
                                onTap: {
                                    // Tapping toggles the selection. If the same pill is tapped
                                    // again, we set it to `nil` to represent "no selection".
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
                // Using `id: \.self` requires `ApplicationSeason: Hashable`.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(orderedOptions, id: \.self) { option in
                            jobSeasonPill(
                                option: option,
                                isSelected: option == season,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)){
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
                in: ...Date(), // Closed range up to "now" (no future dates)
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
                // Start security-scoped access to create a bookmark
                let _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }
                let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
                completion(.success(PickedFile(fileName: url.lastPathComponent, bookmark: bookmark)))
            } catch {
                completion(.failure(error))
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // No-op; user cancelled
        }
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
    // Test data for the preview so you can see the view in Xcode's canvas.
    let testViewModel = JobViewModel()
    let sampleCompany = Company(name: "Meta", logoName: "meta")
    let sampleJob = JobApplication(
        company: sampleCompany,
        position: "Software Engineering Intern - 2026",
        dateApplied: Date(),
    )
    NavigationStack {
        JobDetailView(job: sampleJob, viewModel: testViewModel)
    }
}

