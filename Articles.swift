//
//  Review.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 4/17/25.
//
import SwiftUI
import SafariServices

struct ArticlesView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedArticle: Article?

    var accentColor: Color {
        loadColor() ?? .orange
    }
    private func loadColor() -> Color? {
            guard !selectedColorData.isEmpty else {
                return nil
            }
            
            do {
                if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                    return Color(uiColor)
                }
            } catch {
                print("Failed to unarchive color: \(error)")
            }
            return nil
        }
    var body: some View {
        let textColor:Color = darkMode ? .white:.black
        NavigationView {
            VStack(spacing: 0) {
                Text("Review")
                    .foregroundStyle(accentColor.isLight() == darkMode ? accentColor:textColor)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .padding(.horizontal, 10.0)
                    categoryFilterBar
                    articlesListView

            }
        }
        .fullScreenCover(item: $selectedArticle) { article in
            if let url = URL(string: article.link) {
                SafariView(url: url, isPresented: Binding(
                    get: { selectedArticle != nil },
                    set: { if !$0 { selectedArticle = nil } }
                ))
            }
        }


        .navigationBarBackButtonHidden(true)
        .toolbar {//custom back button cuz color
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack{
                        Image(systemName: "chevron.left")
                            .foregroundStyle(darkMode == accentColor.isLight() ? accentColor:textColor)
                            .font(.title3)
                        Text("Back")
                            .foregroundStyle(darkMode == accentColor.isLight() ? accentColor:textColor)
                            .font(.title3)
                    }
                }
            }
        }
        .accentColor(accentColor)
        .preferredColorScheme(darkMode ? .dark:.light)
        .task {
            await viewModel.fetchArticles()
        }
    }
    var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    accentColor: accentColor
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(["news", "sports", "culture", "opinions", "mavericks"], id: \.self) { category in
                    CategoryButton(
                        title: category.capitalized,
                        isSelected: viewModel.selectedCategory == category,
                        accentColor: accentColor
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    var articlesListView: some View {
        ScrollViewReader { proxy in
            List {
                Color.clear
                    .frame(height: 0)
                    .id("top")

                ForEach(viewModel.filteredArticles) { article in
                    Button {
                        selectedArticle = article
                    } label: {
                        ArticleRow(article: article, accentColor: accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowSeparator(.hidden)

                }
            }
            .listStyle(.plain)
            .onChange(of: viewModel.selectedCategory) { _ in
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
    }

}

// Category Button Component
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? accentColor.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isSelected ? accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .foregroundColor(isSelected ? (accentColor.isLight() == darkMode ? accentColor:.blue) : .primary)
    }
}

struct ArticleRow: View {
    let article: Article
    let accentColor: Color
    
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    var formattedDate: String {
        if let date = article.dateObject {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return article.date
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            AsyncImage(url: URL(string: article.image_url)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                        
                        ProgressView(progress: 0.8)
                            .tint(accentColor)
                    }
                    .frame(height: 200)
                    
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                        
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 200)
                    
                @unknown default:
                    EmptyView()
                }
            }
            
            // Categories
            if !article.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(article.categories, id: \.self) { category in
                            let color = CatColor(raw: category)?.color ?? accentColor

                            Text(category.capitalized)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(color.opacity(0.1))
                                )
                        }

                    }
                }
            }

            // Title
            Text(article.title)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(2)

            // Author and date
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(darkMode == accentColor.isLight() ? accentColor : .blue)
                    .font(.caption)
                
                let cleanedAuthor = article.author
                    .replacingOccurrences(of: "(?<!\\s)and(?!\\s)", with: " and ", options: .regularExpression)
                    .replacingOccurrences(of: "(Staff|Online).*", with: "", options: .regularExpression)

                Text(cleanedAuthor.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.subheadline)
                    .fontWeight(.medium)


                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(darkMode == accentColor.isLight() ? accentColor : .blue)
                    .font(.caption)
                
                Text(formattedDate)
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)

            // Description
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
        )
    }
}

enum CatColor: String, CaseIterable {
    case news, sports, culture, opinions, mavericks

    var color: Color {
        switch self {
        case .news: return .blue
        case .sports: return .green
        case .culture: return .purple
        case .opinions: return .orange
        case .mavericks: return .pink
        }
    }

    init?(raw: String) {
        self.init(rawValue: raw.lowercased())
    }
}


struct Article: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let description: String
    let link: String
    let image_url: String
    let categories: [String]

    var dateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.date(from: date)
    }
}

class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var selectedCategory: String? = nil

    var filteredArticles: [Article] {
        let filtered = selectedCategory == nil
            ? articles
            : articles.filter { $0.categories.contains(selectedCategory!) }

        return filtered.sorted {
            ($0.dateObject ?? Date.distantPast) > ($1.dateObject ?? Date.distantPast)
        }
    }

    func fetchArticles() async {
        guard let url = URL(string: "https://sjsreview-articles-json.s3.us-east-2.amazonaws.com/articles.json") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ArticlesResponse.self, from: data)
            await MainActor.run {
                self.articles = decoded.articles
            }
        } catch {
            print("Error fetching articles:", error)
        }
    }
}

struct ArticlesResponse: Decodable {
    let articles: [Article]
}

#Preview{
    TabControl()
}
