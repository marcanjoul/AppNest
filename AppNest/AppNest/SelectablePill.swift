import SwiftUI

// MARK: - Selectable Pill (for detail view pickers)

struct SelectablePill<T: Hashable & RawRepresentable>: View where T.RawValue == String {
    let option: T
    let isSelected: Bool
    let background: Color
    let foreground: Color
    let onTap: () -> Void

    var body: some View {
        Text(option.rawValue)
            .font(isSelected ? .subheadline.weight(.semibold) : .subheadline)
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, isSelected ? 10 : 8)
            .background(
                Capsule().fill(isSelected ? foreground : background)
            )
            .foregroundColor(isSelected ? .white : foreground)
            .onTapGesture {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                onTap()
            }
    }
}

// MARK: - Display-only Pill (for card view)

struct StatusPill: View {
    let text: String
    let background: Color
    let foreground: Color
    
    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(background)
            )
            .foregroundStyle(foreground)
    }
}