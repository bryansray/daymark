@testable import App
import Core
import XCTest

final class OutputPrinterTests: XCTestCase {
    func testRenderTableIncludesHeadersAndRows() {
        let lines = OutputPrinter.renderTable(
            headers: ["Name", "State"],
            rows: [["Work", "yes"], ["Personal", "no"]]
        )

        XCTAssertEqual(lines.count, 4)
        XCTAssertTrue(lines[0].contains("Name"))
        XCTAssertTrue(lines[0].contains("State"))
        XCTAssertTrue(lines[2].contains("Work"))
        XCTAssertTrue(lines[3].contains("Personal"))
    }

    func testRenderEventsIncludesCalendarTitleAndLocation() {
        let event = CalendarEvent(
            id: "evt-1",
            calendarID: "work",
            title: "Team Standup",
            startDate: Date(timeIntervalSince1970: 1_775_298_600),
            endDate: Date(timeIntervalSince1970: 1_775_300_400),
            isAllDay: false,
            location: "Conference Room"
        )

        let lines = OutputPrinter.renderEvents([event], calendarTitles: ["work": "Work"])

        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[0].contains("Team Standup"))
        XCTAssertTrue(lines[1].contains("calendar: Work"))
        XCTAssertTrue(lines[1].contains("location: Conference Room"))
    }

    func testRenderEventsShowsEmptyState() {
        XCTAssertEqual(OutputPrinter.renderEvents([], calendarTitles: [:]), ["No events found."])
    }

    func testRenderEventsUsesAllDayLabel() {
        let event = CalendarEvent(
            id: "evt-2",
            calendarID: "personal",
            title: "Birthday",
            startDate: Date(timeIntervalSince1970: 1_775_298_600),
            endDate: Date(timeIntervalSince1970: 1_775_385_000),
            isAllDay: true
        )

        let lines = OutputPrinter.renderEvents([event], calendarTitles: [:])
        XCTAssertTrue(lines[0].contains("All day"))
    }

    func testRenderAuthorizationUsesStateText() {
        XCTAssertTrue(OutputPrinter.renderAuthorization(.fullAccess).contains("fullAccess"))
        XCTAssertTrue(OutputPrinter.renderAuthorization(.denied).contains("denied"))
    }
}
