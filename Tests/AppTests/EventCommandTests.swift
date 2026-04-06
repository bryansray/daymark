@testable import App
import Core
import Foundation
import XCTest

final class EventCommandTests: XCTestCase {
    override func tearDown() {
        CLIContext.reset()
        OutputPrinter.resetWriter()
        super.tearDown()
    }

    func testTodayCommandUsesCurrentDayRange() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work", title: "Work", source: "iCloud", isWritable: true)
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try EventsTodayCommand.parse(["--calendar", "work"])

        try await command.run()

        let call = try XCTUnwrap(provider.listEventsCalls.first)
        let calendar = Calendar.autoupdatingCurrent

        XCTAssertEqual(call.start, calendar.startOfDay(for: call.start))
        XCTAssertEqual(call.end, calendar.date(byAdding: .day, value: 1, to: call.start))
        XCTAssertEqual(call.calendars, ["work"])
        XCTAssertEqual(output.messages, ["No events found."])
    }

    func testTomorrowCommandUsesNextDayRange() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "personal", title: "Personal", source: "iCloud", isWritable: true)
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

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
        XCTAssertEqual(output.messages, ["No events found."])
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
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

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
        XCTAssertEqual(output.messages.count, 1)
        XCTAssertTrue(output.messages[0].contains("\"title\" : \"Design Review\""))
    }

    func testSearchCommandFiltersByPartialID() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work", title: "Work", source: "iCloud", isWritable: true)
        ]
        provider.events = [
            makeEvent(id: "abc-123", title: "Design Review"),
            makeEvent(id: "xyz-789", title: "Planning")
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try EventsSearchCommand.parse([
            "--id", "123",
            "--from", "2026-04-01",
            "--to", "2026-04-30"
        ])

        try await command.run()

        XCTAssertEqual(provider.searchEventsCalls.count, 0)
        XCTAssertEqual(provider.listEventsCalls.count, 1)
        XCTAssertEqual(output.messages.count, 2)
        XCTAssertTrue(output.messages[0].contains("Design Review"))
        XCTAssertTrue(output.messages[1].contains("id: abc-123"))
    }

    func testListCommandAppliesLimitAfterFetch() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work", title: "Work", source: "iCloud", isWritable: true)
        ]
        provider.events = [
            makeEvent(id: "evt-1", title: "First"),
            makeEvent(id: "evt-2", title: "Second"),
            makeEvent(id: "evt-3", title: "Third")
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try EventsListCommand.parse([
            "--from", "2026-04-01",
            "--to", "2026-04-30",
            "--limit", "2"
        ])

        try await command.run()

        XCTAssertEqual(provider.listEventsCalls.count, 1)
        XCTAssertEqual(output.messages.count, 5)
        XCTAssertTrue(output.messages[0].contains("First"))
        XCTAssertEqual(output.messages[2], "")
        XCTAssertTrue(output.messages[3].contains("Second"))
        XCTAssertFalse(output.messages.joined(separator: "\n").contains("Third"))
    }

    func testUpcomingCommandUsesLimitAndRange() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work", title: "Work", source: "iCloud", isWritable: true)
        ]
        provider.events = [
            makeEvent(id: "evt-1", title: "First"),
            makeEvent(id: "evt-2", title: "Second"),
            makeEvent(id: "evt-3", title: "Third")
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try EventsUpcomingCommand.parse([
            "--calendar", "work",
            "--days", "7",
            "--limit", "2"
        ])

        try await command.run()

        let call = try XCTUnwrap(provider.listEventsCalls.first)
        XCTAssertEqual(call.calendars, ["work"])
        XCTAssertEqual(call.end.timeIntervalSince(call.start), 7 * 24 * 60 * 60, accuracy: 1)
        XCTAssertEqual(output.messages.count, 5)
        XCTAssertTrue(output.messages[0].contains("First"))
        XCTAssertEqual(output.messages[2], "")
        XCTAssertTrue(output.messages[3].contains("Second"))
        XCTAssertFalse(output.messages.joined(separator: "\n").contains("Third"))
    }
}

private func makeEvent(id: String, title: String) -> CalendarEvent {
    CalendarEvent(
        id: id,
        calendarID: "work",
        title: title,
        startDate: Date(timeIntervalSince1970: 1_775_298_600),
        endDate: Date(timeIntervalSince1970: 1_775_300_400),
        isAllDay: false
    )
}
