//
//  ApplicationStatus.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//


import Foundation

struct Company: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var logoName: String  // e.g. "apple", "google", "meta"
}

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
}
enum ApplicationType: String, CaseIterable{
    case fullTime = "Full Time"
    case partTime = "Part Time"
    case contract = "Contract"
    case internship = "Internship"
    case Co_op = "Co-op"
    case temporary = "Temporary"
}

enum ApplicationSeason: String, CaseIterable{
    case winter = "Winter"
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
}

enum ApplicationStatus: String, CaseIterable {
    case toApply = "To Apply"
    case applied = "Applied"
    case interview = "Interview"
    case offer = "Offer"
    case rejected = "Rejected"
}


