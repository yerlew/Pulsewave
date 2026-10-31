import SwiftUI

struct CommunityView: View {
    private let categories = ["Recommended", "Toy", "Life", "DIY", "Latest"]
    @State private var selectedCategory = "Recommended"
    @Namespace private var underline

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                ThemedHeader("Community")
                    .padding(.horizontal)
                categoryPicker
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MockData.posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.horizontal)
            }
            .themedRootScreen("Community")
            .themedBackground()
        }
    }

    private var categoryPicker: some View {
        let pack = ThemeStore.shared.current
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = selectedCategory == category
                    VStack(spacing: 4) {
                        Text(category)
                            .font(.themed(isSelected ? .headline : .subheadline))
                            .foregroundStyle(isSelected ? .primary : .secondary)
                        if isSelected {
                            Capsule().fill(pack.accent)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "underline", in: underline)
                        } else {
                            Capsule().fill(.clear).frame(height: 3)
                        }
                    }
                    .fixedSize()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.snappy) { selectedCategory = category }
                    }
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
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
        let pack = ThemeStore.shared.current
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(.clear)
                .frame(height: 160)
                .themedCard(cornerRadius: 12)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                )

            Text(post.caption)
                .font(.themed(.subheadline))
                .lineLimit(2)

            HStack {
                Label(post.author.username, systemImage: post.author.avatarSystemName)
                    .font(.themed(.caption))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Label("\(post.likeCount)", systemImage: "heart.fill")
                    .font(.themed(.caption))
                    .foregroundStyle(pack.accent)
            }
        }
    }
}

#Preview {
    CommunityView()
}
