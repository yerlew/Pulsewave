import SwiftUI

struct CommunityView: View {
    private let categories = ["Recommended", "Toy", "Life", "DIY", "Latest"]
    @State private var selectedCategory = "Recommended"

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                categoryPicker
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MockData.posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Community")
            .background(Color.black.ignoresSafeArea())
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .font(selectedCategory == category ? .headline : .subheadline)
                        .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                        .onTapGesture { selectedCategory = category }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}

struct PostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.06))
                .frame(height: 160)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                )

            Text(post.caption)
                .font(.subheadline)
                .lineLimit(2)

            HStack {
                Label(post.author.username, systemImage: post.author.avatarSystemName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Label("\(post.likeCount)", systemImage: "heart")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    CommunityView().preferredColorScheme(.dark)
}
