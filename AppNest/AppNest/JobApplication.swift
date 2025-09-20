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
    var status: ApplicationStatus
    var dateApplied: Date
}

enum ApplicationStatus: String, CaseIterable {
    case wishlist = "Wishlist"
    case applied = "Applied"
    case interview = "Interview"
    case offer = "Offer"
    case rejected = "Rejected"
}


