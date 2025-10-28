//
//  ContentView.swift
//  Buzz
//
//  Created by Jack Vu on 1/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// MARK: - Image Caching

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// MARK: - ImageLoader

class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    
    func loadImage(from urlString: String) {
        // Check the in-memory cache first
        if let cached = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cached
            return
        }
        // Otherwise download from network
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                let data = data,
                let downloaded = UIImage(data: data),
                error == nil
            else {
                return
            }
            DispatchQueue.main.async {
                ImageCache.shared.setImage(downloaded, forKey: urlString)
                self.image = downloaded
            }
        }.resume()
    }
}

// MARK: - Post Model

struct Post: Identifiable, Hashable {
    let id: String
    let userID: String         // new
    let username: String
    let profileImageURL: String
    
    let timestamp: String
    let date: Date
    let imageURL: String
    let caption: String
    var votes: Int
    
    let tag: String?           // new, optional
    let location: GeoPoint?    // new, optional

    // Hashable/Equatable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
}



// MARK: - FeedViewModel

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userVotes: [String: Int] = [:]
    
    private let db = Firestore.firestore()
    private let userID = AuthManager.shared.userID
    
    // Offsets for pagination
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 20
    
    // Cache of user votes so we don’t re-fetch them repeatedly
    private static var userVotesCache: [String: Int] = [:]
    
    // Real-time listener
    private var listener: ListenerRegistration?
    
    init() {
        // Enable offline caching
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    // MARK: - Real-Time Updates
    func listenForPostsRealTime() {
        stopListening()
        listener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for real-time updates: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                let fetched = documents.compactMap { Self.docToPost($0) }
                
                DispatchQueue.main.async {
                    self.posts = fetched
                    self.fetchUserVotesIfNeeded()
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Pagination
    func fetchPostsPaginated(completion: (() -> Void)? = nil) {
        var query = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
        
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            defer { completion?() }
            guard let self = self else { return }
            if let error = error {
                print("Error fetching posts (paginated): \(error)")
                return
            }
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                return // no more data
            }
            
            let newPosts = documents.compactMap { Self.docToPost($0) }
            
            self.lastDocument = documents.last // for next page
            
            DispatchQueue.main.async {
                self.posts.append(contentsOf: newPosts)
                self.fetchUserVotesIfNeeded()
            }
        }
    }
    
    // MARK: - Convert Doc -> Post
    private static func docToPost(_ doc: QueryDocumentSnapshot) -> Post? {
        let data = doc.data()
        let username = data["username"] as? String ?? "Unknown"
        let caption = data["text"] as? String ?? ""
        let votes = data["votes"] as? Int ?? 0
        let imageURL = data["imageURL"] as? String ?? ""
        let profileImageURL = data["profileImageURL"] as? String ?? "profilePlaceholder"
        let tag = data["tag"] as? String
        let location = data["location"] as? GeoPoint
        guard let ts = data["timestamp"] as? Timestamp else { return nil }
        let date = ts.dateValue()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStr = formatter.string(from: date)
        
        return Post(
            id: doc.documentID,
            userID: AuthManager.shared.userID,
            username: username,
            profileImageURL: profileImageURL,
            timestamp: dateStr,
            date: date,
            imageURL: imageURL,
            caption: caption,
            votes: votes,
            tag: tag,
            location: location
        )
    }
    
    // MARK: - User Votes
    private func fetchUserVotesIfNeeded() {
        if !Self.userVotesCache.isEmpty {
            self.userVotes = Self.userVotesCache
            return
        }
        
        db.collection("users")
            .document(userID)
            .collection("votes")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user votes: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                var votesDict = [String: Int]()
                for doc in documents {
                    votesDict[doc.documentID] = doc.data()["vote"] as? Int ?? 0
                }
                
                DispatchQueue.main.async {
                    self?.userVotes = votesDict
                    Self.userVotesCache = votesDict
                }
            }
    }
    
    // MARK: - Voting Logic
    func setUserVote(for post: Post, to vote: Int) {
        let oldVote = userVotes[post.id] ?? 0
        let newVote = (oldVote == vote) ? 0 : vote
        
        userVotes[post.id] = newVote
        Self.userVotesCache[post.id] = newVote
        
        let voteChange = newVote - oldVote
        let updatedVotes = post.votes + voteChange
        
        updateVotes(in: post.id, newVotes: updatedVotes)
        saveUserVote(for: post.id, vote: newVote)
        
        // Update local posts array
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].votes = updatedVotes
        }
        
        // If there's a vote change, increment karma
        if voteChange != 0 {
            incrementKarma(for: post.username, by: voteChange)
        }
    }
    
    private func updateVotes(in postID: String, newVotes: Int) {
        db.collection("posts")
            .document(postID)
            .updateData(["votes": newVotes]) { error in
                if let error = error {
                    print("Error updating votes: \(error)")
                }
            }
    }
    
    private func saveUserVote(for postID: String, vote: Int) {
        db.collection("users")
            .document(userID)
            .collection("votes")
            .document(postID)
            .setData(["vote": vote]) { error in
                if let error = error {
                    print("Error saving user vote: \(error)")
                }
            }
    }
    
    private func incrementKarma(for username: String, by amount: Int) {
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error incrementing karma: \(error)")
                    return
                }
                guard let doc = snapshot?.documents.first else { return }
                
                doc.reference.updateData([
                    "karma": FieldValue.increment(Int64(amount))
                ]) { err in
                    if let err = err {
                        print("Error updating karma: \(err)")
                    }
                }
            }
    }
}



// MARK: - ContentView

struct FeedSubView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var isLoadingMore = false
    @State private var showCreatePost = false // To track whether to show CreatePostView
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    var body: some View {
        let primaryColor = loadColor() ?? Color.purple
        let backgroundColor = darkMode ? Color.black : Color.white
        let textColor = darkMode ? Color.white : Color.black
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.posts) { post in
                            PostView(viewModel: viewModel, post: post)
                        }

                        if !isLoadingMore {
                            Button("Load More") {
                                isLoadingMore = true
                                viewModel.fetchPostsPaginated {
                                    isLoadingMore = false
                                }
                            }
                            .padding()
                        } else {
                        }
                    }
                }
                .navigationTitle("The Quad")
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(viewModel: viewModel, post: post)
                }
            }

            // Floating "Create Post" Button
            Button(action: {
                showCreatePost.toggle() // Show the CreatePostView
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(primaryColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 110)
            .sheet(isPresented: $showCreatePost) {
                // Pass the `onPostCreated` closure to CreatePostView
                CreatePostView { newPost in
                    // Insert the new post at the top of the feed
                    viewModel.posts.insert(newPost, at: 0)
                }
            }
        }
        .onAppear {
            viewModel.fetchPostsPaginated()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
    private func loadColor() -> Color? {
        guard !selectedColorData.isEmpty else { return nil }
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive user-selected color: \(error.localizedDescription)")
        }
        return nil
    }
}




struct ContentView: View {
    @State private var selectedTab: String = "Feed"
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    
    var body: some View {
        let selectedColor = loadColor() ?? .orange
        let backgroundColor = darkMode ? Color.black : Color.white
        let textColor = darkMode ? Color.white : Color.black
        
        ZStack {
            VStack {
                // Top Tab with a Capsule-like Picker Design
                Picker("", selection: $selectedTab) {
                    Text("Feed").tag("Feed")
                    Text("Community").tag("Community")
                    Text("Profile").tag("Profile")
                }
                .pickerStyle(.segmented)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(selectedColor.opacity(0.2))
                        .shadow(color: selectedColor.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                .padding(.top, 60)
                .animation(.easeInOut, value: selectedTab)
                
                // Subview based on selected tab
                ZStack {
                    switch selectedTab {
                    case "Feed":
                        FeedSubView()
                    case "Community":
                        CommunityView()
                    default: // "Profile"
                        ProfileView()
                    }
                }
                .transition(.slide) // Smooth animation when switching tabs
            }
        }
        .foregroundColor(textColor)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadColor() -> Color? {
        // Attempt to unarchive the stored color
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
extension FeedViewModel {
    func fetchClubPosts() {
        // Optionally set some local isLoading state or show a spinner in the UI
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching Club posts: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("No documents returned for clubs.")
                    DispatchQueue.main.async {
                        self.posts = [] // clear posts if nothing is found
                    }
                    return
                }
                
                let allPosts = docs.compactMap { Self.docToPost($0) }
                let clubPosts = allPosts.filter { $0.tag == "Clubs" }
                
                DispatchQueue.main.async {
                    self.posts = clubPosts
                    self.fetchUserVotesIfNeeded()  // so upvote states load
                }
            }
    }
}


