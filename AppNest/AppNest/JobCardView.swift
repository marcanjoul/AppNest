import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A card view that displays a summary of a job application.
///
/// Shows the company logo, position title, company name, status pills
/// (job type, status, season), and a relative timestamp for when the
/// application was submitted. Used in the main applications list.
struct JobCardView: View {
    /// The job application to display in this card.
    let job: JobApplication

    /// Returns a human-readable relative date string (e.g., "Applied 3d ago").
    private var appliedRelativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Applied " + formatter.localizedString(for: job.dateApplied, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Company logo: shows custom image data, asset catalog image, or a fallback icon.
            Group {
                #if canImport(UIKit)
                if let data = job.companyLogoImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                } else if !job.companyLogoName.isEmpty {
                    Image(job.companyLogoName)
                        .resizable()
                } else {
                    Image(systemName: "building.2")
                        .resizable()
                        .padding(12)
                        .foregroundStyle(.secondary)
                }
                #else
                Image(job.companyLogoName)
                    .resizable()
                #endif
            }
            .scaledToFill()
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)

            // Job details: position, company name, status pills, and date.
            VStack(alignment: .leading, spacing: 6) {
                Text(job.position)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)
                    
                Text(job.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Horizontally scrollable row of status pills (type, status, season).
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        if let type = job.jobType {
                            Pill(text: type.rawValue, color: type.color)
                        }
                        if let status = job.status {
                            Pill(text: status.rawValue, color: status.color)
                        }
                        if let season = job.season {
                            Pill(text: season.rawValue, color: season.color)
                        }
                    }
                }

                Text(appliedRelativeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Navigation chevron indicating the card is tappable.
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.quaternary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
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
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}

/// A small, non-interactive pill used inside `JobCardView` to display
/// a colored label for job type, status, or season.
private struct Pill: View {
    /// The text displayed inside the pill (e.g., "Internship", "Applied").
    let text: String
    
    /// The accent color for the pill background and text.
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

#Preview {
    let sampleJob = JobApplication(
        companyName: "Meta",
        companyLogoName: "meta",
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
    .modelContainer(for: JobApplication.self, inMemory: true)
}
