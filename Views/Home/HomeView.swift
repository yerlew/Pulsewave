import SwiftUI

struct HomeView: View {
    @State private var toy = MockData.toy

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    toyHeader
                    toyIllustration
                    connectButton
                    modeGrid
                }
                .padding()
            }
            .navigationTitle("Home")
            .background(
                LinearGradient(colors: [.black, .purple.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    private var toyHeader: some View {
        VStack(spacing: 6) {
            Text(toy.name)
                .font(.title2.bold())
            Button {
                // stub: present toy picker
            } label: {
                Label("Switch toys", systemImage: "arrow.left.arrow.right")
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var toyIllustration: some View {
        Image(systemName: toy.iconSystemName)
            .font(.system(size: 90))
            .foregroundStyle(.orange.opacity(0.9))
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
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08), in: Capsule())
        }
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
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: mode.iconSystemName)
                .font(.title2)
                .foregroundStyle(.purple)
            Text(mode.rawValue)
                .font(.headline)
            Text(mode.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(height: 110)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ModeDetailView: View {
    let mode: ControlMode

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: mode.iconSystemName)
                .font(.system(size: 50))
                .foregroundStyle(.purple)
            Text(mode.rawValue)
                .font(.title.bold())
            Text(mode.subtitle)
                .foregroundStyle(.secondary)
            Spacer()
            Text("Placeholder — wire up \(mode.rawValue) logic here.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle(mode.rawValue)
    }
}

#Preview {
    HomeView().preferredColorScheme(.dark)
}
