import Foundation

/// Machine-readable duration for a stretch.
///
/// The programme data was authored as free-text display chips ("45s/side",
/// "60–90s", "8 reps + 10s holds"). The guided player needs numbers, so this
/// derives them from the chips instead of duplicating the source data — the
/// day cards and the player stay in sync because they read the same strings.
struct StretchTiming: Equatable {
    /// Seconds for one working segment. On a two-sided stretch this is the
    /// time for ONE side; the player schedules the segment twice.
    let seconds: Int
    let perSide: Bool
    /// Qualifier shown under the timer, e.g. "per angle" or "8 reps + 10s holds".
    let note: String?

    var totalSeconds: Int { perSide ? seconds * 2 : seconds }

    static let fallback = StretchTiming(seconds: 45, perSide: false, note: nil)

    /// Ranges are floored to their lower bound — the shorter honest number,
    /// not the aspirational one. Rep-based work is converted at 5s/rep (6s if
    /// the chip says "slow"), which matches a controlled tempo.
    static func parse(_ chips: [String]) -> StretchTiming {
        guard !chips.isEmpty else { return .fallback }

        let joined = chips.joined(separator: " ")
        var s = joined
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "×", with: "x")
            .lowercased()

        let perSide = s.contains("/side") || s.contains("each side")
        let slow = s.contains("slow")
        var note: String?

        // Pull "10s holds" / "3s hold top" out before duration parsing so a
        // hold qualifier is never mistaken for the stretch's own duration.
        var holdSeconds = 0
        if let m = Self.match(s, #"(\d+)\s*s\s*hold"#) {
            holdSeconds = Int(m[1]) ?? 0
            s = Self.remove(s, #"(\d+)\s*s\s*hold\S*(\s*top)?"#)
        }

        // A "x2" / "x3" suffix means repeated sets of the whole hold.
        var sets = 1
        if let m = Self.match(s, #"x\s*(\d+)"#) {
            sets = max(1, Int(m[1]) ?? 1)
            s = Self.remove(s, #"x\s*(\d+)"#)
        }

        var seconds: Int

        if let m = Self.match(s, #"(\d+)\s*(?:-\s*(\d+)\s*)?min"#) {
            seconds = (Int(m[1]) ?? 1) * 60
        } else if let m = Self.match(s, #"(\d+)\s*(?:-\s*(\d+)\s*)?s\b"#) {
            seconds = Int(m[1]) ?? 45
        } else if let m = Self.match(s, #"(\d+)\s*(?:reps?|transitions?)"#) {
            let reps = Int(m[1]) ?? 8
            seconds = reps * (slow ? 6 : 5) + holdSeconds * 2
            note = joined
            holdSeconds = 0
        } else if let m = Self.match(s, #"(\d+)\s*/\s*direction"#) {
            // e.g. "5/direction/side" — both directions on each side.
            seconds = (Int(m[1]) ?? 5) * 2 * (slow ? 6 : 5)
            note = joined
        } else if let m = Self.match(s, #"(\d+)\s*/"#) {
            seconds = (Int(m[1]) ?? 8) * (slow ? 6 : 5)
            note = joined
        } else {
            return StretchTiming(seconds: 45, perSide: perSide, note: nil)
        }

        seconds = seconds * sets + holdSeconds * 2

        // "45s/angle/side" and "40s/position/side" run the hold more than once
        // per side; surface that in the note rather than silently doubling.
        if s.contains("/angle") { note = "per angle" }
        if s.contains("/position") { note = "per position" }

        return StretchTiming(seconds: max(10, seconds), perSide: perSide, note: note)
    }

    // MARK: - Regex helpers

    private static func match(_ s: String, _ pattern: String) -> [String]? {
        guard let re = try? NSRegularExpression(pattern: pattern),
              let m = re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s))
        else { return nil }
        return (0..<m.numberOfRanges).map { i in
            guard let r = Range(m.range(at: i), in: s) else { return "" }
            return String(s[r])
        }
    }

    private static func remove(_ s: String, _ pattern: String) -> String {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return s }
        return re.stringByReplacingMatches(
            in: s, range: NSRange(s.startIndex..., in: s), withTemplate: " ")
    }
}
