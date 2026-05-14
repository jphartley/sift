import Foundation
import Testing
@testable import sift

struct HistoryGroupingTests {

    // MARK: - Helpers

    private func makeCalendar(firstWeekday: Int = 1, timeZone: TimeZone = TimeZone(identifier: "UTC")!) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = firstWeekday
        calendar.timeZone = timeZone
        return calendar
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, calendar: Calendar) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day; c.hour = hour
        return calendar.date(from: c)!
    }

    private func session(at date: Date) -> Session {
        Session(timestamp: date, transcript: "test")
    }

    // MARK: - Empty input

    @Test func emptySessionsReturnsNoGroups() {
        #expect(HistoryGrouping.group(sessions: [], now: Date(), calendar: .current).isEmpty)
    }

    // MARK: - Basic bucketing

    @Test func recentSessionIsThisWeek() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)         // Wednesday Jan 10
        let s   = session(at: makeDate(2024, 1, 9, cal: cal))  // Tuesday Jan 9

        let groups = HistoryGrouping.group(sessions: [s], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "This week")
    }

    @Test func sessionFromPreviousWeekIsLastWeek() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let s   = session(at: makeDate(2024, 1, 3, cal: cal))  // Previous Wednesday

        let groups = HistoryGrouping.group(sessions: [s], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "Last week")
    }

    @Test func oldSessionIsEarlier() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let s   = session(at: makeDate(2023, 12, 20, cal: cal))

        let groups = HistoryGrouping.group(sessions: [s], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "Earlier")
    }

    @Test func sessionsSpanAllThreeBuckets() {
        let cal = makeCalendar()                               // Sunday-start, UTC
        let now = makeDate(2024, 1, 10, cal: cal)             // Wed Jan 10
        // US Sunday-start: thisWeek >= Jan 7, lastWeek >= Dec 31
        let s1 = session(at: makeDate(2024, 1, 9, cal: cal))  // This week
        let s2 = session(at: makeDate(2024, 1, 3, cal: cal))  // Last week
        let s3 = session(at: makeDate(2023, 12, 20, cal: cal))// Earlier

        let groups = HistoryGrouping.group(sessions: [s1, s2, s3], now: now, calendar: cal)

        #expect(groups.map(\.label) == ["This week", "Last week", "Earlier"])
    }

    // MARK: - Week boundaries

    @Test func sessionExactlyAtWeekStartIsThisWeek() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let weekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start

        let groups = HistoryGrouping.group(sessions: [session(at: weekStart)], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "This week")
    }

    @Test func sessionOneSecondBeforeWeekStartIsLastWeek() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let weekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start

        let groups = HistoryGrouping.group(
            sessions: [session(at: weekStart.addingTimeInterval(-1))],
            now: now, calendar: cal
        )

        #expect(groups.count == 1)
        #expect(groups[0].label == "Last week")
    }

    @Test func sessionExactlyAtLastWeekStartIsLastWeek() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start
        let lastWeekStart = cal.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!

        let groups = HistoryGrouping.group(
            sessions: [session(at: lastWeekStart)],
            now: now, calendar: cal
        )

        #expect(groups.count == 1)
        #expect(groups[0].label == "Last week")
    }

    @Test func sessionOneSecondBeforeLastWeekStartIsEarlier() {
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 10, cal: cal)
        let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start
        let lastWeekStart = cal.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!

        let groups = HistoryGrouping.group(
            sessions: [session(at: lastWeekStart.addingTimeInterval(-1))],
            now: now, calendar: cal
        )

        #expect(groups.count == 1)
        #expect(groups[0].label == "Earlier")
    }

    // MARK: - Year boundary

    @Test func sessionsAcrossYearBoundaryGroupCorrectly() {
        // now = Wednesday Jan 3, 2024 (Sunday-start, UTC)
        // startOfThisWeek = Sunday Dec 31, 2023  ← crosses year boundary
        // startOfLastWeek = Sunday Dec 24, 2023
        let cal = makeCalendar()
        let now = makeDate(2024, 1, 3, cal: cal)

        let inNewYear    = session(at: makeDate(2024, 1, 2,  cal: cal))  // This week (2024)
        let crossYear    = session(at: makeDate(2023, 12, 31, cal: cal)) // This week (2023)
        let lastWeek     = session(at: makeDate(2023, 12, 26, cal: cal)) // Last week
        let earlier      = session(at: makeDate(2023, 12, 23, cal: cal)) // Earlier

        let groups = HistoryGrouping.group(
            sessions: [inNewYear, crossYear, lastWeek, earlier],
            now: now, calendar: cal
        )

        #expect(groups.first { $0.label == "This week" }?.sessions.count == 2)
        #expect(groups.first { $0.label == "Last week" }?.sessions.count == 1)
        #expect(groups.first { $0.label == "Earlier"   }?.sessions.count == 1)
    }

    // MARK: - DST transition

    @Test func sessionsAroundDSTTransitionGroupCorrectly() {
        // US spring forward: March 10, 2024 at 2:00 AM → 3:00 AM (America/New_York)
        // now = Monday March 18 (next week, fully in EDT).
        // calendar-correct startOfLastWeek = Sunday March 10 00:00 EST = March 10 05:00 UTC
        // naive startOfLastWeek = now - 7*24*3600 would land at March 10 04:00 UTC (wrong: 1h early)
        //
        // Session at March 9 23:30 EST = March 10 04:30 UTC:
        //   correct → "Earlier"  (< 05:00 UTC start of last week)
        //   naive   → "Last week" (>= 04:00 UTC — the off-by-one DST result)
        let nyTZ  = TimeZone(identifier: "America/New_York")!
        let cal   = makeCalendar(firstWeekday: 1, timeZone: nyTZ)
        let now   = makeDate(2024, 3, 18, hour: 12, calendar: cal)  // Monday

        let shouldBeLastWeek = session(at: makeDate(2024, 3, 10, hour: 1, calendar: cal)) // Sun 1am EST
        let shouldBeEarlier  = session(at: makeDate(2024, 3, 9,  hour: 23, calendar: cal)) // Sat 11pm EST

        let groups = HistoryGrouping.group(sessions: [shouldBeLastWeek, shouldBeEarlier], now: now, calendar: cal)

        #expect(groups.first { $0.label == "Last week" }?.sessions.count == 1)
        #expect(groups.first { $0.label == "Earlier"   }?.sessions.count == 1)
    }

    // MARK: - Locale: Sunday-start vs Monday-start

    @Test func sundayStartCalendarGroupsSundayInThisWeek() {
        // now = Monday Jan 8, 2024 at noon UTC
        // firstWeekday = 1 (Sunday): startOfThisWeek = Sunday Jan 7
        let cal = makeCalendar(firstWeekday: 1)
        let now = makeDate(2024, 1, 8, cal: cal)
        let sunday = session(at: makeDate(2024, 1, 7, hour: 10, calendar: cal))

        let groups = HistoryGrouping.group(sessions: [sunday], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "This week")
    }

    @Test func mondayStartCalendarGroupsSundayInLastWeek() {
        // now = Monday Jan 8, 2024 at noon UTC
        // firstWeekday = 2 (Monday): startOfThisWeek = Monday Jan 8
        // Sunday Jan 7 is therefore in last week
        let cal = makeCalendar(firstWeekday: 2)
        let now = makeDate(2024, 1, 8, cal: cal)
        let sunday = session(at: makeDate(2024, 1, 7, hour: 10, calendar: cal))

        let groups = HistoryGrouping.group(sessions: [sunday], now: now, calendar: cal)

        #expect(groups.count == 1)
        #expect(groups[0].label == "Last week")
    }
}

// Convenience overload so call sites can pass `cal:` without repeating `calendar:`.
private extension HistoryGroupingTests {
    func makeDate(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, cal: Calendar) -> Date {
        makeDate(year, month, day, hour: hour, calendar: cal)
    }
}
