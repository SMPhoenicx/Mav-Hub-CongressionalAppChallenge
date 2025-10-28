//
//  CommentView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//

import SwiftUI

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct CommentRowView: View {
    let comment: Comment
    let userVote: Int
    let onUpVote: () -> Void
    let onDownVote: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Profile row
            HStack(alignment: .center, spacing: 8) {
                AsyncImage(url: URL(string: comment.profileImageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Color.gray
                    }
                }
                .frame(width: 30, height: 30)
                .clipShape(Circle())

                Text(comment.username)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                // Conditionally show the delete button if current user is the owner
                if comment.userID == AuthManager.shared.userID {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
            }

            // Comment text
            Text(comment.text)
                .foregroundColor(.white)

            // Optional image if any
            if let imageURL = comment.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                    default:
                        Color.gray
                    }
                }
                .cornerRadius(8)
            }

            // Voting row
            HStack {
                Button(action: onUpVote) {
                    Image(systemName: userVote == 1 ? "arrowtriangle.up.fill" : "arrowtriangle.up")
                        .resizable()
                        .frame(width: 24, height: 24) // Increased size
                        .foregroundColor(userVote == 1 ? .green : .white)
                }

                Text("\(comment.votes)")
                    .foregroundColor(.white)
                    .font(.headline)

                Button(action: onDownVote) {
                    Image(systemName: userVote == -1 ? "arrowtriangle.down.fill" : "arrowtriangle.down")
                        .resizable()
                        .frame(width: 24, height: 24) // Increased size
                        .foregroundColor(userVote == -1 ? .red : .white)
                }
            }
            .font(.title2) // Increased font size
        }
        .padding(8)
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
    }
}



class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var userCommentVotes: [String: Int] = [:]
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let userID = AuthManager.shared.userID
    private let userName = AuthManager.shared.userName  // or however you access the current username
    
    private let postID: String
    
    init(postID: String) {
        self.postID = postID
    }
    
    // MARK: - Fetch Comments
    func fetchComments() {
        db.collection("posts")
            .document(postID)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching comments: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                
                var newComments: [Comment] = []
                for doc in docs {
                    let data = doc.data()
                    guard
                        let userID = data["userID"] as? String,
                        let username = data["username"] as? String,
                        let profileURL = data["profileImageURL"] as? String,
                        let text = data["text"] as? String,
                        let votes = data["votes"] as? Int,
                        let timestamp = data["timestamp"] as? Timestamp
                    else { continue }
                    
                    let comment = Comment(
                        id: doc.documentID,
                        userID: userID,
                        username: username,
                        profileImageURL: profileURL,
                        timestamp: timestamp.dateValue(),
                        text: text,
                        imageURL: data["imageURL"] as? String,
                        votes: votes
                    )
                    newComments.append(comment)
                }
                
                DispatchQueue.main.async {
                    self.comments = newComments
                    self.fetchUserCommentVotes()
                }
            }
    }
    
    // MARK: - Create Comment
    func createComment(text: String, image: UIImage? = nil) {
        // 1) First, fetch the user’s profile URL from Firestore
        fetchProfileImageURL { [weak self] fetchedProfileURL in
            guard let self = self else { return }
            
            // 2) Prepare a doc ref for the comment
            let commentDocRef = db.collection("posts")
                .document(self.postID)
                .collection("comments")
                .document()  // will generate a random ID
            
            // 3) If there's an image, upload it; then create the comment doc with the fetched profile URL.
            if let uiImage = image {
                let data = uiImage.jpegData(compressionQuality: 0.8)!
                let path = "comments/\(UUID().uuidString).jpg"
                
                self.storage.reference().child(path).putData(data, metadata: nil) { _, error in
                    if let error = error {
                        print("Error uploading comment image: \(error)")
                        return
                    }
                    self.storage.reference().child(path).downloadURL { url, error in
                        if let url = url {
                            self.uploadCommentDocument(
                                docRef: commentDocRef,
                                text: text,
                                imageURL: url.absoluteString,
                                profileURL: fetchedProfileURL
                            )
                        }
                    }
                }
            } else {
                // No image, just create the comment
                self.uploadCommentDocument(
                    docRef: commentDocRef,
                    text: text,
                    imageURL: nil,
                    profileURL: fetchedProfileURL
                )
            }
        }
    }

    
    private func uploadCommentDocument(
        docRef: DocumentReference,
        text: String,
        imageURL: String?,
        profileURL: String
    ) {
        let data: [String: Any] = [
            "userID": userID,
            "username": userName,
            "profileImageURL": profileURL,
            "text": text,
            "imageURL": imageURL ?? "",
            "votes": 0,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        docRef.setData(data) { error in
            if let error = error {
                print("Error creating comment: \(error)")
            }
        }
    }

    private func fetchProfileImageURL(completion: @escaping (String) -> Void) {
        let userID = AuthManager.shared.userID
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image URL: \(error.localizedDescription)")
                completion("")
                return
            }
            let data = snapshot?.data()
            let profileURL = data?["profileImageURL"] as? String ?? ""
            completion(profileURL)
        }
    }

    // MARK: - Vote on Comment
    func voteOnComment(_ comment: Comment, vote: Int) {
        let oldVote = userCommentVotes[comment.id] ?? 0
        let newVote = (oldVote == vote) ? 0 : vote
        let delta = newVote - oldVote
        let updatedVotes = comment.votes + delta

        // Update local cache
        userCommentVotes[comment.id] = newVote

        // Update the comment votes in Firestore
        db.collection("posts")
            .document(postID)
            .collection("comments")
            .document(comment.id)
            .updateData(["votes": updatedVotes]) { error in
                if let error = error {
                    print("Error updating comment votes: \(error)")
                }
            }

        // Update the user's karma in Firestore
        db.collection("users")
            .document(comment.userID)
            .updateData(["karma": FieldValue.increment(Int64(delta))]) { error in
                if let error = error {
                    print("Error updating user karma: \(error)")
                }
            }

        // Record the user's vote in their commentVotes collection
        db.collection("users")
            .document(userID)
            .collection("commentVotes")
            .document(comment.id)
            .setData(["vote": newVote]) { error in
                if let error = error {
                    print("Error saving user comment vote: \(error)")
                }
            }
    }

    
    // MARK: - Fetch existing user comment votes
    private func fetchUserCommentVotes() {
        db.collection("users")
            .document(userID)
            .collection("commentVotes")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching userCommentVotes: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                
                var votesDict = [String: Int]()
                for doc in docs {
                    votesDict[doc.documentID] = doc.data()["vote"] as? Int ?? 0
                }
                DispatchQueue.main.async {
                    self.userCommentVotes = votesDict
                }
            }
    }
    
    
    func deleteComment(_ comment: Comment) {
            db.collection("posts")
                .document(postID)
                .collection("comments")
                .document(comment.id)
                .delete { [weak self] error in
                    if let error = error {
                        print("Error deleting comment: \(error.localizedDescription)")
                    } else {
                        print("Comment deleted successfully.")
                        // Remove comment from local array
                        DispatchQueue.main.async {
                            self?.comments.removeAll { $0.id == comment.id }
                        }
                    }
                }
        }
}


struct Comment: Identifiable, Hashable {
    let id: String
    let userID: String
    let username: String
    let profileImageURL: String
    
    let timestamp: Date
    let text: String
    let imageURL: String?
    var votes: Int
    
    // Equatable / Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

