import SwiftUI

struct SupplementRow: View {
    let supp: SupplementDef
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Text(supp.time)
                    .font(Typography.suppTime)
                    .foregroundStyle(Theme.orange)
                    .frame(minWidth: 56, alignment: .leading)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(supp.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(supp.dose)
                        .font(Typography.bodySm)
                        .foregroundStyle(Theme.text2)
                    Text(supp.note)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .lineSpacing(2)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}
