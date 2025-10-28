import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()

    @State private var profileImage: UIImage? = nil
    @State private var karma: Int = 0
    @State private var posts: [Post] = []
    @State private var errorMessage: String? = nil
    @State private var isPresentingImagePicker = false
    @State private var isPresentingBadgesSheet = false
    @State private var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            let selectedColor = loadColor() ?? Color.orange
            let backgroundColor = darkMode ? Color.black : Color.white
            let textColor = darkMode ? Color.white : Color.black
            let overlayColor = darkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)

            VStack(spacing: 0) {
                ScrollView {
                    // Header Section
                    HStack {
                        Spacer()
                        Button(action: {
                            AuthManager.shared.logout()
                        }) {
                            Text("Log Out")
                                .font(.subheadline)
                                .foregroundColor(selectedColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(backgroundColor)
                                )
                        }
                        .padding(.trailing, 8)
                        .shadow(radius: 1)
                    }
                    .padding(.top, 8)

                    HStack {
                        VStack(alignment: .center) {
                            // Profile Image
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor, lineWidth: 4)
                                    )
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .background(Color.gray.opacity(0.3))
                                    .clipShape(Circle())
                            }

                            // Change Profile Picture Button
                            Button(action: {
                                isPresentingImagePicker = true
                            }) {
                                Text("Change Profile Picture")
                                    .font(.footnote)
                                    .foregroundColor(selectedColor)
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(selectedColor, lineWidth: 1)
                                    )
                            }
                            .padding(.top, 8)

                            //// Badges Button
                            //Button(action: {
                            //    isPresentingBadgesSheet = true
                            //}) {
                            //    Text("View Badges")
                             //       .font(.footnote)
                             //       .foregroundColor(selectedColor)
                             //       .padding(6)
                              //      .background(
                              //          RoundedRectangle(cornerRadius: 6)
                              //              .stroke(selectedColor, lineWidth: 1)
                              //      )
                           // }
                            //.sheet(isPresented: $isPresentingBadgesSheet) {
                             //   BadgesView()
                           // }
                        }
                        .padding(.top, 16)
                    }

                    // Karma and User Posts Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Posts")
                            .font(.headline)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)

                    VStack {
                        if isLoading {
                        } else if posts.isEmpty {
                            Text("No posts found.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(posts) { post in
                                    NavigationLink(destination: PostDetailView(viewModel: viewModel, post: post)) {
                                        PostViewCompact(post: post) { postToDelete in
                                            deletePost(postToDelete)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 96)
                }
                .background(backgroundColor.ignoresSafeArea())
                .onAppear {
                    fetchUserDetails()
                    fetchAllPosts()
                }
            }
            .sheet(isPresented: $isPresentingImagePicker) {
                ImagePickerProf(image: $profileImage, onUpload: uploadProfileImage)
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    // Upload profile image to Firebase Storage and update Firestore
    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let userID = AuthManager.shared.userID
        let storageRef = storage.reference().child("profile_images/\(userID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    self.errorMessage = "Failed to retrieve download URL."
                    return
                }
                
                self.db.collection("users").document(userID).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Failed to update profile image URL: \(error.localizedDescription)"
                    } else {
                        fetchProfileImage(from: downloadURL)
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch User Details
    private func fetchUserDetails() {
        let userID = AuthManager.shared.userID
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch user details: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = document?.data() {
                DispatchQueue.main.async {
                    self.karma = data["karma"] as? Int ?? 0
                }
                
                if
                    let profileImageURLString = data["profileImageURL"] as? String,
                    let profileImageURL = URL(string: profileImageURLString)
                {
                    self.fetchProfileImage(from: profileImageURL)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "User document not found."
                }
            }
        }
    }
    
    // MARK: - Fetch All Posts
    private func fetchAllPosts() {
        isLoading = true
        let userID = AuthManager.shared.userID
        db.collection("posts")
            .whereField("userID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                self.isLoading = false
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch posts: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.posts = []
                    }
                    return
                }
                
                let fetchedPosts = docs.compactMap { doc -> Post? in
                    convertDocToPost(doc)
                }
                
                DispatchQueue.main.async {
                    self.posts = fetchedPosts
                }
            }
    }
    
    // MARK: - Convert DocumentSnapshot to Post
    private func convertDocToPost(_ doc: QueryDocumentSnapshot) -> Post? {
        let data = doc.data()
        let username = data["username"] as? String ?? "Unknown"
        let caption = data["text"] as? String ?? ""
        let votes = data["votes"] as? Int ?? 0
        let imageURL = data["imageURL"] as? String ?? ""
        let profileImageURL = data["profileImageURL"] as? String ?? "profilePlaceholder"
        
        guard let ts = data["timestamp"] as? Timestamp else { return nil }
        let date = ts.dateValue()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStr = formatter.string(from: date)
        
        // NEW: read userID, tag, location
        let userID = data["userID"] as? String ?? ""
        let tag = data["tag"] as? String
        let location = data["location"] as? GeoPoint
        
        return Post(
            id: doc.documentID,
            userID: userID,             // <-- new
            username: username,
            profileImageURL: profileImageURL,
            timestamp: dateStr,
            date: date,
            imageURL: imageURL,
            caption: caption,
            votes: votes,
            tag: tag,                   // <-- new
            location: location          // <-- new
        )
    }
    
    // MARK: - Fetch Profile Image
    private func fetchProfileImage(from url: URL) {
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load profile image."
                }
            }
        }
    }
    
    private func deletePost(_ post: Post) {
        Firestore.firestore().collection("posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully.")
                posts.removeAll { $0.id == post.id }
            }
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
