//
//  DarkStatusPill.swift
//  AppNest
//
//  Status pill with dot indicator for dark theme
//

import SwiftUI

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

#Preview {
    VStack(spacing: 12) {
        DarkStatusPill(status: .applied)
        DarkStatusPill(status: .interview)
        DarkStatusPill(status: .offer)
        DarkStatusPill(status: .rejected)
        
        Divider()
        
        DarkTypeTag(text: "Internship")
        DarkTypeTag(text: "Full-time")
    }
    .padding()
    .background(DarkTheme.background)
}
