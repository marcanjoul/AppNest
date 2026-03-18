import SwiftUI

// MARK: - Universal Selectable Pill

/// A reusable pill-shaped button that can display any enum with a String raw value.
///
/// This generic component adapts its appearance based on selection state:
/// - **Selected**: Bold text, larger size, solid color background, white text
/// - **Unselected**: Regular text, smaller size, translucent background, default text color
///
/// The pill provides haptic feedback on tap (iOS only) and supports any
/// `Hashable` enum that has `String` raw values.
///
/// - Note: The generic constraint `T.RawValue == String` ensures the option
///   can be displayed as text.
struct SelectablePill<T: Hashable & RawRepresentable>: View where T.RawValue == String {
    /// The enum value this pill represents (e.g., `.internship`, `.applied`)
    let option: T
    
    /// Whether this pill is currently selected
    let isSelected: Bool
    
    /// The accent color for this pill (background when selected, tint when not)
    let color: Color
    
    /// Callback invoked when the pill is tapped
    let onTap: () -> Void

    var body: some View {
        Text(option.rawValue)
            /// Selected pills are bolder and slightly larger
            .font(isSelected ? .headline.weight(.bold) : .subheadline)
            .padding(.horizontal, isSelected ? 15 : 12)
            .padding(.vertical, isSelected ? 9 : 8)
            .background(
                Capsule()
                    /// Selected: nearly opaque color, Unselected: very translucent
                    .fill(isSelected ? color.opacity(0.9) : color.opacity(0.2))
            )
            /// White text when selected for contrast, default color when not
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                #if canImport(UIKit)
                /// Provide subtle haptic feedback on tap (iOS/iPadOS only)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                onTap()
            }
    }
}

// MARK: - Color Extensions

/// Extends `ApplicationType` to provide semantic colors for each job type.
///
/// Color meanings:
/// - Green: Permanent positions (full-time)
/// - Yellow: Flexible arrangements (part-time)
/// - Blue: Time-bound contracts
/// - Red: Learning opportunities (internships)
/// - Gray: Academic programs (co-op)
/// - Purple: Short-term work (temporary)
extension ApplicationType {
    var color: Color {
        switch self {
        case .fullTime: return .green
        case .partTime: return .yellow
        case .internship: return .red
        case .contract: return .blue
        case .Co_op: return .gray
        case .temporary: return .purple
        }
    }
}

/// Extends `ApplicationStatus` to provide colors that reflect urgency and progress.
///
/// Color meanings:
/// - Blue: Action needed (to apply)
/// - Yellow: Waiting (applied)
/// - Gray: In progress (interview)
/// - Green: Success (offer)
/// - Red: Closed (rejected)
extension ApplicationStatus {
    var color: Color {
        switch self {
        case .toApply: return .blue
        case .applied: return .yellow
        case .interview: return .gray
        case .offer: return .green
        case .rejected: return .red
        }
    }
}

/// Extends `ApplicationSeason` to provide colors matching seasonal associations.
///
/// Color meanings:
/// - Pink: Spring (flowers)
/// - Yellow: Summer (sunshine)
/// - Brown: Fall (autumn leaves)
/// - Blue: Winter (cold, ice)
extension ApplicationSeason {
    var color: Color {
        switch self {
        case .spring: return .pink
        case .summer: return .yellow
        case .fall: return .brown
        case .winter: return .blue
        }
    }
}
