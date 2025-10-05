//
//  RootView.swift
//  AppNest
//
//  Created by Assistant on 10/1/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = JobViewModel()
    

    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                HomeView(viewModel: viewModel)
            }
            .tabItem {
                Label("Home", systemImage: "list.bullet")
            }

            // Add Tab (placeholder for paste email/link/manual entry flows)
            NavigationStack {
                AddView()
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle")
            }

            // Profile Tab (placeholder for stats, default resume, exports)
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    RootView()
}
