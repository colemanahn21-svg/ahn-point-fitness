import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Card { rows }
                    }
                    .padding(.horizontal, Theme.pagePaddingH)
                    .padding(.top, Theme.pagePaddingV)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private var rows: some View {
        moreRow(label: "6 Week WHOOP Progression", icon: "chart.bar.xaxis", color: Theme.accent) {
            DetailScroll(title: "6 Week WHOOP Progression") { WhoopProgressionView() }
        }
        rowDivider
        moreRow(label: "Fuel", icon: "flame.fill", color: Theme.orange) {
            DetailScroll(title: "Fuel") { FuelView() }
        }
        rowDivider
        moreRow(label: "HRV & VO2max", icon: "waveform.path.ecg", color: Theme.red) {
            DetailScroll(title: "HRV & VO2max") { HRVVO2View() }
        }
        rowDivider
        moreRow(label: "Plan", icon: "chart.line.uptrend.xyaxis", color: Theme.accent) {
            DetailScroll(title: "Plan") { PlanView() }
        }
        rowDivider
        moreRow(label: "Recovery Rules", icon: "shield.lefthalf.filled", color: Theme.green) {
            DetailScroll(title: "Recovery Rules") { RecoveryRulesView() }
        }
        rowDivider
        moreRow(label: "Sauna Protocol", icon: "thermometer.sun.fill", color: Theme.yellow) {
            DetailScroll(title: "Sauna Protocol") { SaunaView() }
        }
        rowDivider
        moreRow(label: "Sleep", icon: "moon.fill", color: Theme.purple) {
            DetailScroll(title: "Sleep") { SleepView() }
        }
    }

    private var rowDivider: some View {
        Rectangle().fill(Theme.border).frame(height: 1)
    }

    @ViewBuilder
    private func moreRow<D: View>(
        label: String,
        icon: String,
        color: Color,
        @ViewBuilder destination: @escaping () -> D
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 28, alignment: .center)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.text3)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail wrapper (provides ScrollView + padding for pushed content)

struct DetailScroll<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(.horizontal, Theme.pagePaddingH)
                .padding(.top, Theme.pagePaddingV)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
