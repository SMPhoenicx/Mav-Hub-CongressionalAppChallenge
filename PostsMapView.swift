//
//  Untitled.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/22/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct PostsMapView: View {
    @Environment(\.presentationMode) private var presentationMode // For dismissing the sheet
    @StateObject private var viewModel = FeedViewModel()
    @State private var posts: [Post] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 29.742082, longitude: -95.428875), // Replace with school location
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    var body: some View {
        let color = loadColor() ?? .orange
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, annotationItems: posts) { post in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: post.location?.latitude ?? 0,
                        longitude: post.location?.longitude ?? 0)) {
                        NavigationLink(destination: PostDetailView(viewModel: viewModel, post: post)) {
                            VStack(spacing: 4) {
                                if !post.imageURL.isEmpty { // Check if imageURL is not empty
                                    AsyncImage(url: URL(string: post.imageURL)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle()) // Circular image
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .shadow(radius: 4)
                                        default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle") // Default SF Symbol
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.red)
                                        .shadow(radius: 4)
                                }
                            }
                        }
                    }
                }

                .onAppear {
                    fetchPosts()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
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
    private func fetchPosts() {
        let twentyFourHoursAgo = Date().addingTimeInterval(-86400 * 2) // 24 hours in seconds
        let db = Firestore.firestore()
        
        db.collection("posts")
            .whereField("timestamp", isGreaterThan: Timestamp(date: twentyFourHoursAgo))
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
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
}
