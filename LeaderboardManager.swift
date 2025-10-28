//
//  LeaderboardManager.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 4/21/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore

class LeaderboardManager: ObservableObject {
    static let shared = LeaderboardManager()
    
    // Leaderboard entry model
    struct LeaderboardEntry: Identifiable, Codable, Equatable {
        var id: String = UUID().uuidString
        let username: String
        let score: Int
        let date: Date
        
        static func == (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    // Published properties
    @Published private(set) var leaderboard: [LeaderboardEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil
    @Published var username: String = "Player"
    @Published private(set) var totalScore: Int = 0
    
    // Device ID for anonymous identification
    private let deviceIdKey = "WordleDeviceID"
    private let usernameKey = "WordleUsername"
    private let totalScoreKey = "WordleTotalScore"
    private var monthYearIdentifier: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    private var deviceId: String {
        if let existingId = UserDefaults.standard.string(forKey: deviceIdKey) {
            return existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: deviceIdKey)
            return newId
        }
    }
    
    private var db: Firestore {
        guard let secondaryApp = FirebaseApp.app(name: "SecondaryApp") else {
            fatalError("🔥 Secondary Firebase app is not configured correctly.")
        }
        return Firestore.firestore(app: secondaryApp)
    }

    
    private init() {
        // Configure Firebase when the singleton is initialized
        configureFirebase()
        
        // Load username and score from UserDefaults
        loadUserProfile()
        
        // Fetch leaderboard data immediately
        fetchLeaderboard()
    }
    
    // MARK: - Firebase Configuration
    
    private func configureFirebase() {
        // This assumes FirebaseApp.configure() is called in AppDelegate or main app entry point
        // If not, you'll need to add configuration code here
    }
    
    // MARK: - User Profile Management
    
    private func loadUserProfile() {
        username = UserDefaults.standard.string(forKey: usernameKey) ?? "Player"
        totalScore = UserDefaults.standard.integer(forKey: totalScoreKey)
    }
    func updateUsername(_ newName: String) {
        self.username = newName
        UserDefaults.standard.set(newName, forKey: usernameKey)

        let monthYear = getMonthYearString(from: Date())
        let entryRef = db.collection("leaderboards").document(monthYear).collection("entries").document(deviceId)

        entryRef.setData([
            "username": newName
        ], merge: true)
 { error in
            if let error = error {
                print("❌ Failed to update username in Firestore: \(error)")
            } else {
                print("✅ Username updated in Firestore to \(newName)")
            }
        }
        print("📩 Using device ID: \(deviceId)")

    }
    private func getMonthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }

    // MARK: - Leaderboard Operations
    
    func addScore(score: Int) {
        isLoading = true
        errorMessage = nil
        
        let now = Date()
        let monthYear = getMonthYearString(from: now)
        let collectionRef = db.collection("leaderboards").document(monthYear).collection("entries")
        let entryRef = collectionRef.document(deviceId)
        
        entryRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error reading leaderboard entry: \(error)")
                self.isLoading = false
                self.errorMessage = "Failed to submit score"
                return
            }

            let existingScore = snapshot?.data()?["score"] as? Int ?? 0
            print("📊 Existing score: \(existingScore), New score: \(score)")

            if score > 0 {
                let newData: [String: Any] = [
                    "username": self.username,
                    "score": score + existingScore,
                    "date": Timestamp(date: now),
                    "deviceId": self.deviceId
                ]

                entryRef.setData(newData) { err in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let err = err {
                            print("❌ Failed to write new score: \(err)")
                            self.errorMessage = "Failed to submit score"
                        } else {
                            print("✅ Score successfully updated for \(self.username)")
                            
                            // 🔐 Save locally
                            UserDefaults.standard.set(score, forKey: self.totalScoreKey)
                            self.totalScore = score

                            self.fetchLeaderboard()
                        }
                    }
                }
            } else {
                print("ℹ️ New score not higher — skipping update")
                self.isLoading = false
            }
        }
    }

    
    func fetchLeaderboard() {
        isLoading = true
        errorMessage = nil
        
        // Get entries for current month, ordered by score (descending)
        db.collection("leaderboards").document(monthYearIdentifier).collection("entries")
            .order(by: "score", descending: true)
            .limit(to: 100)
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error getting leaderboard: \(error)")
                        self.errorMessage = "Failed to load leaderboard"
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self.leaderboard = []
                        return
                    }
                    
                    self.leaderboard = documents.compactMap { document in
                        let data = document.data()
                        
                        guard let username = data["username"] as? String,
                              let score = data["score"] as? Int,
                              let timestamp = data["date"] as? Timestamp else {
                            return nil
                        }
                        
                        return LeaderboardEntry(
                            id: document.documentID,
                            username: username,
                            score: score,
                            date: timestamp.dateValue()
                        )
                    }
                    
                    print("Loaded \(self.leaderboard.count) leaderboard entries")
                }
            }
    }
    
    func currentRank(for username: String) -> Int? {
        return leaderboard.firstIndex { $0.username == username }
            .map { $0 + 1 }
    }
    
    func sortedLeaderboard() -> [LeaderboardEntry] {
        return leaderboard.sorted(by: { $0.score > $1.score })
    }
}

