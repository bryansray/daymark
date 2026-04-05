import Core
import XCTest

final class DateParserTests: XCTestCase {
    func testParsesISO8601DateTime() throws {
        let date = try DateParser.parse("2026-04-04T10:30:00Z")
        XCTAssertEqual(date.timeIntervalSince1970, 1_775_298_600)
    }

    func testParsesCalendarDate() throws {
        let date = try DateParser.parse("2026-04-04")
        XCTAssertGreaterThan(date.timeIntervalSince1970, 0)
    }

    func testRejectsInvalidDates() {
        XCTAssertThrowsError(try DateParser.parse("banana")) { error in
            XCTAssertEqual(error as? DaymarkError, .invalidDate("banana"))
        }
    }

    func testTodayRangeUsesLocalDayBoundaries() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: -18_000) ?? .current

        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(parser.date(from: "2026-04-05T22:55:00-05:00"))
        let range = try DateRange.today(now: now, calendar: calendar)

        let formatter = ISO8601DateFormatter()
        formatter.timeZone = calendar.timeZone
        formatter.formatOptions = [.withInternetDateTime]

        XCTAssertEqual(formatter.string(from: range.start), "2026-04-05T00:00:00-05:00")
        XCTAssertEqual(formatter.string(from: range.end), "2026-04-06T00:00:00-05:00")
    }

    func testCalendarEventMatchesSearchTextAndPartialID() {
        let event = CalendarEvent(
            id: "abc-123-xyz",
            calendarID: "work",
            title: "Design Review",
            startDate: .distantPast,
            endDate: .distantFuture,
            isAllDay: false,
            location: "Conference Room",
            notes: "Bring mocks"
        )

        XCTAssertTrue(event.matchesSearchText("design"))
        XCTAssertTrue(event.matchesSearchText("conference"))
        XCTAssertTrue(event.matchesSearchText("mocks"))
        XCTAssertFalse(event.matchesSearchText("dentist"))
        XCTAssertTrue(event.matchesPartialID("123"))
        XCTAssertTrue(event.matchesPartialID("ABC-123"))
        XCTAssertFalse(event.matchesPartialID("999"))
    }
}
