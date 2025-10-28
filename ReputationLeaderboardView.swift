import SwiftUI
import FirebaseFirestore

struct ReputationLeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntryReputation] = []
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    private let db = Firestore.firestore()

    var body: some View {
        let selectedColor = loadColor() ?? Color.orange
        let backgroundColor = darkMode ? Color.black : Color.white
        let textColor = darkMode ? Color.white : Color.black
        let overlayColor = darkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)

        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [selectedColor, backgroundColor]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Reputation Leaderboard")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(textColor)

                // Ensure exactly 5 entries by appending placeholders if needed
                ForEach(0..<5, id: \.self) { index in
                    let entry = index < leaderboard.count ? leaderboard[index] : LeaderboardEntryReputation.placeholder(at: index)

                    HStack {
                        Text("#\(index + 1)")
                            .font(.headline)
                            .foregroundColor(textColor)
                            .frame(width: 30, alignment: .center)

                        if let url = URL(string: entry.profileImageURL), !entry.profileImageURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                default:
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }

                        Text(entry.username)
                            .font(.headline)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.leading, 8)

                        Spacer()

                        Text("\(entry.karma)")
                            .font(.subheadline)
                            .foregroundColor(textColor)
                    }
                    .padding(.horizontal, 16)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            fetchLeaderboard()
        }
    }

    // Fetch leaderboard data from Firestore
    private func fetchLeaderboard() {
        db.collection("users")
            .order(by: "karma", descending: true)
            .limit(to: 5)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching leaderboard: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.leaderboard = documents.compactMap { doc in
                        let data = doc.data()
                        return LeaderboardEntryReputation(
                            username: data["username"] as? String ?? "Unknown",
                            profileImageURL: data["profileImageURL"] as? String ?? "",
                            karma: data["karma"] as? Int ?? 0
                        )
                    }
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

// Leaderboard entry model
struct LeaderboardEntryReputation: Identifiable {
    let id = UUID()
    let username: String
    let profileImageURL: String
    let karma: Int

    // Static method to generate a placeholder entry
    static func placeholder(at index: Int) -> LeaderboardEntryReputation {
        return LeaderboardEntryReputation(username: "Unknown", profileImageURL: "", karma: 0)
    }
}

struct ReputationLeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        ReputationLeaderboardView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray) // To visualize the background
    }
}
