//
//  ChatTabView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//

import SwiftUI

struct ChatTabControl: View {
    init() {
        // Customize the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Scarlet, black, and white theme
        appearance.backgroundColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.14, blue: 0.0, alpha: 1.0) // Scarlet
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 1.0, green: 0.14, blue: 0.0, alpha: 1.0)] // Scarlet
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            CommunityView()
                .tabItem{
                    Label("Community", systemImage: "person.3.fill")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            ChatSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ChatTabControl()
}
