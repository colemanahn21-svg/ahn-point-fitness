import Foundation
import AVFoundation

/// Audio for the guided stretch player, built to keep working with the screen
/// locked.
///
/// `AudioServicesPlaySystemSound` stops firing once iOS suspends the app, so
/// the cues here are synthesized tones rendered through an `AVAudioEngine`
/// that also loops a silent buffer for the length of the session. The silence
/// is what keeps the app alive in the background (paired with the `audio`
/// UIBackgroundMode); without it the countdown would keep correct time but go
/// mute the moment the phone locks.
///
/// Tones are generated rather than shipped as files — no binary assets, and
/// the pitches stay tweakable in source.
@MainActor
final class StretchAudio {

    private let engine = AVAudioEngine()
    private let cueNode = AVAudioPlayerNode()
    private let silenceNode = AVAudioPlayerNode()

    private var format: AVAudioFormat?
    private var tickBuffer: AVAudioPCMBuffer?
    private var alarmBuffer: AVAudioPCMBuffer?
    private var completeBuffer: AVAudioPCMBuffer?
    private var silenceBuffer: AVAudioPCMBuffer?

    private var isRunning = false
    private var interruptionObserver: NSObjectProtocol?

    // MARK: - Lifecycle

    func start() {
        guard !isRunning else { return }

        // `.mixWithOthers` so a podcast or playlist keeps running underneath —
        // the cues layer on top rather than stopping his audio for 18 minutes.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return }
        format = fmt

        tickBuffer     = Self.tone(fmt, [(880, 0, 0.07)], total: 0.09)
        alarmBuffer    = Self.tone(fmt, [(1175, 0, 0.11), (1175, 0.19, 0.11), (1175, 0.38, 0.16)], total: 0.58)
        completeBuffer = Self.tone(fmt, [(784, 0, 0.14), (988, 0.15, 0.14), (1319, 0.30, 0.30)], total: 0.64)
        silenceBuffer  = Self.silence(fmt, seconds: 1)

        engine.attach(cueNode)
        engine.attach(silenceNode)
        engine.connect(cueNode, to: engine.mainMixerNode, format: fmt)
        engine.connect(silenceNode, to: engine.mainMixerNode, format: fmt)

        do {
            try engine.start()
        } catch {
            return
        }

        if let silenceBuffer {
            silenceNode.scheduleBuffer(silenceBuffer, at: nil, options: .loops)
            silenceNode.play()
        }
        cueNode.play()
        isRunning = true

        observeInterruptions()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
            self.interruptionObserver = nil
        }
        silenceNode.stop()
        cueNode.stop()
        engine.stop()
        try? AVAudioSession.sharedInstance()
            .setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - Cues

    /// Countdown tick — short and dry so 3-2-1 reads as three distinct beats.
    func tick() { play(tickBuffer) }

    /// End of a working hold.
    func alarm() { play(alarmBuffer) }

    /// End of the whole routine.
    func complete() { play(completeBuffer) }

    private func play(_ buffer: AVAudioPCMBuffer?) {
        guard isRunning, let buffer, engine.isRunning else { return }
        cueNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !cueNode.isPlaying { cueNode.play() }
    }

    /// A phone call stops the engine; restart it so the rest of the routine
    /// still has cues.
    private func observeInterruptions() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .ended
            else { return }
            MainActor.assumeIsolated {
                guard let self, self.isRunning else { return }
                try? AVAudioSession.sharedInstance().setActive(true)
                if !self.engine.isRunning { try? self.engine.start() }
                if let s = self.silenceBuffer {
                    self.silenceNode.scheduleBuffer(s, at: nil, options: .loops)
                    self.silenceNode.play()
                }
                self.cueNode.play()
            }
        }
    }

    // MARK: - Tone synthesis

    private typealias Note = (freq: Double, start: Double, duration: Double)

    /// Sums a set of notes into one buffer. Each note gets a short attack and
    /// an exponential decay — a raw square edge on a sine clicks audibly.
    private static func tone(_ format: AVAudioFormat, _ notes: [Note], total: Double) -> AVAudioPCMBuffer? {
        let rate = format.sampleRate
        let frames = AVAudioFrameCount(total * rate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let channel = buffer.floatChannelData?[0]
        else { return nil }
        buffer.frameLength = frames

        for i in 0..<Int(frames) { channel[i] = 0 }

        let attack = 0.005
        for note in notes {
            let startFrame = Int(note.start * rate)
            let noteFrames = Int(note.duration * rate)
            for n in 0..<noteFrames {
                let idx = startFrame + n
                guard idx < Int(frames) else { break }
                let t = Double(n) / rate
                let envelope = min(1, t / attack) * exp(-3.5 * t / note.duration)
                let sample = sin(2 * .pi * note.freq * t) * envelope * 0.55
                channel[idx] += Float(sample)
            }
        }
        return buffer
    }

    /// Inaudible filler that keeps the session rendering while backgrounded.
    private static func silence(_ format: AVAudioFormat, seconds: Double) -> AVAudioPCMBuffer? {
        let frames = AVAudioFrameCount(seconds * format.sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let channel = buffer.floatChannelData?[0]
        else { return nil }
        buffer.frameLength = frames
        for i in 0..<Int(frames) { channel[i] = 0 }
        return buffer
    }
}
