//
//  AddView.swift
//  AppNest
//
//  Created by Assistant on 10/1/25.
//

import SwiftUI

struct AddView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.system(size: 48))
            Text("Add an Application")
                .font(.title2.weight(.semibold))
            Text("Paste an email, paste a link, or add manually. This screen is a placeholder and can be expanded to your flows.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Add")
    }
}

#Preview {
    NavigationStack { AddView() }
}
