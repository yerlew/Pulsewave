import SwiftUI

struct ChatsListView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                ThemedHeader("Chats")
                    .padding(.horizontal)
                LazyVStack(spacing: 10) {
                    ForEach(MockData.chats) { chat in
                        NavigationLink(value: chat) {
                            ChatRow(chat: chat)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .themedRootScreen("Chats")
            .themedBackground(solid: true)
            .navigationDestination(for: ChatPreview.self) { chat in
                ChatDetailView(chat: chat)
            }
        }
    }
}

struct ChatRow: View {
    let chat: ChatPreview

    var body: some View {
        let pack = ThemeStore.shared.current
        HStack(spacing: 12) {
            Image(systemName: chat.user.avatarSystemName)
                .font(.title)
                .foregroundStyle(pack.accent)
                .frame(width: 44, height: 44)
                .background(pack.accent.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.user.username).font(.themed(.headline))
                Text(chat.lastMessage)
                    .font(.themed(.subheadline))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(chat.timestamp.formatted(.relative(presentation: .named)))
                    .font(.themed(.caption2))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                Circle().fill(pack.highlight).frame(width: 8, height: 8)
                    .opacity(chat.unread ? 1 : 0)
            }
        }
        .padding(12)
        .themedCard()
        .accessibilityElement(children: .combine)
        .accessibilityHint(chat.unread ? "Unread" : "")
    }
}

extension ChatPreview: Hashable {
    static func == (lhs: ChatPreview, rhs: ChatPreview) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ChatDetailView: View {
    let chat: ChatPreview

    var body: some View {
        VStack {
            Spacer()
            Text("Chat with \(chat.user.username)")
                .font(.themed(.body))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .themedInlineTitle(chat.user.username)
        .themedBackground(solid: true)
    }
}

#Preview {
    ChatsListView()
}
