import SwiftUI

struct ContentView: View {
    // Launch-argument hook (screenshots / UI tests): `-launchTab log` etc.
    @State private var selected: Tab = {
        switch UserDefaults.standard.string(forKey: "launchTab") {
        case "lifts": return .lifts
        case "log": return .log
        case "more": return .more
        default: return .today
        }
    }()
    @State private var keyboardHeight: CGFloat = 0
    @StateObject private var restTimer = RestTimerState()

    enum Tab: Hashable {
        case today, lifts, log, more
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                TopBar()
                TabView(selection: $selected) {
                    ScrollableTab { TodayView() }
                        .tabItem { Label("Today", systemImage: "clock") }
                        .tag(Tab.today)

                    ScrollableTab { LiftsView() }
                        .tabItem { Label("Lifts", systemImage: "dumbbell") }
                        .tag(Tab.lifts)

                    ScrollableTab { LogView() }
                        .tabItem { Label("Log", systemImage: "square.and.pencil") }
                        .tag(Tab.log)

                    MoreView()
                        .tabItem { Label("More", systemImage: "ellipsis.circle") }
                        .tag(Tab.more)
                }
                .tint(Theme.accent)
            }
        }
        .environmentObject(restTimer)
        .overlay(alignment: .bottomLeading) {
            if restTimer.isRunning {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 12, weight: .semibold))
                    Text(restTimer.display)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                    Button {
                        restTimer.cancel()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .padding(4)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.surface2)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.accent, lineWidth: 1))
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                .padding(.leading, 16)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 8 : 60)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: restTimer.isRunning)
        .overlay(alignment: .bottomTrailing) {
            if keyboardHeight > 0 {
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                } label: {
                    HStack(spacing: 6) {
                        Text("Done")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, keyboardHeight + 8)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.2), value: keyboardHeight > 0)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.background)
            appearance.shadowColor = UIColor(Theme.border)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

private struct ScrollableTab<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(.horizontal, Theme.pagePaddingH)
            .padding(.top, Theme.pagePaddingV)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.background)
    }
}

private struct TopBar: View {
    @AppStorage(CycleModel.storageKey) private var cycleStartRaw: Double = 0

    private var subtitle: String {
        let cycle = CycleModel(startDateRaw: cycleStartRaw)
        switch cycle.phase {
        case .unset:
            return "Set your cycle start date in Settings"
        case .upcoming(let days):
            return "\(cycle.rangeString ?? "") · Starts in \(days)d"
        case .active(let week):
            var line = "\(cycle.rangeString ?? "") · Week \(week) of \(CycleModel.weekCount)"
            if cycle.isDeloadWeek { line += " · Deload" }
            if cycle.isTaperWeek { line += " · Taper" }
            return line
        case .completed:
            return "\(cycle.rangeString ?? "") · Cycle complete"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("AHN POINT ")
                    .foregroundStyle(Theme.text)
                + Text("FITNESS")
                    .foregroundStyle(Theme.accent)
            }
            .font(Typography.pageTitle)
            .tracking(-0.3)

            Text(subtitle)
                .font(Typography.cardSubtitle)
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Theme.background.opacity(0.92)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.border).frame(height: 1)
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
