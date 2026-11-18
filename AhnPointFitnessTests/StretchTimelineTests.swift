import XCTest
@testable import AhnPointFitness

final class StretchTimingTests: XCTestCase {

    func testPlainSecondsAndPerSide() {
        XCTAssertEqual(StretchTiming.parse(["45s"]).seconds, 45)
        XCTAssertFalse(StretchTiming.parse(["45s"]).perSide)

        let side = StretchTiming.parse(["45s/side"])
        XCTAssertEqual(side.seconds, 45)
        XCTAssertTrue(side.perSide)
        XCTAssertEqual(side.totalSeconds, 90)
    }

    func testRangeTakesLowerBound() {
        // "60–90s" should schedule the honest 60, not the aspirational 90.
        XCTAssertEqual(StretchTiming.parse(["60–90s"]).seconds, 60)
        XCTAssertEqual(StretchTiming.parse(["3–5 min"]).seconds, 180)
    }

    func testMinutesAndSetMultiplier() {
        XCTAssertEqual(StretchTiming.parse(["2 min"]).seconds, 120)
        XCTAssertEqual(StretchTiming.parse(["45s × 2"]).seconds, 90)
        XCTAssertEqual(StretchTiming.parse(["45s × 3"]).seconds, 135)
    }

    func testRepsConvertToTime() {
        // 10 reps at a slow tempo -> 6s each.
        XCTAssertEqual(StretchTiming.parse(["10 reps slow"]).seconds, 60)
        XCTAssertEqual(StretchTiming.parse(["8 reps each letter"]).seconds, 40)
    }

    func testHoldQualifierIsNotMistakenForDuration() {
        // "2s hold top" describes the rep, it is not the stretch's duration.
        let t = StretchTiming.parse(["10 reps slow", "2s hold top"])
        XCTAssertGreaterThan(t.seconds, 30, "hold qualifier swallowed the duration")
    }

    func testUnparseableFallsBackToUsableDefault() {
        XCTAssertEqual(StretchTiming.parse(["slow"]).seconds, 45)
        XCTAssertEqual(StretchTiming.parse([]).seconds, 45)
    }

    /// Regression guard for the 59 stretches authored as free text: every one
    /// of them must resolve to a duration a human would actually hold.
    func testEveryStretchInEveryRoutineHasSaneDuration() {
        for routine in StretchLibrary.all {
            for step in routine.steps {
                XCTAssertGreaterThanOrEqual(
                    step.timing.seconds, 15,
                    "\(routine.id)/\(step.name) is too short (\(step.chips))")
                XCTAssertLessThanOrEqual(
                    step.timing.seconds, 300,
                    "\(routine.id)/\(step.name) is too long (\(step.chips))")
            }
        }
    }
}

final class StretchTimelineTests: XCTestCase {

    private func routine(_ chips: [[String]]) -> StretchRoutine {
        StretchRoutine(
            id: "test", name: "Test", subtitle: "", focus: .golf,
            phases: [StretchPhase(id: "p", label: "P", steps: chips.enumerated().map {
                StretchStep(id: "s\($0.offset)", name: "S\($0.offset)",
                            detail: "", chips: $0.element)
            })])
    }

    func testEveryWorkSegmentIsPrecededByGetReady() {
        let segments = StretchTimeline.build(routine([["30s"], ["40s/side"]]))
        for (i, seg) in segments.enumerated() where seg.kind == .work {
            XCTAssertGreaterThan(i, 0)
            XCTAssertEqual(segments[i - 1].kind, .getReady)
            let expected = seg.side == .right
                ? StretchTimeline.sideSwitchSeconds : StretchTimeline.getReadySeconds
            XCTAssertEqual(segments[i - 1].seconds, expected)
        }
    }

    func testPerSideStepExpandsToLeftThenRight() {
        let segments = StretchTimeline.build(routine([["40s/side"]]))
        let work = segments.filter { $0.kind == .work }
        XCTAssertEqual(work.count, 2)
        XCTAssertEqual(work[0].side, .left)
        XCTAssertEqual(work[1].side, .right)
        XCTAssertEqual(work[0].seconds, 40)
        XCTAssertEqual(work[1].seconds, 40)
    }

    func testSingleSideStepHasNoSide() {
        let work = StretchTimeline.build(routine([["30s"]])).filter { $0.kind == .work }
        XCTAssertEqual(work.count, 1)
        XCTAssertNil(work[0].side)
    }

    func testTotalIncludesGetReadyGaps() {
        // 30s + (40s x 2 sides) = 110s work, plus two set-up gaps and one
        // shorter side-switch gap.
        let r = routine([["30s"], ["40s/side"]])
        XCTAssertEqual(r.totalSeconds,
                       110 + 2 * StretchTimeline.getReadySeconds + StretchTimeline.sideSwitchSeconds)
    }

    func testStepIndexIsSharedAcrossBothSides() {
        let segments = StretchTimeline.build(routine([["40s/side"], ["30s"]]))
        let sides = segments.filter { $0.side != nil }
        XCTAssertEqual(Set(sides.map(\.stepIndex)).count, 1,
                       "left and right must belong to the same step")
    }

    func testGolfFlowOpensTheSpineBeforeRotating() {
        // The programme's central claim: you cannot rotate a flexed spine, so
        // the opening phase must always run before the rotation phase.
        let phases = StretchLibrary.Golf.rotationFlow.phases
        let openIdx = phases.firstIndex { $0.label.contains("Open") }
        let rotateIdx = phases.firstIndex { $0.label.contains("Rotate") }
        XCTAssertNotNil(openIdx)
        XCTAssertNotNil(rotateIdx)
        XCTAssertLessThan(openIdx!, rotateIdx!)
    }

    /// A "45s/angle/side" chip means four working holds but the player can
    /// only schedule two, so the routine silently under-times and the card
    /// shows the wrong duration. Multi-position stretches must be authored as
    /// separate steps instead.
    func testNoStretchHidesExtraPositionsInsideOneHold() {
        for routine in StretchLibrary.all {
            for step in routine.steps {
                let chips = step.chips.joined(separator: " ").lowercased()
                XCTAssertFalse(chips.contains("/angle"),
                    "\(routine.id)/\(step.name): split the angles into separate steps")
                XCTAssertFalse(chips.contains("/position"),
                    "\(routine.id)/\(step.name): split the positions into separate steps")
            }
        }
    }

    /// Art is resolved by slugging the stretch name, so a rename silently
    /// drops the diagram back to text. This fails loudly instead.
    func testEveryStretchHasADiagram() {
        var missing: [String] = []
        for routine in StretchLibrary.all {
            for step in routine.steps where step.art == nil {
                missing.append("\(step.name) -> \(StretchArt.assetName(for: step.name))")
            }
        }
        XCTAssertTrue(missing.isEmpty,
            "no diagram for:\n" + missing.joined(separator: "\n"))
    }

    func testEveryStretchHasSkimmableCues() {
        var missing: [String] = []
        for routine in StretchLibrary.all {
            for step in routine.steps {
                if step.cues.isEmpty { missing.append(step.name) }
                for cue in step.cues {
                    XCTAssertLessThanOrEqual(cue.count, 60,
                        "cue too long to skim: \(step.name) — \(cue)")
                }
            }
        }
        XCTAssertTrue(missing.isEmpty, "no cues for: " + missing.joined(separator: ", "))
    }

    @MainActor
    func testSkipNeverLandsOnAGetReadyGap() {
        let session = StretchSessionState()
        session.start(StretchLibrary.Golf.rotationFlow)
        // From the opening get-ready, every press should land on a hold.
        for _ in 0..<12 {
            session.skip()
            guard session.isActive else { break }
            XCTAssertEqual(session.current?.kind, .work,
                           "skip parked on a get-ready gap")
        }
        session.stop()
    }

    @MainActor
    func testSkipMovesOnRatherThanStartingWhatItSkipped() {
        let session = StretchSessionState()
        session.start(StretchLibrary.routine(for: .mon))   // opens on a per-side stretch

        // Opening get-ready is for the left side; skipping it should skip that
        // side outright, not drop into it.
        session.skip()
        XCTAssertEqual(session.current?.kind, .work)
        XCTAssertEqual(session.current?.side, .right)
        XCTAssertEqual(session.current?.stepIndex, 0)

        // From the last side of a stretch, skip moves to the next movement —
        // again landing on the hold, not its get-ready.
        session.skip()
        XCTAssertEqual(session.current?.kind, .work)
        XCTAssertEqual(session.current?.stepIndex, 1)
        XCTAssertEqual(session.current?.side, .left)
        session.stop()
    }

    func testFlowShortensTheSideSwitchGapButIntervalsDoNot() {
        let flow = StretchTimeline.build(routine([["40s/side"]]))
        let switchGap = flow.first { $0.kind == .getReady && $0.side == .right }
        XCTAssertEqual(switchGap?.seconds, StretchTimeline.sideSwitchSeconds)
        XCTAssertEqual(flow.first { $0.kind == .getReady && $0.side == .left }?.seconds,
                       StretchTimeline.getReadySeconds)

        var interval = routine([["40s/side"]]); interval.cadence = .interval
        let gap = StretchTimeline.build(interval).first { $0.kind == .getReady && $0.side == .right }
        XCTAssertEqual(gap?.seconds, StretchTimeline.getReadySeconds)
    }

    func testBreathCountSurfacesAsTheNote() {
        let t = StretchTiming.parse(["75s/side", "≈ 8 breaths/side"])
        XCTAssertEqual(t.seconds, 75)
        XCTAssertTrue(t.perSide)
        XCTAssertEqual(t.note, "≈ 8 breaths/side")
    }

    // MARK: - One routine a day

    func testEveryDayHasExactlyOneEveningRoutineFromTheLibrary() {
        for day in ProgrammeDay.allCases {
            let r = StretchSchedule.evening(for: day)
            XCTAssertNotNil(StretchLibrary.routine(id: r.id), "\(day.short): \(r.name) not in the library")
        }
    }

    /// Doing everything the old programme prescribed came to about an hour a
    /// day. The ceiling is now one home flow plus the desk reset, ~22 min, and
    /// the desk part is done at lunch, not stacked on the evening.
    func testNoDayAsksForMoreThanTwentyTwoMinutes() {
        for day in ProgrammeDay.allCases {
            let total = StretchSchedule.evening(for: day).totalSeconds
                + (StretchSchedule.desk(for: day)?.totalSeconds ?? 0)
            XCTAssertLessThanOrEqual(total, 22 * 60, "\(day.short) asks for \(total / 60) min")
        }
    }

    func testDeskResetOnWeekdaysOnly() {
        for day in ProgrammeDay.allCases {
            let weekend = day == .sat || day == .sun
            XCTAssertEqual(StretchSchedule.desk(for: day) == nil, weekend, day.short)
        }
    }

    /// Thoracic turn is the limiter. The golf flow runs twice; the desk reset
    /// (extension + seated turn) and Upper Body Flow carry it on other days.
    func testThoracicWorkEveryWeekdayAndGolfFlowTwice() {
        XCTAssertGreaterThanOrEqual(
            StretchSchedule.days(for: StretchLibrary.Golf.rotationFlow).count, 2)
        for day in ProgrammeDay.allCases where day != .sat {
            let steps = StretchSchedule.evening(for: day).steps
                + (StretchSchedule.desk(for: day)?.steps ?? [])
            XCTAssertTrue(steps.contains { $0.name.contains("Thoracic") || $0.name.contains("Thread")
                                           || $0.name.contains("Peanut") },
                          "\(day.short) has no thoracic work")
        }
    }

    /// Lower-body work is not optional: a full flow on both lower-body
    /// training days, and hamstrings every workday from the chair.
    func testLowerBodyFlowOnLegsAndConditioningDays() {
        XCTAssertEqual(StretchSchedule.days(for: StretchLibrary.lowerBody), [.tue, .sat])
        let names = StretchLibrary.lowerBody.steps.map(\.name).joined(separator: " ")
        for muscle in ["Hamstring", "Calf", "Couch", "Adductor", "Pigeon"] {
            XCTAssertTrue(names.contains(muscle), "Lower Body Flow lost \(muscle)")
        }
    }

    func testHamstringsEveryWorkday() {
        XCTAssertTrue(StretchLibrary.Work.deskReset.steps.contains { $0.name.contains("Hamstring") })
    }

    func testFewRoutinesSoEachBecomesFamiliar() {
        let distinct = Set(ProgrammeDay.allCases.map { StretchSchedule.evening(for: $0).id })
        XCTAssertLessThanOrEqual(distinct.count, 3)
    }

    func testEveryDayCardPointsAtItsRoutine() {
        for day in Programme.allDays {
            let links = day.sections.filter { if case .stretchLink = $0 { return true }; return false }
            XCTAssertEqual(links.count, 1, "\(day.day.short) should show exactly one stretch link")
        }
    }

    func testTodayUsesEasternTime() {
        // 2026-11-17 03:30 UTC is still Monday evening in New York.
        let date = ISO8601DateFormatter().date(from: "2026-11-17T03:30:00Z")!
        XCTAssertEqual(StretchSchedule.today(date), .mon)
    }

    /// The desk routine only works if it is short enough to repeat during a
    /// workday and never asks you onto an office floor.
    func testDeskResetIsShortAndOfficeSafe() {
        let desk = StretchLibrary.Work.deskReset
        XCTAssertLessThanOrEqual(desk.totalSeconds, 8 * 60, "too long for a lunch break")
        for step in desk.steps {
            let text = (step.name + " " + step.detail).lowercased()
            XCTAssertFalse(text.contains("floor") || text.contains("all fours")
                           || text.contains("kneel"), "\(step.name) is not office-safe")
        }
    }

    /// Both work flows reverse a flexed spine before asking it to turn, and
    /// stay under the ~14 min ceiling every flow is held to.
    func testWorkFlowsExtendBeforeRotatingAndStayShort() {
        let desk = StretchLibrary.Work.deskReset.steps.map(\.name)
        let ext = desk.firstIndex { $0.contains("Extension") }
        let turn = desk.firstIndex { $0.contains("Turn") }
        XCTAssertNotNil(ext); XCTAssertNotNil(turn)
        XCTAssertLessThan(ext!, turn!)
        for routine in StretchLibrary.workRoutines {
            XCTAssertLessThanOrEqual(routine.totalSeconds, 14 * 60, routine.name)
            XCTAssertEqual(routine.cadence, .flow, routine.name)
        }
    }
}
