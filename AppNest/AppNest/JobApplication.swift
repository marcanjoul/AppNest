import Foundation
import SwiftData

// MARK: - Company

/// Represents a company associated with a job application.
///
/// A company can display its logo in two ways:
/// 1. Using a pre-defined asset from the app's asset catalog (via `logoName`)
/// 2. Using custom image data uploaded by the user (via `logoImageData`)
///
/// Conforms to `Identifiable` for SwiftUI list operations and `Hashable` for
/// use in sets and as dictionary keys.
struct Company: Identifiable, Hashable {
    /// Unique identifier for this company instance
    let id = UUID()
    
    /// The company's name (e.g., "Apple", "Google", "Meta")
    var name: String
    
    /// Asset catalog name for the company's logo image
    var logoName: String
    
    /// Optional custom image data when the user uploads their own logo
    var logoImageData: Data? = nil
}

// MARK: - Job Application

/// Represents a single job application with all associated details.
///
/// Each application tracks the company, position, employment details, and current
/// status. It also supports attaching notes and resume files via security-scoped bookmarks.
///
/// Every application receives a unique identifier upon creation, ensuring SwiftUI can
/// distinguish between applications even if they have identical company names or positions.
struct JobApplication: Identifiable {
    let id = UUID()
// Every time a new job is created, it gets its own unique ID. SwiftUI won’t confuse two job applications even if they have the same company name.
    var company: Company
    var position: String
    var jobType: ApplicationType?
    var status: ApplicationStatus?
    var season: ApplicationSeason?
    var dateApplied: Date
    var jobNotes: String?
    var resumeFileName: String? = nil
    var resumeBookmark: Data? = nil
}

// MARK: - Application Type

/// The type of employment for a job application.
///
/// Provides common employment categories with user-friendly display names.
enum ApplicationType: String, CaseIterable {
    case fullTime = "Full Time"
    case partTime = "Part Time"
    case contract = "Contract"
    case internship = "Internship"
    case Co_op = "Co-op"
    case temporary = "Temporary"
}

// MARK: - Application Season

/// The season when a position is expected to start.
///
/// Particularly useful for tracking internships and co-op positions,
/// which are often organized by academic seasons.
enum ApplicationSeason: String, CaseIterable {
    case winter = "Winter"
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
}

// MARK: - Application Status

/// The current status of a job application in the hiring pipeline.
///
/// Tracks progression from initial planning through final outcome.
enum ApplicationStatus: String, CaseIterable {
    /// Planned to apply but not yet submitted
    case toApply = "To Apply"
    
    /// Application has been submitted
    case applied = "Applied"
    
    /// Currently in the interview process
    case interview = "Interview"
    
    /// Received a job offer
    case offer = "Offer"
    
    /// Application was rejected or position filled
    case rejected = "Rejected"
}


