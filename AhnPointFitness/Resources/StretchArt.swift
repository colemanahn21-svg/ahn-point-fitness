import SwiftUI

/// Resolves a stretch's diagram from its name.
///
/// Asset names are derived, not registered — dropping `stretch-bretzel` into
/// the asset catalogue is the only step needed to give the Bretzel a diagram.
/// No lookup table to keep in sync, and stretches sharing a name across days
/// (Prayer Lat appears on four) share one image automatically.
///
/// Movement drills need two frames, because the movement *is* the exercise: a
/// single still cannot show a 90/90 switch. Add a second asset with an `-end`
/// suffix and the player alternates between them.
///
///     stretch-90-90-hip-switches       <- start position
///     stretch-90-90-hip-switches-end   <- end position (optional)
///
/// Anything without art falls back to its text cue, so a partial set works.
struct StretchArtSet {
    let start: Image
    let end: Image?

    /// Two frames means a movement to animate rather than a shape to match.
    var isSequence: Bool { end != nil }
}

enum StretchArt {

    static func assetName(for stretchName: String) -> String {
        "stretch-" + slug(stretchName)
    }

    static func endAssetName(for stretchName: String) -> String {
        assetName(for: stretchName) + "-end"
    }

    static func artSet(for stretchName: String) -> StretchArtSet? {
        let base = assetName(for: stretchName)
        guard UIImage(named: base) != nil else { return nil }
        let endName = endAssetName(for: stretchName)
        let end = UIImage(named: endName) != nil ? Image(endName) : nil
        return StretchArtSet(start: Image(base), end: end)
    }

    /// "Doorway Pec Stretch · 90° Elbow" -> "doorway-pec-stretch-90-elbow"
    /// "90/90 PAIL/RAIL"                 -> "90-90-pail-rail"
    static func slug(_ name: String) -> String {
        var out = ""
        var pendingSeparator = false
        for ch in name.lowercased() {
            if ch.isLetter || ch.isNumber {
                if pendingSeparator && !out.isEmpty { out.append("-") }
                pendingSeparator = false
                out.append(ch)
            } else {
                pendingSeparator = true
            }
        }
        return out
    }
}
