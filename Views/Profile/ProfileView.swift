import SwiftUI

struct ProfileView: View {
    private let profile = MockData.profile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ThemedHeader("Me")
                    avatar
                    identity
                    statsRow
                    levelCard
                    quickLinks
                    themeLink
                    featuresGrid
                }
                .padding()
            }
            .themedRootScreen("Me")
            .themedBackground()
        }
    }

    private var pack: ThemePack { ThemeStore.shared.current }

    private var avatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 90))
            .foregroundStyle(pack.accent)
    }

    private var identity: some View {
        VStack(spacing: 4) {
            Text(profile.username).font(pack.style.titleFont(22, pack: pack))
            Text("ID \(profile.memberId)")
                .font(.themed(.caption))
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
            Text("\(value)").font(.themed(.headline))
            Text(label).font(.themed(.caption)).foregroundStyle(.secondary)
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
            .font(.themed(.headline))
            .foregroundStyle(pack.headerText)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(pack.headerGradient)

            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: Double(profile.levelProgress), total: Double(profile.levelCap))
                    .tint(pack.highlight)
                Text("\(profile.levelProgress)/\(profile.levelCap)")
                    .font(.themed(.caption))
                    .foregroundStyle(.secondary)
            }
            .padding([.horizontal, .bottom])
        }
        .themedCard()
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(pack.headerCornerRadius ?? 14)))
    }

    private var quickLinks: some View {
        HStack(spacing: 12) {
            quickLinkTile("My Posts", "doc.text.fill")
            quickLinkTile("My Toys", "waveform.path.ecg")
        }
    }

    private func quickLinkTile(_ title: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(pack.accent)
            Text(title).font(.themed(.subheadline).weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .themedCard()
    }

    /// Entry to the pack picker, showing the equipped pack's colors.
    private var themeLink: some View {
        NavigationLink {
            ThemePacksView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "paintpalette.fill").foregroundStyle(pack.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme Packs").font(.themed(.subheadline).weight(.medium))
                    Text(pack.name).font(.themed(.caption)).foregroundStyle(.secondary)
                }
                Spacer()
                PackSwatches(pack: pack)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .themedCard()
        }
        .buttonStyle(.plain)
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
                    Text(item.0).font(.themed(.caption2))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .themedCard()
    }
}

/// Small overlapping dots of a pack's key colors.
struct PackSwatches: View {
    let pack: ThemePack

    var body: some View {
        HStack(spacing: -6) {
            ForEach([\ThemePack.Palette.backgroundTop, \.backgroundBottom, \.highlight, \.accent], id: \.self) { key in
                Circle()
                    .fill(pack.color(key))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .frame(width: 18, height: 18)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ProfileView()
}
