@testable import App
import Core
import XCTest

final class AuthCommandTests: XCTestCase {
    override func tearDown() {
        CLIContext.reset()
        OutputPrinter.resetWriter()
        super.tearDown()
    }

    func testStatusCommandRendersAuthorizationState() async throws {
        let provider = TestCalendarProvider()
        provider.authorizationState = .denied
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try AuthStatusCommand.parse([])

        try await command.run()

        XCTAssertEqual(output.messages.count, 1)
        XCTAssertTrue(output.messages[0].contains("denied"))
    }

    func testStatusCommandPrintsJSON() async throws {
        let provider = TestCalendarProvider()
        provider.authorizationState = .fullAccess
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try AuthStatusCommand.parse(["--json"])

        try await command.run()

        XCTAssertEqual(output.messages.count, 1)
        XCTAssertTrue(output.messages[0].contains("\"status\" : \"fullAccess\""))
    }

    func testGrantCommandRequestsAccessAndPrintsJSON() async throws {
        let provider = TestCalendarProvider()
        provider.authorizationState = .fullAccess
        CLIContext.provider = provider
        let output = CapturedOutput()
        OutputPrinter.setWriter { output.append($0) }

        var command = try AuthGrantCommand.parse(["--json"])

        try await command.run()

        XCTAssertEqual(provider.requestAccessCallCount, 1)
        XCTAssertEqual(output.messages.count, 1)
        XCTAssertTrue(output.messages[0].contains("\"status\" : \"fullAccess\""))
    }
}
