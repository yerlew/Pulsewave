import SwiftUI

struct HomeView: View {
    @State private var toy = MockData.toy

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ThemedHeader("Home")
                    toyHeader
                    toyIllustration
                    connectButton
                    modeGrid
                }
                .padding()
            }
            .themedRootScreen("Home")
            .themedBackground()
        }
    }

    private var pack: ThemePack { ThemeStore.shared.current }

    private var toyHeader: some View {
        VStack(spacing: 6) {
            Text(toy.name)
                .font(pack.style.titleFont(22, pack: pack))
            Button {
                // stub: present toy picker
            } label: {
                Label("Switch toys", systemImage: "arrow.left.arrow.right")
                    .font(.themed(.subheadline))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var toyIllustration: some View {
        Image(systemName: toy.iconSystemName)
            .font(.system(size: 90))
            .foregroundStyle(pack.highlight.opacity(0.9))
            .shadow(color: pack.highlight.opacity(0.45), radius: toy.state == .connected ? 24 : 0)
            .symbolEffect(.pulse, isActive: toy.state == .pairing)
            .frame(height: 140)
    }

    private var connectButton: some View {
        Button {
            // stub: kick off CoreBluetooth scan via DeviceManager
            toy.state = toy.state == .connected ? .disconnected : .pairing
        } label: {
            HStack {
                Image(systemName: toy.state == .connected ? "checkmark.circle.fill" : "link")
                Text(connectLabel)
            }
            .font(.themed(.subheadline).weight(.medium))
            .foregroundStyle(toy.state == .connected ? pack.accent : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .themedCard(cornerRadius: 28)
        }
        .buttonStyle(.plain)
    }

    private var connectLabel: String {
        switch toy.state {
        case .connected: return "Connected"
        case .pairing: return "Connecting…"
        case .disconnected: return "Tap to connect"
        }
    }

    private var modeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(ControlMode.allCases) { mode in
                NavigationLink(value: mode) {
                    ModeTile(mode: mode)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: ControlMode.self) { mode in
            ModeDetailView(mode: mode)
        }
    }
}

struct ModeTile: View {
    let mode: ControlMode

    var body: some View {
        let pack = ThemeStore.shared.current
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: mode.iconSystemName)
                .font(.title2)
                .foregroundStyle(pack.accent)
            Text(mode.rawValue)
                .font(.themed(.headline))
            Text(mode.subtitle)
                .font(.themed(.caption))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(height: 110)
        .themedCard(cornerRadius: 16)
    }
}

struct ModeDetailView: View {
    let mode: ControlMode

    var body: some View {
        let pack = ThemeStore.shared.current
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Image(systemName: mode.iconSystemName)
                    .font(.system(size: 50))
                Text(mode.rawValue)
                    .font(pack.style.titleFont(28, pack: pack))
                Text(mode.subtitle)
                    .font(.themed(.subheadline))
                    .opacity(0.8)
            }
            .foregroundStyle(pack.headerText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(pack.headerGradient, in: RoundedRectangle(cornerRadius: CGFloat(pack.headerCornerRadius ?? 14)))
            Spacer()
            Text("Placeholder — wire up \(mode.rawValue) logic here.")
                .font(.themed(.footnote))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 40)
        }
        .padding()
        .themedInlineTitle(mode.rawValue)
        .themedBackground()
    }
}

#Preview {
    HomeView()
}
