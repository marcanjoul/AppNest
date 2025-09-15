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
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Job Info Card
                        VStack(alignment: .leading, spacing: 16) {
                                    Label("Job Info", systemImage: "briefcase.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(.primary)
                            
                                    VStack(spacing: 15) {
                                        TextField("Company Name", text: $company)
                                            .padding(12) // space inside the box
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(Color.gray.opacity(0.7), lineWidth: 1.2)
                                            )
                                        
                                        TextField("Position Title", text: $position)
                                            .padding(12) // space inside the box
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(Color.gray.opacity(0.7), lineWidth: 1.2)
                                            )
                                    }
                                .padding(.vertical)
                            
                                Label("Job Status", systemImage: "rectangle.and.hand.point.up.left.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 5) {
                                    ForEach(ApplicationStatus.allCases, id: \.self) { option in
                                        Text(option.rawValue)
                                            .font(.subheadline)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(option == status ? Color.accentColor : Color(.systemGray5)) // light gray for unselected
                                            )
                                            .foregroundColor(option == status ? .white : .primary)
                                            .onTapGesture {
                                                withAnimation(.bouncy) {
                                                    status = option
                                                }
                                            }
                                    }
                            }
                            .padding(.vertical)
                            
                            Label("Date Applied", systemImage: "calendar")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                            
                                VStack(spacing: 20) {
                                    DatePicker("Select a date:", selection: $dateApplied,
                                               in: ...Date(),
                                               displayedComponents: .date)
                                        }
                                        .padding()
                                    }
                            }
                        // Save Button
                        Button(action: {
                            viewModel.update(
                                job: job,
                                company: company,
                                position: position,
                                status: status,
                                date: dateApplied
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

#Preview {
    let testViewModel = JobViewModel()
    let sampleJob = JobApplication(
        company: "Meta",
        position: "Software Engineering Intern",
        status: .applied,
        dateApplied: Date()
    )
    return NavigationStack {
        JobDetailView(job: sampleJob, viewModel: testViewModel)
    }
}
