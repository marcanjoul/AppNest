import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Job Card View

/// Displays a single job application as a card in the application list.
///
/// The card shows:
/// - Company logo (from assets or custom uploaded image)
/// - Position title
/// - Company name
/// - Pills for job type, status, and season
/// - Relative date when applied (e.g., "Applied 5 days ago")
/// - Chevron indicating it's tappable
///
/// The card uses a glassmorphic design with gradients and material effects.
struct JobCardView: View {
    /// The job application to display
    let job: JobApplication

    /// Generates a user-friendly relative time string for when the application was submitted.
    ///
    /// Examples: "Applied 2 days ago", "Applied 3 weeks ago"
    private var appliedRelativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Applied " + formatter.localizedString(for: job.dateApplied, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // MARK: Company Logo
            // Load logo from custom image data if available, otherwise use asset catalog
            Group {
                #if canImport(UIKit)
                // On iOS: try to load custom uploaded logo first
                if let data = job.company.logoImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                } else {
                    // Fall back to asset catalog logo
                    Image(job.company.logoName)
                        .resizable()
                }
                #else
                // On macOS or other platforms: use asset catalog only
                Image(job.company.logoName)
                    .resizable()
                #endif
            }
            .scaledToFill()
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)

            // MARK: Job Details
            VStack(alignment: .leading, spacing: 6) {
                // Position title
                Text(job.position)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)
                    
                // Company name
                Text(job.company.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Pills for job type, status, and season
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        if let type = job.jobType {
                            Pill(text: type.rawValue, color: color(for: type))
                        }
                        if let status = job.status {
                            Pill(text: status.rawValue, color: color(for: status))
                        }
                        if let season = job.season {
                            Pill(text: season.rawValue, color: color(for: season))
                        }
                    }
                }

                // Relative date applied
                Text(appliedRelativeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Navigation chevron indicator
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.quaternary)
        }
        .padding(16)
        // Glassmorphic background with material effect
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        // Subtle gradient overlay for visual depth
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.06),
                            Color.cyan.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        // Border stroke
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }

    // MARK: - Color Mapping Helpers
    
    /// Returns the appropriate color for a given application type.
    ///
    /// Color scheme:
    /// - Full-time: Green (permanent position)
    /// - Part-time: Yellow (flexible)
    /// - Contract: Blue (time-bound)
    /// - Internship: Red (learning opportunity)
    /// - Co-op: Gray (academic integration)
    /// - Temporary: Purple (short-term)
    private func color(for type: ApplicationType) -> Color {
        switch type {
        case .fullTime: return .green
        case .partTime: return .yellow
        case .contract: return .blue
        case .internship: return .red
        case .Co_op: return .gray
        case .temporary: return .purple
        }
    }

    /// Returns the appropriate color for a given application status.
    ///
    /// Color scheme reflects urgency and progress:
    /// - To Apply: Blue (action needed)
    /// - Applied: Yellow (pending)
    /// - Interview: Gray (in progress)
    /// - Offer: Green (success)
    /// - Rejected: Red (closed)
    private func color(for status: ApplicationStatus) -> Color {
        switch status {
        case .toApply: return .blue
        case .applied: return .yellow
        case .interview: return .gray
        case .offer: return .green
        case .rejected: return .red
        }
    }

    /// Returns the appropriate color for a given season.
    ///
    /// Colors match common seasonal associations:
    /// - Spring: Pink (flowers)
    /// - Summer: Yellow (sunshine)
    /// - Fall: Brown (leaves)
    /// - Winter: Blue (cold)
    private func color(for season: ApplicationSeason) -> Color {
        switch season {
        case .spring: return .pink
        case .summer: return .yellow
        case .fall: return .brown
        case .winter: return .blue
        }
    }
}

// MARK: - Pill Component

/// A small colored pill/badge for displaying tags like job type, status, or season.
///
/// Features:
/// - Colored background with 25% opacity
/// - Foreground text in the solid color
/// - Capsule shape with padding
/// - Bold text that doesn't wrap
private struct Pill: View {
    /// The text to display in the pill
    let text: String
    
    /// The accent color for this pill
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(color.opacity(0.25))
            )
            .foregroundStyle(color)
    }
    
}


// MARK: - Preview

#Preview {
    let sampleCompany = Company(name: "Meta", logoName: "meta")
    let sampleJob = JobApplication(
        company: sampleCompany,
        position: "Software Engineering Intern - 2026",
        jobType: .internship,
        status: .applied,
        season: .summer,
        dateApplied: Date().addingTimeInterval(-86_400 * 10)
    )

    return VStack(spacing: 19) {
        JobCardView(job: sampleJob)
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
