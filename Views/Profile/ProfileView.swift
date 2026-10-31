import SwiftUI

struct ProfileView: View {
    private let profile = MockData.profile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatar
                    identity
                    statsRow
                    levelCard
                    quickLinks
                    featuresGrid
                }
                .padding()
            }
            .navigationTitle("Me")
            .background(Color.black.ignoresSafeArea())
        }
    }

    private var avatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 90))
            .foregroundStyle(.purple)
    }

    private var identity: some View {
        VStack(spacing: 4) {
            Text(profile.username).font(.title2.bold())
            Text("ID \(profile.memberId)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem("Following", profile.following)
            Divider().frame(height: 30)
            statItem("Followers", profile.followers)
            Divider().frame(height: 30)
            statItem("Friends", profile.friends)
        }
    }

    private func statItem(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Your Level", systemImage: "bolt.fill")
                Spacer()
                Text("LV\(profile.level)").bold()
            }
            ProgressView(value: Double(profile.levelProgress), total: Double(profile.levelCap))
            Text("\(profile.levelProgress)/\(profile.levelCap)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    }

    private var quickLinks: some View {
        HStack(spacing: 12) {
            quickLinkTile("My Posts", "doc.text.fill")
            quickLinkTile("My Toys", "waveform.path.ecg")
        }
    }

    private func quickLinkTile(_ title: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(.purple)
            Text(title).font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }

    private var featuresGrid: some View {
        let items: [(String, String)] = [
            ("Likes", "heart.fill"),
            ("Collections", "bookmark.fill"),
            ("Socials", "link"),
            ("Settings", "gearshape.fill")
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 6) {
                    Image(systemName: item.1)
                    Text(item.0).font(.caption2)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ProfileView().preferredColorScheme(.dark)
}
