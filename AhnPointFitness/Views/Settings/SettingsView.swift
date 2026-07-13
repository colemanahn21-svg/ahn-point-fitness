import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var whoopAuth: WhoopAuth

    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var allLogs: [WorkoutLog]

    // Export
    @State private var exportFile: ExportFile?
    @State private var isExporting = false
    @State private var exportError: String?

    // Import
    @State private var isImporterPresented = false
    @State private var pendingImport: PendingImport?
    @State private var importError: String?
    @State private var importResult: ImportResult?

    // WHOOP
    @State private var isConnectingWhoop = false
    @State private var whoopError: String?

    private var totalSets: Int {
        allLogs.reduce(0) { $0 + $1.sets.count }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                contentScroll
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(item: $exportFile) { file in
                ActivityView(url: file.url) { exportFile = nil }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false,
                onCompletion: handleImporterResult
            )
            .modifier(SettingsAlerts(
                exportError: $exportError,
                importError: $importError,
                pendingImport: $pendingImport,
                importResult: $importResult,
                onConfirmImport: commitImport
            ))
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionLabel(text: "WHOOP Connection")
                Card { whoopRows }
                SectionLabel(text: "Data")
                Card { dataRows }
            }
            .padding(.horizontal, Theme.pagePaddingH)
            .padding(.top, Theme.pagePaddingV)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var whoopRows: some View {
        if whoopAuth.isConnected {
            actionRow(
                title: connectedTitle,
                subtitle: connectedSubtitle,
                systemImage: "checkmark.circle.fill",
                action: {}
            )
            rowDivider
            actionRow(
                title: "Disconnect WHOOP",
                subtitle: "Clear tokens from Keychain. You'll need to reconnect.",
                systemImage: "link.badge.minus",
                action: disconnectWhoop
            )
        } else {
            actionRow(
                title: "Connect WHOOP",
                subtitle: whoopError ?? "Sign in with your WHOOP account to fetch recovery, sleep, strain.",
                systemImage: "link.circle",
                disabled: isConnectingWhoop,
                showSpinner: isConnectingWhoop,
                action: connectWhoopTapped
            )
        }
    }

    private var connectedTitle: String {
        if let line = WhoopProfileCache.load()?.displayLine {
            return line
        }
        return "Connected"
    }

    private var connectedSubtitle: String {
        if let snap = WhoopTodayCache.load() {
            return "Last sync \(Self.formatLastSync(snap.fetchedAt))"
        }
        return "Tokens stored in Keychain"
    }

    private static func formatLastSync(_ d: Date) -> String {
        if -d.timeIntervalSinceNow < 60 * 60 {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: d)
        }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: d, relativeTo: Date())
    }

    @ViewBuilder
    private var dataRows: some View {
        actionRow(
            title: "Export All Logs",
            subtitle: "Save backup as JSON file",
            systemImage: "square.and.arrow.up",
            disabled: isExporting || allLogs.isEmpty,
            showSpinner: isExporting,
            action: exportTapped
        )
        rowDivider
        actionRow(
            title: "Import Logs from Backup",
            subtitle: "Restore from a previously exported JSON",
            systemImage: "square.and.arrow.down",
            action: { isImporterPresented = true }
        )
        rowDivider
        actionRow(
            title: "Data Summary",
            subtitle: "\(allLogs.count) logs · \(totalSets) sets",
            systemImage: "chart.bar",
            action: {}
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") { dismiss() }
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func actionRow(
        title: String,
        subtitle: String,
        systemImage: String,
        disabled: Bool = false,
        showSpinner: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ActionRowContent(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                showSpinner: showSpinner
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1.0)
    }

    private var rowDivider: some View {
        Rectangle().fill(Theme.border).frame(height: 1)
    }

    // MARK: - Export

    private func exportTapped() {
        guard !isExporting else { return }
        isExporting = true
        let snapshot = allLogs
        Task.detached(priority: .userInitiated) {
            do {
                let data = try DataExportService.encode(snapshot)
                let url = try DataExportService.writeTempFile(data)
                await MainActor.run {
                    exportFile = ExportFile(url: url)
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = error.localizedDescription
                    isExporting = false
                }
            }
        }
    }

    // MARK: - Import

    private func handleImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let err):
            importError = err.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            parseFile(url)
        }
    }

    private func parseFile(_ url: URL) {
        Task.detached(priority: .userInitiated) {
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let payload = try DataExportService.decode(data)
                await MainActor.run {
                    pendingImport = PendingImport(payload: payload)
                }
            } catch {
                await MainActor.run {
                    importError = "Could not read this file. Make sure it's a valid AHN POINT FITNESS logs export."
                }
            }
        }
    }

    private func commitImport(_ p: PendingImport) {
        let counts = DataExportService.mergeImport(p.payload, into: ctx, existing: allLogs)
        pendingImport = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            importResult = ImportResult(imported: counts.imported, skipped: counts.skipped)
        }
    }

    // MARK: - WHOOP

    private func connectWhoopTapped() {
        guard !isConnectingWhoop else { return }
        whoopError = nil
        isConnectingWhoop = true
        Task {
            do {
                try await whoopAuth.connect()
                // Fetch + cache profile so the connected row shows email immediately.
                // Failures here are non-fatal: connection still succeeded.
                let service = WhoopService(auth: whoopAuth)
                if let profile = try? await service.getProfile() {
                    WhoopProfileCache.save(profile)
                }
            } catch let e as WhoopAuthError {
                if case .userCancelled = e {
                    // silent
                } else {
                    whoopError = e.errorDescription ?? "Connection failed"
                }
            } catch {
                whoopError = error.localizedDescription
            }
            isConnectingWhoop = false
        }
    }

    private func disconnectWhoop() {
        whoopAuth.disconnect()
        WhoopProfileCache.clear()
        WhoopTodayCache.clear()
    }
}

// MARK: - Row content (extracted to keep parent body simple)

private struct ActionRowContent: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let showSpinner: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundStyle(Theme.accent)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text2)
            }
            Spacer()
            if showSpinner {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Theme.accent)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Alerts modifier (extracted to ease type-checking)

private struct SettingsAlerts: ViewModifier {
    @Binding var exportError: String?
    @Binding var importError: String?
    @Binding var pendingImport: PendingImport?
    @Binding var importResult: ImportResult?
    let onConfirmImport: (PendingImport) -> Void

    private var showExportError: Binding<Bool> {
        Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })
    }
    private var showImportError: Binding<Bool> {
        Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })
    }
    private var showPending: Binding<Bool> {
        Binding(get: { pendingImport != nil }, set: { if !$0 { pendingImport = nil } })
    }
    private var showResult: Binding<Bool> {
        Binding(get: { importResult != nil }, set: { if !$0 { importResult = nil } })
    }

    private var pendingMessage: String {
        guard let p = pendingImport else { return "" }
        return "Import \(p.payload.totalLogs) workout logs containing \(p.payload.totalSets) sets? This will MERGE with your existing logs — duplicates (same date + exercise + setNumber) will be skipped, not overwritten."
    }

    private var resultMessage: String {
        guard let r = importResult else { return "" }
        return "Imported \(r.imported) new logs, skipped \(r.skipped) duplicates."
    }

    func body(content: Content) -> some View {
        content
            .alert("Export failed", isPresented: showExportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportError ?? "")
            }
            .alert("Could not read file", isPresented: showImportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError ?? "Make sure it's a valid AHN POINT FITNESS logs export.")
            }
            .alert("Import logs?", isPresented: showPending) {
                Button("Cancel", role: .cancel) {}
                Button("Import") {
                    if let p = pendingImport { onConfirmImport(p) }
                }
            } message: {
                Text(pendingMessage)
            }
            .alert("Import complete", isPresented: showResult) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(resultMessage)
            }
    }
}

// MARK: - Helper types

struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct PendingImport: Identifiable {
    let id = UUID()
    let payload: ExportPayload
}

struct ImportResult: Identifiable {
    let id = UUID()
    let imported: Int
    let skipped: Int
}

// MARK: - UIActivityViewController bridge

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL
    let onComplete: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in
            onComplete()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
