//
//  DarkStatusPill.swift
//  AppNest
//
//  Status pill with dot indicator for dark theme
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Status pill with tinted fill, colored border, and dot indicator
struct DarkStatusPill: View {
    let status: ApplicationStatus
    
    private var style: DarkTheme.StatusStyle {
        DarkTheme.statusStyle(for: status)
    }
    
    private var displayText: String {
        switch status {
        case .interview:
            return "Interviewing"
        default:
            return status.rawValue
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Dot indicator
            Circle()
                .fill(style.tintColor)
                .frame(width: 6, height: 6)
            
            Text(displayText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(style.tintColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(style.fillColor)
                .overlay(
                    Capsule()
                        .strokeBorder(style.borderColor, lineWidth: 1)
                )
        )
    }
}

/// Type tag with muted styling
struct DarkTypeTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DarkTheme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: DarkTheme.typeTagRadius, style: .continuous)
                    .fill(DarkTheme.typeTagFill)
            )
    }
}

/// Stat chip for displaying statistics on the main screen
struct StatChip: View {
    let number: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(number)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DarkTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DarkTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: DarkTheme.statChipRadius, style: .continuous)
                .fill(DarkTheme.statChipFill)
        )
    }
}

/// Dark themed job card for the applications list
struct DarkJobCardView: View {
    let job: JobApplication
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: job.dateApplied)
    }
    
    private var initial: String {
        String(job.companyName.prefix(1)).uppercased()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Company avatar
            Group {
                #if canImport(UIKit)
                if let data = job.companyLogoImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else if !job.companyLogoName.isEmpty, UIImage(named: job.companyLogoName) != nil {
                    Image(job.companyLogoName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text(initial)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(DarkTheme.avatarGradient(for: job.companyName))
                }
                #else
                Text(initial)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DarkTheme.avatarGradient(for: job.companyName))
                #endif
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(job.position)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DarkTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(job.companyName)
                    .font(.system(size: 14))
                    .foregroundStyle(DarkTheme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if let status = job.status {
                        DarkStatusPill(status: status)
                    }
                    if let type = job.jobType {
                        DarkTypeTag(text: type.rawValue)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DarkTheme.cardRadius, style: .continuous)
                .fill(DarkTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: DarkTheme.cardRadius, style: .continuous)
                        .strokeBorder(DarkTheme.cardBorder, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        DarkStatusPill(status: .applied)
        DarkStatusPill(status: .interview)
        DarkStatusPill(status: .offer)
        DarkStatusPill(status: .rejected)
        
        Divider()
        
        DarkTypeTag(text: "Internship")
        DarkTypeTag(text: "Full-time")
        
        Divider()
        
        HStack(spacing: 12) {
            StatChip(number: 12, label: "Applied")
            StatChip(number: 3, label: "Interviewing")
        }
        
        Divider()
        
        DarkJobCardView(job: JobApplication(
            companyName: "Google",
            companyLogoName: "google",
            position: "Software Engineering Intern",
            jobType: .internship,
            status: .applied,
            season: .summer,
            dateApplied: Date()
        ))
    }
    .padding()
    .background(DarkTheme.background)
}
