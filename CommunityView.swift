import SwiftUI
import FirebaseFirestore
import MapKit

struct CommunityView: View {
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @State private var profileImage: UIImage? = nil
    @State private var karma: Int = 0
    @State private var errorMessage: String? = nil
    @State private var isLeaderboardActive: Bool = false
    @State private var isMapActive: Bool = false
    @State private var isClubActive: Bool = false
    @State private var isNewFeatureActive: Bool = false // State for the new button's sheet
    @State private var userAssignments: [Assignment] = []
    private let db = Firestore.firestore()

    var body: some View {
        let primaryColor = loadColor() ?? Color.orange
        let backgroundColor = darkMode ? Color.black : Color.white
        let textColor = darkMode ? Color.white : Color.black

        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Profile Section
                VStack(spacing: 16) {
                    Text("\(karma) Reputation")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            textColor.opacity(0.2)
                                .cornerRadius(8)
                        )
                }

                // First Row: Leaderboard and Map Buttons
                HStack(spacing: 20) {
                    // Leaderboard Button
                    Button(action: {
                        isLeaderboardActive = true
                    }) {
                        VStack {
                            Image(systemName: "list.number")
                                .font(.largeTitle)
                                .foregroundColor(darkMode ? Color.black : Color.white)
                            Text("Leaderboard")
                                .bold()
                                .foregroundColor(darkMode ? Color.black : Color.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(primaryColor)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }

                    // Map Button
                    Button(action: {
                        isMapActive = true
                    }) {
                        VStack {
                            Image(systemName: "map")
                                .font(.largeTitle)
                                .foregroundColor(darkMode ? Color.black : Color.white)
                            Text("Map")
                                .bold()
                                .foregroundColor(darkMode ? Color.black : Color.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(primaryColor)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                }
                .padding(.horizontal)

                // Second Row: Club and New Feature Buttons
                HStack(spacing: 20) {
                    // Club Posts Button
                    Button(action: {
                        isClubActive = true
                    }) {
                        VStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(darkMode ? Color.black : Color.white)
                            Text("Club Posts")
                                .bold()
                                .foregroundColor(darkMode ? Color.black : Color.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(primaryColor)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }

                    // New Feature Button
                    Button(action: {
                        isNewFeatureActive = true
                    }) {
                        VStack {
                            Image(systemName: "message.fill")
                                .font(.largeTitle)
                                .foregroundColor(darkMode ? Color.black : Color.white)
                            Text("Class Chats")
                                .bold()
                                .foregroundColor(darkMode ? Color.black : Color.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(primaryColor)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
        }
        .sheet(isPresented: $isLeaderboardActive) {
            ReputationLeaderboardView()
        }
        .sheet(isPresented: $isMapActive) {
            PostsMapView()
        }
        .sheet(isPresented: $isClubActive) {
            ClubView() // Reference to the ClubView
        }
        .sheet(isPresented: $isNewFeatureActive) {
            ClassDiscussionsView() // Reference to the new feature view
        }
        .onAppear {
            fetchUserDetails()
        }
    }

    // Fetch user details from Firestore
    private func fetchUserDetails() {
        let userID = AuthManager.shared.userID // Replace with your user ID retrieval logic
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

                if let profileImageURL = data["profileImageURL"] as? String {
                    self.fetchProfileImage(from: profileImageURL)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "User document not found."
                }
            }
        }
    }

    // Fetch profile image
    private func fetchProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }

    // Load user-selected color
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




#Preview {
    CommunityView()
}
