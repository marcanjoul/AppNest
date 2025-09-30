//
//  JobViewModel.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//

import SwiftUI

class JobViewModel: ObservableObject {
    @Published var applications: [JobApplication] = []

    func update(job: JobApplication, company: Company, position: String, type: ApplicationType, status: ApplicationStatus, season: ApplicationSeason?, dateApplied: Date, jobNotes: String?, resumeFileName: String? = nil, resumeBookmark: Data? = nil) {
        if let index = applications.firstIndex(where: { application in
            return application.id == job.id
        }) {
            applications[index].company = company
            applications[index].position = position
            applications[index].jobType = type
            applications[index].status = status
            applications[index].season = season
            applications[index].dateApplied = dateApplied
            applications[index].jobNotes = jobNotes
            applications[index].resumeFileName = resumeFileName
            applications[index].resumeBookmark = resumeBookmark
            
        }
    }
}
