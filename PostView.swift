import SwiftUI
import FirebaseFirestore

struct PostView: View {
    private let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()

    @ObservedObject var viewModel: FeedViewModel
    let post: Post
    
    private var userVote: Int {
        viewModel.userVotes[post.id] ?? 0
    }
    
    private var isUserPost: Bool {
        AuthManager.shared.userName == post.username
    }

    var body: some View {
        let color = loadColor() ?? .orange

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 1)
                )
                .shadow(radius: 4)

            HStack(alignment: .top, spacing: 12) {
                NavigationLink(value: post) {
                    VStack(alignment: .leading, spacing: 12) {
                        PostHeaderView(
                            profileImageURL: post.profileImageURL,
                            username: post.username,
                            timestamp: post.timestamp,
                            tag: post.tag
                        )
                        
                        if !post.caption.isEmpty {
                            Text(post.caption)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if !post.imageURL.isEmpty {
                            AsyncImage(url: URL(string: post.imageURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                default:
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                }
                            }
                        }
                        
                        HStack{
                            if let location = (post.location) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        
                                        MapSnapshotView(location: location)
                                            .frame(width: 160, height: 120)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.top, 8)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                }

                Spacer()

                HStack() {
                    if isUserPost {
                        Button(action: { deletePost() }) {
                            Image(systemName: "trash")
                                .foregroundColor(color)
                                .font(.title3)
                        }.padding(.top, 12)
                    }
                    // Voting area
                    VotingView(
                        votes: post.votes,
                        userVote: userVote,
                        onUpVote: { viewModel.setUserVote(for: post, to: 1) },
                        onDownVote: { viewModel.setUserVote(for: post, to: -1) }
                    ).padding(.top, 16)
                    
                    // Delete Button (only for user's own posts)
                }.padding(.trailing, 20)
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    private func deletePost() {
        Firestore.firestore().collection("posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully.")
                // Remove post from local view model
                viewModel.posts.removeAll { $0.id == post.id }
            }
        }
    }
    
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver
                .unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
}


struct VotingView: View {
    let votes: Int
    let userVote: Int
    let onUpVote: () -> Void
    let onDownVote: () -> Void
    
    private let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    
    var body: some View {
        VStack(spacing: 6) {
            // Upvote
            Button(action: onUpVote) {
                Image(systemName: userVote == 1 ? "arrowtriangle.up.fill" : "arrowtriangle.up")
                    .foregroundColor(userVote == 1 ? scarlet : .white)
                    .font(.title3)
            }
            
            // Current vote count
            Text("\(votes)")
                .font(.headline)
                .foregroundColor(.white)
            
            // Downvote
            Button(action: onDownVote) {
                Image(systemName: userVote == -1 ? "arrowtriangle.down.fill" : "arrowtriangle.down")
                    .foregroundColor(userVote == -1 ? .red : .white)
                    .font(.title3)
            }
        }
    }
}

/// Separate the header (profile image, username, timestamp) into its own subview.
struct PostHeaderView: View {
    let profileImageURL: String
    let username: String
    let timestamp: String
    
    // NEW: optional tag
    let tag: String?
    
    var body: some View {
        VStack{
            HStack(spacing: 8){
                // If there's a tag, show a color-coded badge
                if let tag = tag, !tag.isEmpty && tag != "None" {
                    Text(tag)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(colorForTag(tag))
                        .cornerRadius(6)
                }
                Spacer()
            }
            HStack(alignment: .top, spacing: 12) {
                
                // Profile Image
                AsyncImage(url: URL(string: profileImageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    default:
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                
                // Username + Timestamp + Tag
                VStack(alignment: .leading, spacing: 4) {
                        Text(username)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                        Text(timestamp)
                            .font(.footnote)
                            .foregroundColor(.gray)
                }.padding(.top, 8)
                Spacer()
            }
        }
    }
    
    // Provide a color for each tag
    private func colorForTag(_ tag: String) -> Color {
        switch tag {
        case "Discussion":       return Color.purple
        case "Student Council":  return Color.blue
        case "Clubs":            return Color.green
        case "Sports":           return Color.orange
        case "Events":           return Color.yellow
        case "Homework Help":    return Color.pink
        case "Arts":             return Color.indigo
        case "Tech & Coding":    return Color.cyan
        case "Announcement":    return Color.red
        case "Volunteering":     return Color.teal
        case "Lost & Found":     return Color.mint
        case "Lunch Menu":       return Color.brown
        case "Memes":            return Color.gray
        case "Class News":       return Color.pink
        case "Library":          return Color.brown
        case "Wellness":         return Color.mint
        case "Dorm Life":        return Color.blue
        case "Sports Updates":   return Color.orange
        case "Celebrations":     return Color.red
        default:
            return Color.gray
        }
    }
}


