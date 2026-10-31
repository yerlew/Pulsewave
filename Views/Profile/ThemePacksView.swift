import SwiftUI
import UniformTypeIdentifiers

/// Me → Theme Packs: a grid of live pack previews. Tap to equip; long-press an
/// imported pack to export or delete it.
struct ThemePacksView: View {
    @State private var isImporting = false
    @State private var exportDocument: JSONDocument?
    @State private var exportFilename = ""
    @State private var errorMessage: String?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        let store = ThemeStore.shared

        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(store.allPacks) { pack in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { store.activate(pack.id) }
                    } label: {
                        PackPreviewCard(pack: pack, isActive: store.current.id == pack.id)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Export", systemImage: "square.and.arrow.up") { export(pack) }
                        if !store.isBuiltIn(pack) {
                            Button("Delete", systemImage: "trash", role: .destructive) { store.delete(pack) }
                        }
                    }
                }
            }
            .padding()

            Text("Packs share Jolly Roger's file format, so you can swap them between the apps. Long-press a pack to export it.")
                .font(.themed(.footnote))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 24)
        }
        .themedInlineTitle("Theme Packs")
        .themedBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Import Pack", systemImage: "square.and.arrow.down") { isImporting = true }
                    Button("Export \(store.current.name)", systemImage: "square.and.arrow.up") { export(store.current) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { handleImport($0) }
        .fileExporter(
            isPresented: Binding(get: { exportDocument != nil }, set: { if !$0 { exportDocument = nil } }),
            document: exportDocument,
            contentType: .json,
            defaultFilename: exportFilename
        ) { _ in }
        .alert("Theme Pack Problem", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }),
               presenting: errorMessage) { _ in
            Button("OK") { errorMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private func export(_ pack: ThemePack) {
        do {
            exportDocument = JSONDocument(data: try ThemeStore.shared.exportData(for: pack))
            exportFilename = "\(pack.name) Theme Pack"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                try ThemeStore.shared.importPack(from: Data(contentsOf: url))
            } catch is DecodingError {
                errorMessage = "That file isn't a theme pack."
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

/// A tiny mock screen drawn in the pack's own background, card, fonts and colors.
struct PackPreviewCard: View {
    let pack: ThemePack
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pack.name)
                .font(pack.style.titleFont(17, pack: pack))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(pack.highlight)
                VStack(alignment: .leading, spacing: 3) {
                    Capsule().fill(pack.accent).frame(width: 46, height: 5)
                    Capsule().fill(.secondary).frame(width: 30, height: 4)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { PackSurface(pack: pack, cornerRadius: 10) }

            HStack {
                Text(pack.author.map { "by \($0)" } ?? "Imported")
                    .font(pack.font(.caption2))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isActive ? pack.accent : .secondary)
            }
        }
        .padding(12)
        .frame(height: 150, alignment: .top)
        .background {
            ZStack {
                LinearGradient(colors: [pack.color(\.backgroundTop), pack.color(\.backgroundBottom)],
                               startPoint: .top, endPoint: .bottom)
                PackBackdrop(style: pack.style)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isActive ? pack.accent : Color.primary.opacity(0.12), lineWidth: isActive ? 2.5 : 1))
        // Each preview renders in its own pack's scheme so .primary/.secondary read correctly.
        .environment(\.colorScheme, pack.preferredColorScheme ?? .dark)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pack.name)
        .accessibilityAddTraits(isActive ? [.isButton, .isSelected] : .isButton)
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    NavigationStack { ThemePacksView() }
}
