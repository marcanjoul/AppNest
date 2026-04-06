//
//  DarkTheme.swift
//  AppNest
//
//  Design system for AppNest UI with adaptive light/dark mode support
//

import SwiftUI

/// Adaptive theme design system that responds to light/dark mode
enum DarkTheme {
    
    // MARK: - Background Colors
    
    /// Adaptive background color
    static let background = Color(UIColor.systemBackground)
    
    // MARK: - Card Styles
    
    /// Adaptive card fill with better light mode contrast
    static let cardFill: Color = {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.secondarySystemGroupedBackground
            default:
                // In light mode, use a slightly darker gray for better visibility
                return UIColor.systemGray6
            }
        })
        #else
        return Color(UIColor.secondarySystemGroupedBackground)
        #endif
    }()
    
    /// Adaptive card border with enhanced visibility
    static let cardBorder: Color = {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.separator.withAlphaComponent(0.5)
            default:
                // In light mode, use a more visible border
                return UIColor.separator.withAlphaComponent(0.8)
            }
        })
        #else
        return Color(UIColor.separator).opacity(0.5)
        #endif
    }()
    
    /// Card corner radius
    static let cardRadius: CGFloat = 20
    
    // MARK: - Text Colors
    
    /// Primary text (adapts to light/dark mode)
    static let textPrimary = Color(UIColor.label)
    
    /// Secondary text (adapts to light/dark mode)
    static let textSecondary = Color(UIColor.secondaryLabel)
    
    /// Tertiary text (adapts to light/dark mode)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // MARK: - Status Colors
    
    struct StatusStyle {
        let tintColor: Color
        let fillColor: Color
        let borderColor: Color
    }
    
    static func statusStyle(for status: ApplicationStatus) -> StatusStyle {
        switch status {
        case .applied:
            let baseColor = Color(red: 0x5b / 255.0, green: 0xa8 / 255.0, blue: 0xf5 / 255.0) // #5ba8f5
            return StatusStyle(
                tintColor: baseColor,
                fillColor: baseColor.opacity(0.15),
                borderColor: baseColor.opacity(0.3)
            )
        case .interview:
            let baseColor = Color(red: 0xf5 / 255.0, green: 0xb9 / 255.0, blue: 0x4a / 255.0) // #f5b94a
            return StatusStyle(
                tintColor: baseColor,
                fillColor: baseColor.opacity(0.15),
                borderColor: baseColor.opacity(0.3)
            )
        case .offer:
            let baseColor = Color(red: 0x85 / 255.0, green: 0xc9 / 255.0, blue: 0x3a / 255.0) // #85c93a
            return StatusStyle(
                tintColor: baseColor,
                fillColor: baseColor.opacity(0.15),
                borderColor: baseColor.opacity(0.3)
            )
        case .rejected:
            let baseColor = Color(red: 0xf0 / 255.0, green: 0x70 / 255.0, blue: 0x70 / 255.0) // #f07070
            return StatusStyle(
                tintColor: baseColor,
                fillColor: baseColor.opacity(0.15),
                borderColor: baseColor.opacity(0.3)
            )
        case .toApply:
            return StatusStyle(
                tintColor: Color(UIColor.secondaryLabel),
                fillColor: Color(UIColor.tertiarySystemFill),
                borderColor: Color(UIColor.separator)
            )
        }
    }
    
    // MARK: - Type Tag Style
    
    /// Type tag fill (adaptive)
    static let typeTagFill = Color(UIColor.tertiarySystemFill)
    static let typeTagRadius: CGFloat = 8
    
    // MARK: - Stat Chip Style
    
    /// Stat chip fill (adaptive)
    static let statChipFill = Color(UIColor.secondarySystemGroupedBackground)
    static let statChipRadius: CGFloat = 14
    
    // MARK: - Section Label Style
    
    static let sectionLabelSize: CGFloat = 11
    static let sectionLabelSpacing: CGFloat = 1.2
    
    // MARK: - Company Avatar Gradients
    
    static let avatarGradients: [LinearGradient] = [
        LinearGradient(
            colors: [Color(red: 0x5b / 255.0, green: 0xa8 / 255.0, blue: 0xf5 / 255.0),
                     Color(red: 0x3b / 255.0, green: 0x88 / 255.0, blue: 0xd5 / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(red: 0xf5 / 255.0, green: 0xb9 / 255.0, blue: 0x4a / 255.0),
                     Color(red: 0xd5 / 255.0, green: 0x99 / 255.0, blue: 0x2a / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(red: 0x85 / 255.0, green: 0xc9 / 255.0, blue: 0x3a / 255.0),
                     Color(red: 0x65 / 255.0, green: 0xa9 / 255.0, blue: 0x1a / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(red: 0xf0 / 255.0, green: 0x70 / 255.0, blue: 0x70 / 255.0),
                     Color(red: 0xd0 / 255.0, green: 0x50 / 255.0, blue: 0x50 / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(red: 0x9b / 255.0, green: 0x87 / 255.0, blue: 0xf5 / 255.0),
                     Color(red: 0x7b / 255.0, green: 0x67 / 255.0, blue: 0xd5 / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(red: 0xf5 / 255.0, green: 0x87 / 255.0, blue: 0x9b / 255.0),
                     Color(red: 0xd5 / 255.0, green: 0x67 / 255.0, blue: 0x7b / 255.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
    ]
    
    static func avatarGradient(for name: String) -> LinearGradient {
        let hash = abs(name.hashValue)
        return avatarGradients[hash % avatarGradients.count]
    }
}
