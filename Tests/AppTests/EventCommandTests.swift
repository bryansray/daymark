@testable import App
import Core
import XCTest

final class EventCommandTests: XCTestCase {
    override func tearDown() {
        CLIContext.reset()
        super.tearDown()
    }

    func testTodayCommandUsesCurrentDayRange() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work", title: "Work", source: "iCloud", isWritable: true)
        ]
        CLIContext.provider = provider

        var command = try EventsTodayCommand.parse(["--calendar", "work"])

        try await command.run()

        let call = try XCTUnwrap(provider.listEventsCalls.first)
        let calendar = Calendar.autoupdatingCurrent

        XCTAssertEqual(call.start, calendar.startOfDay(for: call.start))
        XCTAssertEqual(call.end, calendar.date(byAdding: .day, value: 1, to: call.start))
        XCTAssertEqual(call.calendars, ["work"])
    }

    func testTomorrowCommandUsesNextDayRange() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "personal", title: "Personal", source: "iCloud", isWritable: true)
        ]
        CLIContext.provider = provider

        var command = try EventsTomorrowCommand.parse(["--calendar", "personal"])

        try await command.run()

        let call = try XCTUnwrap(provider.listEventsCalls.first)
        let calendar = Calendar.autoupdatingCurrent
        let todayStart = calendar.startOfDay(for: Date())
        let tomorrowStart = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: todayStart))
        let nextDayStart = try XCTUnwrap(calendar.date(byAdding: .day, value: 2, to: todayStart))

        XCTAssertEqual(call.start.timeIntervalSinceReferenceDate, tomorrowStart.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(call.end.timeIntervalSinceReferenceDate, nextDayStart.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(call.calendars, ["personal"])
    }

    func testSearchCommandUsesProviderSearchWhenQueryIsPresent() async throws {
        let provider = TestCalendarProvider()
        provider.events = [
            CalendarEvent(
                id: "abc-123",
                calendarID: "work",
                title: "Design Review",
                startDate: .distantPast,
                endDate: .distantFuture,
                isAllDay: false
            )
        ]
        CLIContext.provider = provider

        var command = try EventsSearchCommand.parse([
            "--query", "design",
            "--from", "2026-04-01",
            "--to", "2026-04-30",
            "--json"
        ])

        try await command.run()

        let call = try XCTUnwrap(provider.searchEventsCalls.first)
        XCTAssertEqual(call.query, "design")
        XCTAssertTrue(provider.listEventsCalls.isEmpty)
    }
}
