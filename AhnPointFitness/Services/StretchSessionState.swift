import Foundation
import Combine
import AVFoundation
import UIKit

/// Drives a guided stretch routine: get-ready gap, working hold, audible
/// 3-2-1 countdown, alarm at zero, automatic side switches.
///
/// Like `RestTimerState`, the countdown derives from an absolute `segmentEnd`
/// rather than accumulating ticks, so a dropped frame or a brief background
/// trip never makes the session drift.
@MainActor
final class StretchSessionState: ObservableObject {

    @Published private(set) var routine: StretchRoutine?
    @Published private(set) var segments: [StretchSegment] = []
    @Published private(set) var index: Int = 0
    @Published private(set) var remaining: Int = 0
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isFinished: Bool = false

    private var segmentEnd: Date?
    private var pausedRemaining: Int = 0
    private var ticker: AnyCancellable?
    private var lastAnnounced: Int = -1
    private let audio = StretchAudio()

    // MARK: - Derived

    var isActive: Bool { routine != nil && !isFinished }
    var current: StretchSegment? { segments.indices.contains(index) ? segments[index] : nil }

    /// Segments after the current one. Guarded because SwiftUI renders the
    /// player once before `onAppear` loads a routine, when `segments` is empty
    /// and a `[1...]` slice would trap.
    private var upcoming: ArraySlice<StretchSegment> {
        let start = index + 1
        guard start < segments.count else { return [] }
        return segments[start...]
    }

    var next: StretchSegment? {
        upcoming.first { $0.kind == .work }
    }

    /// Fraction of the current segment elapsed (0 → 1), for the ring.
    var segmentProgress: Double {
        guard let seg = current, seg.seconds > 0 else { return 0 }
        return min(1, max(0, Double(seg.seconds - remaining) / Double(seg.seconds)))
    }

    /// Fraction of the whole routine elapsed, for the top bar.
    var routineProgress: Double {
        let total = segments.reduce(0) { $0 + $1.seconds }
        guard total > 0 else { return 0 }
        let done = segments.prefix(index).reduce(0) { $0 + $1.seconds }
        let inSegment = (current?.seconds ?? 0) - remaining
        return min(1, Double(done + inSegment) / Double(total))
    }

    var secondsLeftInRoutine: Int {
        remaining + upcoming.reduce(0) { $0 + $1.seconds }
    }

    /// Work segments only — "stretch 4 of 12" should not count the gaps.
    var workStepPosition: (current: Int, total: Int) {
        let total = Set(segments.filter { $0.kind == .work }.map(\.stepIndex)).count
        guard total > 0 else { return (0, 0) }
        let done = (current?.stepIndex ?? 0) + 1
        return (min(done, total), total)
    }

    var display: String {
        let m = remaining / 60
        let s = remaining % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(remaining)
    }

    // MARK: - Transport

    func start(_ routine: StretchRoutine) {
        stop()
        self.routine = routine
        self.segments = StretchTimeline.build(routine)
        self.index = 0
        self.isFinished = false
        audio.start()
        UIApplication.shared.isIdleTimerDisabled = true
        beginSegment()
    }

    func togglePause() {
        guard isActive else { return }
        if isPaused {
            isPaused = false
            segmentEnd = Date().addingTimeInterval(TimeInterval(pausedRemaining))
            startTicker()
        } else {
            isPaused = true
            pausedRemaining = remaining
            ticker?.cancel()
            ticker = nil
        }
    }

    /// Skip the current stretch and land on the next one already running.
    ///
    /// Advancing by one segment would drop you into that stretch's 5s
    /// get-ready instead — pressing skip means "move on now", so the gap is
    /// exactly what you are trying to bypass. Sides count as separate
    /// segments, so skipping the left side lands on the right.
    func skip() {
        guard isActive, let cur = current else { return }
        let next = segments.indices.dropFirst(index + 1).first { i in
            let seg = segments[i]
            return seg.kind == .work
                && !(seg.stepIndex == cur.stepIndex && seg.side == cur.side)
        }
        advance(to: next ?? segments.count, playChime: false)
    }

    /// Back to the start of the current stretch, or the previous one if we're
    /// already near the start — the behaviour a music player's back button has.
    func previous() {
        guard isActive, let seg = current else { return }
        let elapsed = seg.seconds - remaining
        if seg.kind == .work && elapsed <= 3 || seg.kind == .getReady {
            let target = segments[..<index].lastIndex { $0.stepIndex < seg.stepIndex } ?? 0
            let stepStart = segments.firstIndex { $0.stepIndex == segments[target].stepIndex } ?? 0
            advance(to: stepStart, playChime: false)
        } else {
            let stepStart = segments.firstIndex { $0.stepIndex == seg.stepIndex } ?? index
            advance(to: stepStart, playChime: false)
        }
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        routine = nil
        segments = []
        index = 0
        remaining = 0
        isPaused = false
        isFinished = false
        segmentEnd = nil
        audio.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - Engine

    private func beginSegment() {
        guard let seg = current else { return finish() }
        remaining = seg.seconds
        lastAnnounced = -1
        isPaused = false
        segmentEnd = Date().addingTimeInterval(TimeInterval(seg.seconds))
        startTicker()
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        guard let end = segmentEnd, !isPaused else { return }
        let left = Int(end.timeIntervalSinceNow.rounded(.up))

        if left <= 0 {
            let wasWork = current?.kind == .work
            advance(to: index + 1, playChime: wasWork)
            return
        }

        if left != remaining {
            remaining = left
            announce(left)
        }
    }

    /// 3-2-1 ticks only on working segments — the get-ready gap already ends
    /// with the stretch starting, so double-beeping it is noise.
    private func announce(_ left: Int) {
        guard current?.kind == .work,
              left <= StretchTimeline.countdownSeconds,
              left > 0,
              left != lastAnnounced
        else { return }
        lastAnnounced = left
        audio.tick()
        Haptics.tick()
    }

    private func advance(to newIndex: Int, playChime: Bool) {
        ticker?.cancel()
        ticker = nil

        guard newIndex < segments.count else {
            if playChime { audio.complete(); Haptics.done() }
            return finish()
        }
        if playChime { audio.alarm(); Haptics.done() }
        index = newIndex
        beginSegment()
    }

    private func finish() {
        ticker?.cancel()
        ticker = nil
        remaining = 0
        isFinished = true
        segmentEnd = nil
        audio.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }

}

// MARK: - Haptics

private enum Haptics {
    static func tick() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func done() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
