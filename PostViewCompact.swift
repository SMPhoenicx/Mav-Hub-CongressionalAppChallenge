//
//  ProfilePostView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//

import SwiftUI
import FirebaseFirestore

struct PostViewCompact: View {
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    let post: Post
    let onDelete: (Post) -> Void // Callback for delete action

    var body: some View {
        let color = loadColor() ?? .orange
        VStack(alignment: .leading, spacing: 12) {
            
            // Top row: Profile + Compact Voting
            HStack(alignment: .top, spacing: 12) {
                PostHeaderView(profileImageURL: post.profileImageURL,
                               username: post.username,
                               timestamp: post.timestamp,
                               tag: post.tag
                )
                
                Spacer()
                
                CompactVotingView(votes: post.votes) {
                    onDelete(post) // Call delete action
                }
            }
            
            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
                    .foregroundColor(.white)
            }

            // Post Image
            if !post.imageURL.isEmpty {
                AsyncImage(url: URL(string: post.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: 300)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 1)
                )
                .shadow(radius: 4)
        )
        .padding(.horizontal)
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
/// Compact voting view for showing upvote/downvote arrow, count, and delete button.
struct CompactVotingView: View {
    let votes: Int
    let onDelete: () -> Void // Callback for delete action

    private let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    private let gray = Color.gray

    var body: some View {
        HStack(spacing: 8) {
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
            }

            // Voting section
            Image(systemName: votes >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                .foregroundColor(votes >= 0 ? scarlet : gray)
                .font(.title3)

            Text("\(votes)")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
