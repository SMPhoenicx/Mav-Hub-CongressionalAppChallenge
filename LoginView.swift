//
//  LoginView.swift
//  Buzz
//
//  Created by Jack Vu on 1/4/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    
    @State private var isShowingTermsSheet = false // State to control sheet presentation
    
    var body: some View {
        let color1 = loadColor() ?? .orange
        let color2: Color = darkMode ? .black : .white
        
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [color1, color2]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Logo or Icon
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                // Title
                Text("Welcome to the Quad")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .multilineTextAlignment(.center)

                // Subtitle, fix to reflect values, intended uses
                Text("Connect, share, and explore with your friends!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 50)

                // Log In Button
                Button(action: {
                    authManager.startLogin() // Start OAuth login
                }) {
                    Text("Log In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [color1]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 40)
                .scaleEffect(1.05)
                .animation(.easeInOut(duration: 0.2), value: 1.05)

                // Footer
                HStack {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: {
                        isShowingTermsSheet = true // Show the terms sheet
                    }) {
                        Text("Terms & Conditions")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .sheet(isPresented: $isShowingTermsSheet) {
                        TermsAndConditionsView()
                    }
                }
                .padding(.top, 16)
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 24)
        }
    }
    
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
}

// MARK: - Terms and Conditions View

// MARK: - Preview

#Preview {
    LoginView()
}
