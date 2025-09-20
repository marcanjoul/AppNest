//
//  JobDetailView.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//


import SwiftUI

struct JobDetailView: View {
    @ObservedObject var viewModel: JobViewModel
    var job: JobApplication
    
    @State private var company: String
    @State private var position: String
    @State private var status: ApplicationStatus
    @State private var dateApplied = Date()
    
    init(job: JobApplication, viewModel: JobViewModel) {
        self.job = job
        self.viewModel = viewModel
        _company = State(initialValue: job.company)
        _position = State(initialValue: job.position)
        _status = State(initialValue: job.status)
        _dateApplied = State(initialValue: job.dateApplied)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    JobInfoSection(company: $company, position: $position)
                    StatusPickerSection(status: $status)
                    DateAppliedSection(dateApplied: $dateApplied)

                    Button(action: {
                        viewModel.update(
                            job: job,
                            company: company,
                            position: position,
                            status: status,
                            dateApplied: dateApplied
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

private struct JobInfoSection: View {
    @Binding var company: String
    @Binding var position: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Job Info", systemImage: "briefcase.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            VStack(spacing: 15) {
                TextField("Company Name", text: $company)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 1.2)
                    )

                TextField("Position Title", text: $position)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 1.2)
                    )
            }
            .padding(.vertical)
        }
    }
}

private struct StatusPickerSection: View {
    @Binding var status: ApplicationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Job Status", systemImage: "rectangle.and.hand.point.up.left.fill")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            // Using id: \.self requires ApplicationStatus: Hashable; enums are Hashable by default.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(ApplicationStatus.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .font(option == status ? .headline : .subheadline) // bigger font for selected
                            .padding(.horizontal, option == status ? 16 : 12)
                            .padding(.vertical, option == status ? 10 : 8)
                            .background(
                                Capsule()
                                    .fill(option == status ? Color.accentColor : Color(.systemGray5))
                            )
                            .foregroundColor(option == status ? .white : .primary)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: status)

                            .onTapGesture {
                                withAnimation(.interpolatingSpring) {
                                    status = option
                                }
                            }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

private struct DateAppliedSection: View {
    @Binding var dateApplied: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Date Applied", systemImage: "calendar")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            VStack(spacing: 20) {
                DatePicker(
                    "Select a date:",
                    selection: $dateApplied,
                    in: ...Date(),
                    displayedComponents: .date
                )
            }
            .padding()
        }
    }
}

#Preview {
    let testViewModel = JobViewModel()
    let sampleJob = JobApplication(
        company: "Meta",
        position: "Software Engineering Intern",
        status: .applied,
        dateApplied: Date(),
    )
    return NavigationStack {
        JobDetailView(job: sampleJob, viewModel: testViewModel)
    }
}
