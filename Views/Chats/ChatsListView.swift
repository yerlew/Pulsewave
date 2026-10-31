import SwiftUI

struct ChatsListView: View {
    var body: some View {
        NavigationStack {
            List(MockData.chats) { chat in
                NavigationLink(value: chat) {
                    HStack(spacing: 12) {
                        Image(systemName: chat.user.avatarSystemName)
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.08), in: Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(chat.user.username).font(.headline)
                            Text(chat.lastMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        if chat.unread {
                            Circle().fill(.purple).frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
            .navigationDestination(for: ChatPreview.self) { chat in
                ChatDetailView(chat: chat)
            }
        }
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
                .foregroundStyle(.secondary)
            Spacer()
        }
        .navigationTitle(chat.user.username)
    }
}

#Preview {
    ChatsListView().preferredColorScheme(.dark)
}
