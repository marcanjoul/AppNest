//
//  ApplicationStatus.swift
//  AppNest
//
//  Created by Mark Anjoul on 9/13/25.
//


import Foundation

struct JobApplication: Identifiable {
    let id = UUID()
// Every time a new job is created, it gets its own unique ID. SwiftUI won’t confuse two job applications even if they have the same company name.
    var company: String
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


