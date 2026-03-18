import SwiftUI

/// The central source of truth for all job applications in the app.
///
/// This view model manages the collection of job applications and provides
/// methods to update them. As an `ObservableObject`, any changes to `applications`
/// will automatically trigger UI updates in views that observe this model.
class JobViewModel: ObservableObject {
    /// The list of all job applications. Changes publish to observing views.
    @Published var applications: [JobApplication] = []

    /// Updates an existing job application with new values.
    ///
    /// This method finds the job by its ID and updates all fields in place.
    /// The UI will automatically refresh due to `@Published`.
    ///
    /// - Parameters:
    ///   - job: The original job application to update (used to find by ID)
    ///   - company: Updated company information (name and logo)
    ///   - position: Updated position title
    ///   - type: Job type (e.g., full-time, internship)
    ///   - status: Application status (e.g., applied, interview)
    ///   - season: Optional season for seasonal positions
    ///   - dateApplied: When the application was submitted
    ///   - jobNotes: Optional notes about the position
    ///   - resumeFileName: Optional name of attached resume file
    ///   - resumeBookmark: Optional security-scoped bookmark data for file access
    func update(job: JobApplication, company: Company, position: String, type: ApplicationType, status: ApplicationStatus, season: ApplicationSeason?, dateApplied: Date, jobNotes: String?, resumeFileName: String? = nil, resumeBookmark: Data? = nil) {
        /// Find the job in the array by matching its unique ID
        if let index = applications.firstIndex(where: { application in
            return application.id == job.id
        }) {
            /// Update all fields of the job at this index
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
