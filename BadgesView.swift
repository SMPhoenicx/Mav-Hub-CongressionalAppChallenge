//
//  BadgesView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//


import SwiftUI

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let isUnlocked: Bool
}

struct BadgesView: View {
    // Example data
    let badges: [Badge] = [
        Badge(name: "Hater", imageName: "hater", isUnlocked: true),
        Badge(name: "Post Lover", imageName: "lover", isUnlocked: true),
        Badge(name: "Five Day Streak", imageName: "fiveday", isUnlocked: false),
        Badge(name: "Ten Day Streak", imageName: "tenday", isUnlocked: false),
        Badge(name: "Student Council", imageName: "sac", isUnlocked: false),
        Badge(name: "Reputation Leader", imageName: "king", isUnlocked: false)
    ]
    
    @State private var selectedBadge: Badge? = nil
    
    var body: some View {
        VStack {
            Text("Select Your Badge")
                .font(.title)
                .bold()
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Unlocked badges
                    Text("Unlocked Badges")
                        .font(.headline)
                        .padding(.leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(badges.filter { $0.isUnlocked }) { badge in
                                BadgeView(badge: badge)
                                    .onTapGesture {
                                        selectedBadge = badge
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Locked badges
                    Text("Locked Badges")
                        .font(.headline)
                        .padding(.leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(badges.filter { !$0.isUnlocked }) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Show the selected badge
            if let selectedBadge = selectedBadge {
                Text("Selected Badge: \(selectedBadge.name)")
                    .padding()
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack {
            Image(badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(badge.isUnlocked ? Color.green : Color.gray, lineWidth: 3)
                )
                .opacity(badge.isUnlocked ? 1.0 : 0.5)
            
            Text(badge.name)
                .font(.caption)
                .foregroundColor(badge.isUnlocked ? .primary : .gray)
        }
        .frame(width: 100)
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
