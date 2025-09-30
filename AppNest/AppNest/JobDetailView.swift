//
//  JobDetailView.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//

import SwiftUI

/// A screen that lets you view and edit a single `JobApplication`.
///
/// This view makes editable copies of the job's properties using `@State` so the
/// user can make changes locally. When "Save Changes" is tapped, we pass those
/// values back to the `JobViewModel` to update the original job.
struct JobDetailView: View {
    // The source of truth for jobs across the app. We observe it so the UI can
    // react to changes coming from the model layer.
    @ObservedObject var viewModel: JobViewModel

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

    // Example of creating a Binding to a nested property (company.name).
    // NOTE: This computed binding is not used in this top-level view because
    // we pass `company` down to `JobInfoSection` where a similar binding is used.
    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name }, // what to show in the TextField
            set: { company.name = $0 } // how to update local state when user types
        )
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
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
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
                    SeasonPickerSection(season: $season)

                    // Date picker for when the application was submitted.
                    DateAppliedSection(dateApplied: $dateApplied)
                    
                    //Text Editor for when user wants to add notes about a position (e.g, benefits, requirements).
                    JobNotesSection(jobNotes: $jobNotes)

                    // Save button: pushes the edited values back to the view model.
                    Button(action: {
                        // NOTE: We force-unwrap `status` and `season` here because
                        // the UI is designed to ensure a selection is made. If you
                        // want to be extra safe, consider guarding against nil and
                        // showing an alert if the user hasn't picked one.
                        viewModel.update(
                            job: job,
                            company: company,
                            position: position,
                            type: job.jobType!,
                            status: status!,
                            season: season!,
                            dateApplied: dateApplied,
                            jobNotes: jobNotes
                        )
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: 220)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Extracted Subviews

/// Displays the company logo and two text fields: position title and company name.
/// This view receives `@Binding` values so edits flow back up to `JobDetailView`'s
/// local `@State` properties.
private struct JobInfoSection: View {
    @Binding var company: Company
    @Binding var position: String

    // Binding to a nested value (`company.name`). This lets a TextField edit
    // just the name, while still keeping `company` as a whole in sync.
    private var companyNameBinding: Binding<String> {
        Binding(
            get: { company.name },
            set: { company.name = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // Company logo displayed as a circle with a subtle border and shadow.
            Image(company.logoName)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle()) // makes it perfectly round
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(radius: 2)

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
            .font(isSelected ? .headline : .subheadline)
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, isSelected ? 10 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobTypePillColor : jobTypePillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture(perform: onTap)
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
            .font(isSelected ? .headline : .subheadline)
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, isSelected ? 10 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobStatusPillColor : jobStatusPillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture(perform: onTap)
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
            .font(isSelected ? .headline : .subheadline)
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, isSelected ? 10 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? jobSeasonPillColor : jobSeasonPillColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture(perform: onTap)
    }
}
/// Lets the user pick a job type using horizontally scrolling pills.
private struct TypePickerSection: View {
    @Binding var type: ApplicationType?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Type", systemImage: "list.bullet")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    // `ApplicationType.allCases` provides the list of options to render.
                    ForEach(ApplicationType.allCases, id: \.self) { option in
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
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
/// Lets the user pick a job status using horizontally scrolling pills.
private struct StatusPickerSection: View {
    @Binding var status: ApplicationStatus?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Status", systemImage: "rectangle.and.hand.point.up.left.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    // `ApplicationStatus.allCases` provides the list of options to render.
                    ForEach(ApplicationStatus.allCases, id: \.self) { option in
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
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

/// Lets the user pick a season using horizontally scrolling pills.
private struct SeasonPickerSection: View {
    @Binding var season: ApplicationSeason?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Season", systemImage: "sun.snow.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            // Using `id: \.self` requires `ApplicationSeason: Hashable`.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(ApplicationSeason.allCases, id: \.self) { option in
                        jobSeasonPill(
                            option: option,
                            isSelected: option == season,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)){
                                    season = (season == option ? nil : option)
                                }
                            }
                        )
                    }
                }
                .padding(.vertical)
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

            VStack(spacing: 20) {
                DatePicker(
                    "Select a date:",
                    selection: $dateApplied,
                    in: ...Date(), // Closed range up to "now" (no future dates)
                    displayedComponents: .date
                )
            }
            .padding()
        }
    }
}

/// A Text editor section for any notes needed to be added about the job position( benefits, requirements, etc.)
private struct JobNotesSection: View{ 
    @Binding var jobNotes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Notes", systemImage: "square.and.pencil")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                TextEditor(text: $jobNotes)
                    .frame(minHeight: 100) // gives it space to type
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()
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
        jobType: .internship,
        status: .applied,
        season: .summer,
        dateApplied: Date(),
        jobNotes: "-401(k) benefits\n-Health insurance included"
    )
    NavigationStack {
        JobDetailView(job: sampleJob, viewModel: testViewModel)
    }
}
