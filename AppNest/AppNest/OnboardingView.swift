//
//  OnboardingView.swift
//  AppNest
//
//  Created by Mark Anjoul on 3/18/26.
//


import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("briefcase.fill", "Track every application", "Keep all your job applications organized in one place."),
        ("envelope.open.fill", "Paste and parse", "Paste a confirmation email and let AppNest extract the details."),
        ("chart.bar.fill", "See your progress", "Stats, filters, and exports to stay on top of your search."),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 56))
                            .foregroundStyle(Theme.accent)
                            .padding(.bottom, 8)
                        
                        Text(pages[index].title)
                            .font(.title2.weight(.bold))
                            .multilineTextAlignment(.center)
                        
                        Text(pages[index].subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Theme.accent : Color(.tertiarySystemFill))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            .padding(.bottom, 32)
            
            // CTA button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            } else {
                Spacer()
                    .frame(height: 48)
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}