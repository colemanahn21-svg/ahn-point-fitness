import XCTest
@testable import AhnPointFitness

final class ProfileExpiryReminderTests: XCTestCase {

    /// A profile is binary CMS wrapping an XML plist; the parser has to find
    /// the plist inside the envelope, not assume the file starts with it.
    func testReadsExpiryOutOfSignedEnvelope() {
        let expiry = TestSupport.etDate(2026, 9, 23, hour: 14)
        let iso = ISO8601DateFormatter().string(from: expiry)
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
          <key>Name</key><string>iOS Team Provisioning Profile: com.coleman.recomp</string>
          <key>ExpirationDate</key><date>\(iso)</date>
        </dict></plist>
        """
        var envelope = Data([0x30, 0x82, 0x1A, 0x2B, 0x06, 0x09])   // DER header noise
        envelope.append(Data(plist.utf8))
        envelope.append(Data([0x00, 0x31, 0x82, 0xFF]))               // trailing signature noise

        let parsed = ProfileExpiryReminder.expirationDate(fromProfileData: envelope)
        XCTAssertEqual(parsed?.timeIntervalSince1970 ?? 0, expiry.timeIntervalSince1970, accuracy: 1)
    }

    func testGarbageYieldsNil() {
        XCTAssertNil(ProfileExpiryReminder.expirationDate(fromProfileData: Data("not a profile".utf8)))
    }

    func testReminderIsEightPMTheEveningBefore() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        let expiry = TestSupport.etDate(2026, 9, 23, hour: 14)
        let now = TestSupport.etDate(2026, 9, 16, hour: 12)

        let fireAt = ProfileExpiryReminder.reminderDate(for: expiry, now: now, calendar: cal)
        let c = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireAt!)
        XCTAssertEqual([c.year, c.month, c.day, c.hour, c.minute], [2026, 9, 22, 20, 0])
    }

    func testNoReminderOnceTheEveningBeforeHasPassed() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        let expiry = TestSupport.etDate(2026, 9, 23, hour: 14)
        let lateOnTheEveningBefore = TestSupport.etDate(2026, 9, 22, hour: 22)
        XCTAssertNil(ProfileExpiryReminder.reminderDate(for: expiry, now: lateOnTheEveningBefore, calendar: cal))
    }
}
