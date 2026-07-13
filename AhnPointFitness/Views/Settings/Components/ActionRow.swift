import SwiftUI

// MARK: - Row content (extracted to keep SettingsView body simple)

struct ActionRowContent: View {
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
