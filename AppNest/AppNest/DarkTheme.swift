//
//  DarkTheme.swift
//  AppNest
//
//  Design system for dark AppNest UI
//

import SwiftUI

/// Dark theme design system matching the mockup specifications
enum DarkTheme {
    
    // MARK: - Background Colors
    
    /// Near-black background with blue shift: #0a0a0f
    static let background = Color(red: 0x0a / 255.0, green: 0x0a / 255.0, blue: 0x0f / 255.0)
    
    // MARK: - Card Styles
    
    /// Card fill: rgba(255,255,255,0.04)
    static let cardFill = Color.white.opacity(0.04)
    
    /// Card border: rgba(255,255,255,0.09)
    static let cardBorder = Color.white.opacity(0.09)
    
    /// Card corner radius
    static let cardRadius: CGFloat = 20
    
    // MARK: - Text Colors
    
    /// Primary white text
    static let textPrimary = Color.white
    
    /// Secondary text: rgba(255,255,255,0.4)
    static let textSecondary = Color.white.opacity(0.4)
    
    /// Tertiary text: rgba(255,255,255,0.25)
    static let textTertiary = Color.white.opacity(0.25)
    
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
                tintColor: Color.white.opacity(0.6),
                fillColor: Color.white.opacity(0.08),
                borderColor: Color.white.opacity(0.15)
            )
        }
    }
    
    // MARK: - Type Tag Style
    
    /// Type tag fill: rgba(255,255,255,0.06)
    static let typeTagFill = Color.white.opacity(0.06)
    static let typeTagRadius: CGFloat = 8
    
    // MARK: - Stat Chip Style
    
    /// Stat chip fill: rgba(255,255,255,0.05)
    static let statChipFill = Color.white.opacity(0.05)
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
