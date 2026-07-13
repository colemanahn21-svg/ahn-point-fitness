import Foundation

extension Calendar {
    func with(timeZone: TimeZone) -> Calendar {
        var cal = self
        cal.timeZone = timeZone
        return cal
    }
}

/// Formats a weight for display: whole numbers drop the trailing ".0".
func formatWeight(_ w: Double) -> String {
    if w.truncatingRemainder(dividingBy: 1) == 0 {
        return String(Int(w))
    } else {
        return String(w)
    }
}
