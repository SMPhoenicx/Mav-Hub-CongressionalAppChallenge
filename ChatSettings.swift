import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct ChatSettingsView: View {
    @AppStorage("username") var username: String = "Anonymous"
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var profileImage: UIImage? = nil
    @State private var isShowingImagePickerProfile = false
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    
    private let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    private let grayBackground = Color.black.opacity(0.1)
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [scarlet, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Profile Picture Section
                VStack(spacing: 12) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(scarlet, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .overlay(
                                Circle()
                                    .stroke(scarlet, lineWidth: 2)
                            )
                    }
                    
                    Button("Change Photo") {
                        isShowingImagePickerProfile = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(grayBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(scarlet, lineWidth: 1)
                    )
                }
                
                // Username Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(grayBackground)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(scarlet, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    authManager.isAuthenticated = false
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding()
            .sheet(isPresented: $isShowingImagePickerProfile) {
                ImagePickerProfile(selectedImage: $profileImage, onImageSelected: { image in
                    uploadProfileImage(image)
                })
            }
            .alert("Error", isPresented: Binding(get: { uploadError != nil }, set: { _ in uploadError = nil })) {
                Text(uploadError ?? "An unknown error occurred.")
            }
        }
        .onAppear {
            fetchProfileImage()
            ensureUserDocumentExists()
        }
    }
    
    // Fetch profile image URL from Firestore and load it
    func fetchProfileImage() {
        let userID = authManager.userID
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image: \(error)")
                return
            }
            
            if let data = snapshot?.data(), let urlString = data["profileImageURL"] as? String, let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                }
            }
        }
    }
    
    // Upload the profile image to Firebase Storage and save the URL to Firestore
    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        let userID = authManager.userID
        isUploading = true
        
        let storageRef = storage.reference().child("profile_images/\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isUploading = false
                    self.uploadError = "Failed to upload image: \(error.localizedDescription)"
                }
                return
            }
            
            storageRef.downloadURL { url, error in
                DispatchQueue.main.async {
                    self.isUploading = false
                }
                if let error = error {
                    DispatchQueue.main.async {
                        self.uploadError = "Failed to retrieve image URL: \(error.localizedDescription)"
                    }
                    return
                }
                
                if let url = url {
                    saveProfileImageURL(url.absoluteString)
                }
            }
        }
    }
    
    // Save the profile image URL to Firestore
    private func saveProfileImageURL(_ url: String) {
        let userID = authManager.userID
        db.collection("users").document(userID).updateData(["profileImageURL": url]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.uploadError = "Failed to save image URL: \(error.localizedDescription)"
                }
            } else {
                print("Profile image URL updated successfully!")
            }
        }
    }
    
    // Ensure the user's document exists in Firestore
    private func ensureUserDocumentExists() {
        let userID = authManager.userID
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error checking user document: \(error.localizedDescription)")
                return
            }
            
            if !(document?.exists ?? false) {
                userRef.setData([
                    "username": username,
                    "profileImageURL": "",
                    "karma": 0,
                    "userID": AuthManager.shared.userID,
                    "numPosts": 0
                ]) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                    } else {
                        print("User document created successfully.")
                    }
                }
            }
        }
    }
}

struct ImagePickerProfile: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onImageSelected: onImageSelected)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerProfile
        let onImageSelected: (UIImage) -> Void

        init(_ parent: ImagePickerProfile, onImageSelected: @escaping (UIImage) -> Void) {
            self.parent = parent
            self.onImageSelected = onImageSelected
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.parent.selectedImage = image
                        self.onImageSelected(image)
                    }
                }
            }
        }
    }
}
