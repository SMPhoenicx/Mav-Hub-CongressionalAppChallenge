import SwiftUI
import FirebaseFirestore

struct PostDetailView: View {
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()

    @ObservedObject var viewModel: FeedViewModel
    let post: Post

    @StateObject private var commentViewModel = CommentViewModel(postID: "")

    // For creating a new comment
    @State private var commentText: String = ""
    @State private var selectedImage: UIImage? = nil

    private var livePost: Post? {
        viewModel.posts.first(where: { $0.id == post.id })
    }

    private var currentVotes: Int {
        livePost?.votes ?? post.votes
    }

    private var currentUserVote: Int {
        viewModel.userVotes[post.id] ?? 0
    }

    private var isUserPost: Bool {
        AuthManager.shared.userName == (livePost?.username ?? post.username)
    }

    init(viewModel: FeedViewModel, post: Post) {
        self.viewModel = viewModel
        self.post = post
        let commentVM = CommentViewModel(postID: post.id)
        _commentViewModel = StateObject(wrappedValue: commentVM)
    }

    var body: some View {
        let selectedColor = loadColor() ?? .orange
        VStack(spacing: 0) {
            topBar
            Divider().background(Color.gray.opacity(0.3))
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    postContentSection

                    Divider().background(Color.gray.opacity(0.3))

                    if isUserPost {
                        deletePostButton
                    }

                    // Comment input view
                    CommentInputView(
                        commentText: $commentText,
                        selectedImage: $selectedImage,
                        onSend: {
                            commentViewModel.createComment(
                                text: commentText,
                                image: selectedImage
                            )
                            commentText = ""
                            selectedImage = nil
                        }
                    )

                    Divider().background(Color.gray.opacity(0.3))

                    // Comments list view
                    CommentsListView(commentViewModel: commentViewModel)
                }
                .padding(.bottom, 96)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            commentViewModel.fetchComments()
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
    private var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title) // Increased font size
                    .foregroundColor(.white)
            }
            Spacer()
            Text("Post")
                .font(.body) // Increased font size
                .bold() // Make the text bold
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                // Share action
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title) // Increased font size
                    .foregroundColor(.white)
            }
            .opacity(0) // If not needed, keep it invisible
        }
        .padding()
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let tag = livePost?.tag ?? post.tag, !tag.isEmpty, tag != "None" {
                Text(tag)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(colorForTag(tag))
                    .cornerRadius(6)
                    .padding(.top, 8)
            }

            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: livePost?.profileImageURL ?? post.profileImageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
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

                VStack(alignment: .leading, spacing: 4) {
                        Text(livePost?.username ?? post.username)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                        Text(livePost?.timestamp ?? post.timestamp)
                            .font(.footnote)
                            .foregroundColor(.gray)
                }.padding(.top, 8)
                Spacer()

                VotingView(
                    votes: currentVotes,
                    userVote: currentUserVote,
                    onUpVote: { handleVote(1) },
                    onDownVote: { handleVote(-1) }
                )
            }

            let caption = livePost?.caption ?? post.caption
            if !caption.isEmpty {
                Text(caption)
                    .font(.title3)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            let imageURL = livePost?.imageURL ?? post.imageURL
            if !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                }
            }

            if let location = (livePost?.location ?? post.location) {
                HStack {
                    MapSnapshotView(location: location)
                        .frame(width: 160, height: 120)
                        .cornerRadius(8)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }.padding()
    }

    private var deletePostButton: some View {
        Button(action: deletePost) {
            HStack {
                Image(systemName: "trash")
                
                .foregroundColor(.red)
                Text("Delete Post")
                    .foregroundColor(.black)
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(8)
        }
    }

    private func handleVote(_ newVote: Int) {
        let currentVote = currentUserVote
        let finalVote = (currentVote == newVote) ? 0 : newVote
        viewModel.setUserVote(for: livePost ?? post, to: finalVote)
    }

    private func deletePost() {
        Firestore.firestore().collection("posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully.")
                DispatchQueue.main.async {
                    viewModel.posts.removeAll { $0.id == post.id }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

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
        case "Announcement":     return Color.red
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


struct CommentInputView: View {
    @Binding var commentText: String
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false

    var onSend: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Display selected image if available
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(8)
                    .overlay(
                        Button(action: {
                            selectedImage = nil // Remove the image
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        .padding(4),
                        alignment: .topTrailing
                    )
            }

            HStack {
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }

                ZStack(alignment: .leading) {
                    if commentText.isEmpty {
                        Text("Write a comment...")
                            .foregroundColor(.white.opacity(0.6)) // Placeholder color
                            .padding(.leading, 8)
                    }
                    TextField("", text: $commentText)
                        .padding(8)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }

                Button("Send") {
                    onSend()
                }
                .padding()
                .disabled(commentText.isEmpty && selectedImage == nil)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 1)
                )
                
            }
        }
        .padding(.top, 8)
    }
}




struct CommentsListView: View {
    @ObservedObject var commentViewModel: CommentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments")
                .foregroundColor(.white)
                .font(.headline)

            ForEach(commentViewModel.comments) { comment in
                CommentRowView(
                    comment: comment,
                    userVote: commentViewModel.userCommentVotes[comment.id] ?? 0, // Fixed access to `userCommentVotes`
                    onUpVote: { commentViewModel.voteOnComment(comment, vote: 1) }, // Replaced `viewModel` with `commentViewModel`
                    onDownVote: { commentViewModel.voteOnComment(comment, vote: -1) }, // Replaced `viewModel` with `commentViewModel`
                    onDelete: { commentViewModel.deleteComment(comment) } // Replaced `viewModel` with `commentViewModel`
                )
            }
        }
    }
}

