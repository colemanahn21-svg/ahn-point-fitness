import SwiftUI

struct WarmupRow: View {
    let item: WarmupDef
    var body: some View {
        Text(item.name)
            .font(Typography.exerciseNameSm)
            .foregroundStyle(Theme.purple)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.rowPaddingH)
            .padding(.vertical, 10)
            .background(Theme.purpleBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.rowRadius)
                    .stroke(Theme.purpleRowStroke, lineWidth: 1)
            )
            .padding(.bottom, 5)
    }
}

struct MobilityRow: View {
    let item: MobilityDef
    var body: some View {
        Text(item.name)
            .font(Typography.exerciseNameSm)
            .foregroundStyle(Theme.green)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.rowPaddingH)
            .padding(.vertical, 10)
            .background(Theme.greenBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.rowRadius)
                    .stroke(Theme.greenRowStroke, lineWidth: 1)
            )
            .padding(.bottom, 5)
    }
}
