import SwiftUI

struct RootTabView: View {
    @State private var selection = Tab.home

    enum Tab: Hashable { case home, community, chats, me }


    var body: some View {
        let pack = ThemeStore.shared.current

        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)

            CommunityView()
                .tabItem { Label("Community", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(Tab.community)

            ChatsListView()
                .tabItem { Label("Chats", systemImage: "message.fill") }
                .tag(Tab.chats)

            ProfileView()
                .tabItem { Label("Me", systemImage: "person.fill") }
                .tag(Tab.me)
        }
        .tint(pack.accent)
        .toolbarBackground(pack.color(\.solidBackground), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(pack.preferredColorScheme)
    }
}

#Preview {
    RootTabView()
}
