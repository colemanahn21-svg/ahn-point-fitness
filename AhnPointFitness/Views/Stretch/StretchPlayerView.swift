import SwiftUI

/// Full-screen guided player. One stretch on screen at a time, big enough to
/// read from the floor with your head turned.
struct StretchPlayerView: View {
    let routine: StretchRoutine
    @EnvironmentObject private var session: StretchSessionState
    @Environment(\.dismiss) private var dismiss

    @State private var showCue = false

    /// Derived from the countdown so a movement drill animates start -> end
    /// every two seconds without a second timer, and holds still when paused.
    private var showEndFrame: Bool {
        guard session.current?.step.art?.isSequence == true else { return false }
        return session.remaining % 4 < 2
    }

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
                    if let art = session.current?.step.art {
                        diagramHero(art)
                    } else {
                        timerRing
                    }
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

    /// Diagram as the hero, with the countdown overlaid rather than beside it —
    /// on the floor mid-hold you want the picture big and the number readable
    /// in one glance, not two competing circles.
    private func diagramHero(_ art: StretchArtSet) -> some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    art.start
                        .resizable().scaledToFit()
                        .opacity(showEndFrame ? 0 : 1)
                    if let end = art.end {
                        end
                            .resizable().scaledToFit()
                            .opacity(showEndFrame ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 236)
                .animation(.easeInOut(duration: 0.45), value: showEndFrame)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
                .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.border, lineWidth: 1))
                .overlay(alignment: .topLeading) {
                    if art.isSequence {
                        Text(showEndFrame ? "END" : "START")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(Theme.text3)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.surface2)
                            .clipShape(Capsule())
                            .padding(12)
                    }
                }

                HStack(spacing: 8) {
                    if let side = session.current?.side, !isGetReady {
                        Text(side.rawValue.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Theme.accent)
                            .clipShape(Capsule())
                    }
                    Text(isGetReady
                         ? (session.current?.side == .right ? "SWITCH · \(session.display)" : "READY · \(session.display)")
                         : session.display)
                        .font(.system(size: isGetReady ? 20 : 40, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(countdownColor)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.15), value: session.remaining)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.background.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(isGetReady ? Theme.yellow : Theme.border, lineWidth: 1))
                .padding(12)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surface3)
                    Capsule().fill(ringColor)
                        .frame(width: geo.size.width * session.segmentProgress)
                        .animation(.linear(duration: 0.1), value: session.segmentProgress)
                }
            }
            .frame(height: 5)
        }
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
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
                .lineLimit(2)

            if let note = session.current?.step.timing.note {
                Text(note)
                    .font(Typography.chip)
                    .foregroundStyle(Theme.text3)
            }

            if let step = session.current?.step, !step.cues.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(step.cues, id: \.self) { cue in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 5, height: 5)
                                .offset(y: -1)
                            Text(cue)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.text)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        showCue.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(showCue ? "Hide why" : "Why")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .rotationEffect(.degrees(showCue ? 180 : 0))
                    }
                    .foregroundStyle(Theme.text3)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)

                if showCue {
                    ScrollView {
                        Text(step.detail)
                            .font(Typography.bodySm)
                            .foregroundStyle(Theme.text2)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 88)
                }
            } else {
                ScrollView {
                    Text(session.current?.step.detail ?? "")
                        .font(Typography.bodyMd)
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 110)
            }

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
