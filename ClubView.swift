import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ClubView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = FeedViewModel() // single source of truth
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
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            NavigationStack {
                VStack {
                    if viewModel.posts.isEmpty {
                        Text("No posts found for Club Hub.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            ForEach(viewModel.posts) { post in
                                PostView(viewModel: viewModel, post: post)
                                    .padding(.bottom, 10)
                            }
                        }
                        .navigationDestination(for: Post.self) { post in
                            PostDetailView(viewModel: viewModel, post: post)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .onAppear {
                viewModel.fetchClubPosts()  // Use the new method in FeedViewModel
            }
        }
    }
}

