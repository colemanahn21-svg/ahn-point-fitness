import SwiftUI

/// Full-screen guided player. One stretch on screen at a time, big enough to
/// read from the floor with your head turned.
struct StretchPlayerView: View {
    let routine: StretchRoutine
    @EnvironmentObject private var session: StretchSessionState
    @Environment(\.dismiss) private var dismiss

    private var isGetReady: Bool { session.current?.kind == .getReady }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if session.isFinished {
                CompletedView(routine: routine) { dismiss() }
            } else {
                VStack(spacing: 0) {
                    header
                    Spacer(minLength: 0)
                    timerRing
                    Spacer(minLength: 0)
                    stepDetail
                    transport
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .onAppear { if !session.isActive { session.start(routine) } }
        .onDisappear { session.stop() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text2)
                        .frame(width: 34, height: 34)
                        .background(Theme.surface2)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
                VStack(spacing: 1) {
                    Text(routine.name)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Theme.text)
                    Text(timeLeftLabel)
                        .font(Typography.chip)
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
                Color.clear.frame(width: 34, height: 34)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surface3)
                    Capsule().fill(Theme.accent)
                        .frame(width: geo.size.width * session.routineProgress)
                }
            }
            .frame(height: 4)

            HStack {
                Text(session.current?.phaseLabel.uppercased() ?? "")
                    .font(Typography.sectionLabel)
                    .foregroundStyle(Theme.text3)
                    .lineLimit(1)
                Spacer()
                Text("\(session.workStepPosition.current) / \(session.workStepPosition.total)")
                    .font(Typography.chip)
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(.top, 8)
    }

    private var timeLeftLabel: String {
        let s = session.secondsLeftInRoutine
        return "\(s / 60):\(String(format: "%02d", s % 60)) left"
    }

    // MARK: - Ring

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Theme.surface3, lineWidth: 14)

            Circle()
                .trim(from: 0, to: session.segmentProgress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: session.segmentProgress)

            VStack(spacing: 6) {
                if isGetReady {
                    Text(session.current?.side == .right ? "SWITCH SIDES" : "GET READY")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(Theme.accent)
                }
                Text(session.display)
                    .font(.system(size: isGetReady ? 64 : 76, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(countdownColor)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: session.remaining)

                if let side = session.current?.side, !isGetReady {
                    Text(side.rawValue.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Theme.accent)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(width: 268, height: 268)
        .padding(.vertical, 12)
    }

    private var ringColor: Color {
        if isGetReady { return Theme.yellow }
        return session.remaining <= StretchTimeline.countdownSeconds ? Theme.red : Theme.accent
    }

    private var countdownColor: Color {
        session.remaining <= StretchTimeline.countdownSeconds && !isGetReady
            ? Theme.red : Theme.text
    }

    // MARK: - Detail

    private var stepDetail: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.current?.step.name ?? "")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
                .lineLimit(2)

            if let note = session.current?.step.timing.note {
                Text(note)
                    .font(Typography.chip)
                    .foregroundStyle(Theme.text3)
            }

            ScrollView {
                Text(session.current?.step.detail ?? "")
                    .font(Typography.bodyMd)
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 110)

            if let next = session.next, next.stepIndex != session.current?.stepIndex {
                HStack(spacing: 6) {
                    Text("NEXT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Theme.text3)
                    Text(next.step.name)
                        .font(Typography.bodySm)
                        .foregroundStyle(Theme.text2)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            }
        }
        .padding(.bottom, 18)
    }

    // MARK: - Transport

    private var transport: some View {
        HStack(spacing: 28) {
            Button { session.previous() } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .frame(width: 54, height: 54)
                    .background(Theme.surface2)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button { session.togglePause() } label: {
                Image(systemName: session.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 78, height: 78)
                    .background(Theme.accent)
                    .clipShape(Circle())
                    .shadow(color: Theme.accent.opacity(0.35), radius: 10, y: 4)
            }
            .buttonStyle(.plain)

            Button { session.skip() } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .frame(width: 54, height: 54)
                    .background(Theme.surface2)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Completion

private struct CompletedView: View {
    let routine: StretchRoutine
    let done: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(Theme.green)
            Text("Routine complete")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.text)
            Text("\(routine.name) · \(routine.durationLabel)")
                .font(Typography.body)
                .foregroundStyle(Theme.text2)

            Button(action: done) {
                Text("Done")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.horizontal, 40)
        }
        .padding(28)
    }
}
