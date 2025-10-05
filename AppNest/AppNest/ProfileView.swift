//
//  ProfileView.swift
//  AppNest
//
//  Created by Assistant on 10/1/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
            Text("Profile")
                .font(.title2.weight(.semibold))
            Text("Stats, most-applied companies, exports, and default resume settings will live here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
