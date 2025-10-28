//
//  ChatView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject private var authManager = AuthManager.shared
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                LoginView() // Login view for unauthenticated users
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated) // Smooth transition
        .onAppear {
            // Automatically check if the user is authenticated from a previous session
            authManager.checkAuthentication()
        }
    }
}

#Preview {
    ChatView()
}
