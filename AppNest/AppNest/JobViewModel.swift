//
//  JobViewModel.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//


import SwiftUI

class JobViewModel: ObservableObject {
    @Published var applications: [JobApplication] = []

    func update(job: JobApplication, company: String, position: String, status: ApplicationStatus, date: Date) {
        if let index = applications.firstIndex(where: { application in
            return application.id == job.id
        }) {
            applications[index].company = company
            applications[index].position = position
            applications[index].status = status
            applications[index].dateApplied = date
        }
    }
}
