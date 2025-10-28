import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import MapKit

struct CreatePostView: View {
    // MARK: - Dependencies
    var onPostCreated: (Post) -> Void
    
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    @State private var postText: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var profileImageURL: String = ""
    @State private var showImagePicker = false
    
    // New states for tagging & location
    @State private var selectedTag: String = "None"
    @State private var showMapPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    
    private let db = Firestore.firestore()
    
    private let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    private let grayBackground = Color.black.opacity(0.1)
    
    var body: some View {
        let color1 = loadColor() ?? .orange
        let color2: Color = darkMode ? .black : .white
        
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [color1]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // MARK: - Post Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's on your mind?")
                            .font(.headline)
                            .foregroundColor(color1.isLight() ? Color.black : Color.white)
                        
                        TextField("", text: $postText)
                            .padding()
                            .background(grayBackground)
                            .cornerRadius(8)
                            .foregroundColor(color1.isLight() ? Color.black : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color1, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Image Section
                    VStack(spacing: 8) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(color1, lineWidth: 1)
                                )
                                .padding(.horizontal)
                        } else {
                            Button {
                                showImagePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "photo")
                                }
                                .foregroundColor(color1.isLight() ? Color.black : Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(grayBackground)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                    HStack(){
                        Text("Select a Tag:")
                            .font(.headline)
                            .foregroundColor(color1.isLight() ? Color.black : Color.white)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    // MARK: - Tag Picker
                    VStack(alignment: .leading) {
                        
                        
                        Picker("Tag", selection: $selectedTag) {
                            Text("None").tag("None")
                            Text("Discussion").tag("Discussion")
                            Text("Announcement").tag("Announcement")
                            Text("Clubs").tag("Clubs")
                            Text("Sports").tag("Sports")
                            Text("Events").tag("Events")
                            Text("Academics").tag("Academics")
                            Text("Arts").tag("Arts")
                            Text("Volunteering").tag("Volunteering")
                            Text("Lost & Found").tag("Lost & Found")
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .clipped()
                        .padding(.horizontal)
                    }

                    
                    // MARK: - Location (Geotag) Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location:")
                            .font(.headline)
                            .foregroundColor(color1.isLight() ? Color.black : Color.white)
                        
                        // Show selected coordinate or a placeholder
                        if let coord = selectedCoordinate {
                            Text(String(format: "Latitude: %.4f, Longitude: %.4f",
                                        coord.latitude, coord.longitude))
                            .foregroundColor(darkMode ? .white : .black)
                        } else {
                            Text("No location selected")
                                .foregroundColor(color1.isLight() ? Color.black : Color.white)
                        }
                        
                        Button {
                            showMapPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("Select Location")
                            }
                            .foregroundColor(color1.isLight() ? Color.black : Color.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(grayBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color1, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showMapPicker) {
                        LocationPickerView { coordinate in
                            selectedCoordinate = coordinate
                            showMapPicker = false
                        }
                    }
                    
                    // MARK: - Post Button
                    Button(action: postButtonTapped) {
                        Text(isUploading ? "Posting..." : "Post")
                            .font(.headline)
                            .foregroundColor((postText.isEmpty && selectedImage == nil) ?
                                             Color.black :
                                             (color1.isLight() ? Color.black : Color.white)) // Fixed ternary operator usage
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background((postText.isEmpty && selectedImage == nil) ?
                                        Color.gray :
                                        color1) // Fixed background color logic
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Add a gray border
                                    .stroke(Color.gray, lineWidth: 1) // Define the border color and width
                            )
                    }
                    .disabled(postText.isEmpty && selectedImage == nil)
                    .padding(.horizontal)

                    
                    Spacer()
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    // MARK: - Load Color
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

// MARK: - Private Helpers
extension CreatePostView {
    
    /// User tapped the "Post" button
    private func postButtonTapped() {
        isUploading = true
        
        // 1) Grab the user's profile image URL from Firestore
        fetchProfileImageURL { fetchedProfileImageURL in
            profileImageURL = fetchedProfileImageURL
            
            // 2) If an image is chosen, upload it
            if let image = selectedImage {
                uploadImageToStorage(image) { imageURL in
                    // 3) Create the post in Firestore with the image URL
                    createPostInFirestore(text: postText, imageUrl: imageURL)
                }
            } else {
                // 3) Create the post in Firestore with no image
                createPostInFirestore(text: postText, imageUrl: nil)
            }
        }
    }
    
    /// Upload image to Firebase Storage
    private func uploadImageToStorage(_ image: UIImage,
                                      completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
            .child("images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    /// Create the post in Firestore
    private func createPostInFirestore(text: String, imageUrl: String?) {
        let userID = AuthManager.shared.userID
        let timestamp = Date()
        
        // Prepare dictionary for Firestore
        var postData: [String: Any] = [
            "userID": userID,
            "username": AuthManager.shared.userName,
            "text": text,
            "imageURL": imageUrl ?? "",
            "timestamp": timestamp,
            "profileImageURL": profileImageURL,
            "votes": 0,
            "tag": selectedTag
        ]
        
        // If location is chosen, store as GeoPoint
        if let coord = selectedCoordinate {
            postData["location"] = GeoPoint(latitude: coord.latitude,
                                            longitude: coord.longitude)
        }
        
        // Create a reference before writing so we can get its ID
        let newDocRef = db.collection("posts").document()
        newDocRef.setData(postData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error creating post: \(error.localizedDescription)")
                } else {
                    print("Post created successfully (docID: \(newDocRef.documentID)).")
                    
                    // Build local Post object
                    let postLocation = selectedCoordinate.map {
                        GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
                    }
                    
                    let post = Post(
                        id: newDocRef.documentID,
                        userID: userID,
                        username: AuthManager.shared.userName,
                        profileImageURL: profileImageURL,
                        timestamp: DateFormatter.localizedString(
                            from: timestamp,
                            dateStyle: .medium,
                            timeStyle: .short
                        ),
                        date: timestamp,
                        imageURL: imageUrl ?? "",
                        caption: text,
                        votes: 0,
                        tag: selectedTag,
                        location: postLocation
                    )
                    
                    onPostCreated(post)
                    resetStateAndDismiss()
                }
            }
        }
    }
    
    /// Fetch the user's profile image URL from Firestore
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
    
    /// Reset state and dismiss the view
    private func resetStateAndDismiss() {
        isUploading = false
        postText = ""
        selectedImage = nil
        selectedCoordinate = nil
        dismiss()
    }
}
