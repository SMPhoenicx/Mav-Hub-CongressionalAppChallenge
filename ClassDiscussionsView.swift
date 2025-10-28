import SwiftUI
import FirebaseFirestore
import FirebaseStorage


struct ClassSelectionHeader: View {
    let selectedClass: String?
    let classes: [String]
    let onSelect: (String) -> Void
    
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selectedClass ?? "Select a Class")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemBackground))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown menu
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(classes, id: \.self) { className in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                                onSelect(className)
                            }
                        }) {
                            HStack {
                                Text(className)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if className == selectedClass {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                className == selectedClass
                                    ? Color.blue.opacity(0.1)
                                    : Color(UIColor.systemBackground)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if className != classes.last {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        //.background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top)
    }
}

struct ClassDiscussionsView: View {
    
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @StateObject private var viewModel = ClassDiscussionViewModel()

    @AppStorage("usingSchedule", store: defaults) private var usingSchedule: Int = 0
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()

    @State private var schedules: [Schedule] = []
    @State private var curSchedule: Schedule = Schedule(
        name: "",
        assignmentsLink: "",
        aCarrier: "",
        bCarrier: "",
        cCarrier: "",
        dCarrier: "",
        eCarrier: "",
        fCarrier: "",
        gCarrier: "",
        d1Morning: "",
        d1Vinci: "",
        d2Morning: "",
        d3Vinci: "",
        d4Morning: "",
        d5Morning: "",
        d6Morning: "",
        d6Vinci: "",
        d7Morning: "",
        grade: 0,
        assignments: []
    )
    @State private var assignments: [Assignment] = []
    @State private var groupedAssignments: [String: [Assignment]] = [:]
    @State private var selectedClass: String? = nil
    @State private var newMessageText: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var isClassMenuExpanded = false

    var body: some View {
        let primaryColor = loadColor() ?? Color.blue // User-selected color or default to blue
        let backgroundColor = darkMode ? Color.black : Color.white
        let textColor = darkMode ? Color.white : Color.black

        VStack(spacing: 0) {
            // Header for class selection
            ClassSelectionHeader(
                selectedClass: selectedClass,
                classes: Array(groupedAssignments.keys).sorted(),
                onSelect: { className in
                    selectedClass = className
                    viewModel.listenForMessages(in: className)
                }
            )

            VStack {
                if let selectedClass = selectedClass {
                    ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 12) {
                                        ForEach(viewModel.messages) { msg in
                                            HStack {
                                                if msg.userID == AuthManager.shared.userID {
                                                    Spacer()
                                                    MessageBubble(message: msg, isCurrentUser: true, userColor: primaryColor)
                                                } else {
                                                    MessageBubble(message: msg, isCurrentUser: false, userColor: Color.gray.opacity(0.2))
                                                    Spacer()
                                                }
                                            }
                                            .id(msg.id) // Make sure your Message model has an id property
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .onChange(of: viewModel.messages.count) { _ in
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        if let lastMessage = viewModel.messages.last {
                                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                        }
                                    }
                                }
                                .onAppear {
                                    if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }

                    VStack {
                        // Input Field
                        HStack(spacing: 12) {
                            TextField("What's happening?", text: $newMessageText)
                                .padding(12)
                                .background(backgroundColor.opacity(0.8))
                                .foregroundColor(textColor)
                                .cornerRadius(16)

                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "photo")
                                    .font(.system(size: 18))
                                    .foregroundColor(primaryColor)
                            }
                            .buttonStyle(.plain)

                            Button(action: sendMessage) {
                                Text("Send")
                                    .bold()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(newMessageText.isEmpty && selectedImage == nil ? Color.gray.opacity(0.5) : primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                            .disabled(newMessageText.isEmpty && selectedImage == nil)
                        }

                        if let image = selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                                    .cornerRadius(12)

                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(backgroundColor.opacity(0.9))
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                                .offset(x: -10, y: 10)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("Select a class to start chatting.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear {
            loadInitialSchedules()
        }
        .onDisappear {
            viewModel.removeListeners()
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
    private func loadInitialSchedules() {
        if let decodedSchedules = try? JSONDecoder().decode([Schedule].self, from: schedulesData) {
            schedules = decodedSchedules
            if usingSchedule < schedules.count {
                curSchedule = schedules[usingSchedule]
                fetchAndGroupAssignments()
            }
        }
    }

    private func fetchAndGroupAssignments() {
        assignments = curSchedule.assignments
        groupedAssignments = Dictionary(grouping: assignments) { parseClassName(from: $0) }
    }

    private func parseClassName(from assignment: Assignment) -> String {
        if let range = assignment.summary.range(of: "- ") {
            return String(assignment.summary[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return assignment.summary.isEmpty ? "Other" : assignment.summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendMessage() {
        guard let selectedClass = selectedClass else { return }
        isUploading = true

        if let image = selectedImage {
            uploadImageToStorage(image) { imageURL in
                createMessage(text: newMessageText, imageUrl: imageURL)
            }
        } else {
            createMessage(text: newMessageText, imageUrl: nil)
        }
    }

    private func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference()
            .child("classDiscussions/\(UUID().uuidString).jpg")

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

    private func createMessage(text: String, imageUrl: String?) {
        guard let selectedClass = selectedClass else { return }

        let messageData: [String: Any] = [
            "text": text,
            "userID": AuthManager.shared.userID,
            "userName": AuthManager.shared.userName,
            "timestamp": FieldValue.serverTimestamp(),
            "imageUrl": imageUrl ?? ""
        ]

        Firestore.firestore()
            .collection("classDiscussions")
            .document(selectedClass)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                }
                isUploading = false
                newMessageText = ""
                selectedImage = nil
            }
    }
}

struct MessageBubble: View {
    let message: ClassMessage
    let isCurrentUser: Bool
    let userColor: Color

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text("\(message.userName), \(formattedTimestamp(message.timestamp))")
                .font(.caption)
                .foregroundColor(.gray)
            
            if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(maxWidth: 200, maxHeight: 200)
            }
            
            if message.text != "" {
                Text(message.text)
                    .padding()
                    .background(isCurrentUser ? userColor : Color.gray.opacity(0.2))
                    .foregroundColor(userColor.isLight() ? Color.black : Color.white)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
        .padding(isCurrentUser ? .leading : .trailing, 50)
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class ScrollViewHelper: ObservableObject {
    @Published var shouldScrollToBottom = false
}
