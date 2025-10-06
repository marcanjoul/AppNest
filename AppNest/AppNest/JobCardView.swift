import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct JobCardView: View {
    let job: JobApplication

    private var appliedRelativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Applied " + formatter.localizedString(for: job.dateApplied, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Company Logo
            Group {
                #if canImport(UIKit)
                if let data = job.company.logoImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                } else {
                    Image(job.company.logoName)
                        .resizable()
                }
                #else
                Image(job.company.logoName)
                    .resizable()
                #endif
            }
            .scaledToFill()
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(job.position)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)
                    
                Text(job.company.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

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

                Text(appliedRelativeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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

    // MARK: - Helpers
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

    private func color(for status: ApplicationStatus) -> Color {
        switch status {
        case .toApply: return .blue
        case .applied: return .yellow
        case .interview: return .gray
        case .offer: return .green
        case .rejected: return .red
        }
    }

    private func color(for season: ApplicationSeason) -> Color {
        switch season {
        case .spring: return .pink
        case .summer: return .yellow
        case .fall: return .brown
        case .winter: return .blue
        }
    }
}

private struct Pill: View {
    let text: String
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
