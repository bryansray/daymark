@testable import App
import Core
import XCTest

final class CalendarCommandTests: XCTestCase {
    override func tearDown() {
        CLIContext.reset()
        OutputPrinter.resetWriter()
        super.tearDown()
    }

    func testListCommandRendersCalendarTable() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "work-id", title: "Work", source: "iCloud", isWritable: true)
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try CalendarsListCommand.parse([])

        try await command.run()

        XCTAssertEqual(output.messages.count, 3)
        XCTAssertTrue(output.messages[0].contains("Title"))
        XCTAssertTrue(output.messages[2].contains("Work"))
        XCTAssertTrue(output.messages[2].contains("work-id"))
    }

    func testListCommandPrintsJSON() async throws {
        let provider = TestCalendarProvider()
        provider.calendars = [
            CalendarSummary(id: "personal-id", title: "Personal", source: "Local", isWritable: false)
        ]
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try CalendarsListCommand.parse(["--json"])

        try await command.run()

        XCTAssertEqual(output.messages.count, 1)
        XCTAssertTrue(output.messages[0].contains("\"title\" : \"Personal\""))
        XCTAssertTrue(output.messages[0].contains("\"id\" : \"personal-id\""))
    }

    func testGetCommandRequiresIDOrName() async throws {
        var command = try CalendarsGetCommand.parse([])

        await XCTAssertThrowsDaymarkError(
            expected: .validation(message: "Provide --id or --name.")
        ) {
            try await command.run()
        }
    }

    func testGetCommandLooksUpByName() async throws {
        let provider = TestCalendarProvider()
        provider.calendarsByLookup["name:Work"] = CalendarSummary(
            id: "work-id",
            title: "Work",
            source: "iCloud",
            isWritable: true
        )
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try CalendarsGetCommand.parse(["--name", "Work"])

        try await command.run()

        XCTAssertEqual(output.messages.count, 3)
        XCTAssertTrue(output.messages[0].contains("Work"))
        XCTAssertTrue(output.messages[1].contains("source: iCloud"))
        XCTAssertTrue(output.messages[2].contains("id: work-id"))
    }
}

private func XCTAssertThrowsDaymarkError(
    expected: DaymarkError,
    file: StaticString = #filePath,
    line: UInt = #line,
    _ body: () async throws -> Void
) async {
    do {
        try await body()
        XCTFail("Expected DaymarkError to be thrown", file: file, line: line)
    } catch let error as DaymarkError {
        XCTAssertEqual(error, expected, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
}
