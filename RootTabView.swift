import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            CommunityView()
                .tabItem { Label("Community", systemImage: "bubble.left.and.bubble.right.fill") }

            ChatsListView()
                .tabItem { Label("Chats", systemImage: "message.fill") }

            ProfileView()
                .tabItem { Label("Me", systemImage: "person.fill") }
        }
        .tint(.purple)
    }
}

#Preview {
    RootTabView().preferredColorScheme(.dark)
}
