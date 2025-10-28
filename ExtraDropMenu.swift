//
//  HamDropMenu.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 4/18/25.
//

import SwiftUI

struct ExtraDropMenu: View {
    @Binding var isMenuOpen: Bool
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true

    @State private var showLeaderboard = false
    @State private var showArticles = false
    @State private var showGame = false
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor: Color = darkMode ? .white : .black

        ZStack {
            Button {
                isMenuOpen = false
                showLeaderboard = true
            } label: {
                ZStack {
                    if #available(iOS 17.0, *) {
                        Capsule()
                            .fill(.regularMaterial)
                            .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            .frame(width: 105, height: 45)
                    } else {
                        Capsule()
                            .fill(textColor)
                            .frame(width: 105, height: 45)
                            .overlay(
                                Capsule()
                                    .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            )
                    }
                    HStack{
                        Image(systemName: "trophy")
                            .resizable()
                            .frame(width: 16, height: 20.0)
                            .foregroundStyle(darkMode ? .white : .black)
                        Text("Ranks")
                            .foregroundStyle(darkMode ? .white : .black)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
            }
            .padding(.horizontal, 8)
            .displayOnMenuOpen(isMenuOpen, offset: CGFloat(50))

            Button {
                isMenuOpen = false
                showArticles = true
            } label: {
                ZStack {
                    if #available(iOS 17.0, *) {
                        Capsule()
                            .fill(.regularMaterial)
                            .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            .frame(width: 105, height: 45)
                    } else {
                        Capsule()
                            .fill(textColor)
                            .frame(width: 105, height: 45)
                            .overlay(
                                Capsule()
                                    .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            )
                    }
                    HStack{
                        Image(systemName: "newspaper")
                            .resizable()
                            .frame(width: 16, height: 20.0)
                            .foregroundStyle(darkMode ? .white : .black)
                        Text("Review")
                            .foregroundStyle(darkMode ? .white : .black)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
            }
            .padding(.horizontal, 8)
            .displayOnMenuOpen(isMenuOpen, offset: CGFloat(100))
            Button {
                isMenuOpen = false
                showGame = true
            } label: {
                ZStack {
                    if #available(iOS 17.0, *) {
                        Capsule()
                            .fill(.regularMaterial)
                            .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            .frame(width: 105, height: 45)
                    } else {
                        Capsule()
                            .fill(textColor)
                            .frame(width: 105, height: 45)
                            .overlay(
                                Capsule()
                                    .stroke(darkMode == isLight ? color : textColor, lineWidth: 2)
                            )
                    }
                    HStack{
                        Image(systemName: "gamecontroller")
                            .resizable()
                            .frame(width: 18, height: 16.0)
                            .foregroundStyle(darkMode ? .white : .black)
                        Text("Games")
                            .foregroundStyle(darkMode ? .white : .black)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
            }
            .padding(.horizontal, 8)
            .displayOnMenuOpen(isMenuOpen, offset: CGFloat(150))
            ZStack {
                Capsule()
                    .frame(width: 105, height: 35)
                    .foregroundColor(color)
                HStack{
                    Image(systemName: "list.bullet")
                        .foregroundColor(isLight ? .black : .white)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Menu")
                        .foregroundStyle(isLight ? .black : .white)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }
            .zIndex(3)

            // Hidden NavigationLinks
            NavigationLink(destination: LeaderboardView(), isActive: $showLeaderboard) {
                EmptyView()
            }.hidden()

            NavigationLink(destination: ArticlesView(), isActive: $showArticles) {
                EmptyView()
            }.hidden()
            NavigationLink(destination: WordleGameView(), isActive: $showGame) {
                EmptyView()
            }.hidden()
        }
        .preferredColorScheme(darkMode ? .dark : .light)
    }

    private func loadColor() -> Color? {
        guard !selectedColorData.isEmpty else {
            return nil
        }

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

#Preview {
    TabControl()
}
