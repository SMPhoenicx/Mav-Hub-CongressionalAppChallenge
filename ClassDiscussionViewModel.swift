//
//  ClassDiscussionsViewModel.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/21/25.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

struct ClassMessage: Identifiable {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let timestamp: Date
    let imageUrl: String?
}

class ClassDiscussionViewModel: ObservableObject {
    @Published var userClasses: [String] = []
    @Published var selectedClass: String?
    @Published var messages: [ClassMessage] = []

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listeners: [ListenerRegistration] = []

    func syncUserClasses(from assignments: [Assignment]) {
        // Filter assignments where selfAdded is false
        let filteredAssignments = assignments.filter { !$0.selfAdded }
        
        // Parse class names from the filtered assignments
        let parsedClasses: [String] = filteredAssignments.compactMap { parseClassName(from: $0) }
        
        // Remove duplicates by reducing into a unique list
        userClasses = parsedClasses.reduce(into: [String]()) { uniqueClasses, className in
            if !uniqueClasses.contains(className) {
                uniqueClasses.append(className)
            }
        }
    }


    private func parseClassName(from assignment: Assignment) -> String? {
        if let range = assignment.summary.range(of: "- ") {
            return String(assignment.summary[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil // Explicitly return nil if parsing fails
    }

    func listenForMessages(in className: String) {
        removeListeners()
        let classRef = db.collection("classDiscussions").document(className)
        classRef.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    return ClassMessage(
                        id: doc.documentID,
                        text: data["text"] as? String ?? "",
                        userID: data["userID"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        imageUrl: data["imageUrl"] as? String
                    )
                }
            }
    }

    func sendMessage(_ text: String, image: UIImage?) {
        guard let selectedClass = selectedClass else { return }
        let classRef = db.collection("classDiscussions").document(selectedClass)

        let uploadTask: (String?) -> Void = { imageUrl in
            let data: [String: Any] = [
                "text": text,
                "userID": AuthManager.shared.userID,
                "userName": AuthManager.shared.userName,
                "timestamp": FieldValue.serverTimestamp(),
                "imageUrl": imageUrl ?? ""
            ]
            classRef.collection("messages").addDocument(data: data)
        }

        if let image = image {
            let imagePath = "classImages/\(UUID().uuidString).jpg"
            let storageRef = storage.reference().child(imagePath)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                storageRef.downloadURL { url, _ in
                    uploadTask(url?.absoluteString)
                }
            }
        } else {
            uploadTask(nil)
        }
    }

    func removeListeners() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
}
