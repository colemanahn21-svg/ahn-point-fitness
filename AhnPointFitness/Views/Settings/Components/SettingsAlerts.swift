import SwiftUI

// MARK: - Alerts modifier (extracted to ease type-checking)

struct SettingsAlerts: ViewModifier {
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

struct PendingImport: Identifiable {
    let id = UUID()
    let payload: ExportPayload
}

struct ImportResult: Identifiable {
    let id = UUID()
    let imported: Int
    let skipped: Int
}
