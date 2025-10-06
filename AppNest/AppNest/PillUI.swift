//
//  PillUI.swift
//  AppNest
//
//  Created by Mark Anjoul on 10/6/25.
//


//
//  PillUI.swift
//  AppNest
//
//  Created by Mark Anjoul on 10/5/25.
//

import SwiftUI

// MARK: - Universal Selectable Pill
struct SelectablePill<T: Hashable & RawRepresentable>: View where T.RawValue == String {
    let option: T
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Text(option.rawValue)
            .font(isSelected ? .headline.weight(.bold) : .subheadline)
            .padding(.horizontal, isSelected ? 15 : 12)
            .padding(.vertical, isSelected ? 9 : 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.9) : color.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                onTap()
            }
    }
}

// MARK: - Color Extensions

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
