import Core
import Foundation

final class TestCalendarProvider: CalendarProvider, @unchecked Sendable {
    struct ListEventsCall: Equatable {
        let start: Date
        let end: Date
        let calendars: [String]
    }

    struct SearchEventsCall: Equatable {
        let query: String
        let start: Date
        let end: Date
        let calendars: [String]
    }

    var authorizationState: AuthorizationState = .fullAccess
    var calendars: [CalendarSummary] = []
    var events: [CalendarEvent] = []
    var calendarsByLookup: [String: CalendarSummary] = [:]
    var eventByID: [String: CalendarEvent] = [:]

    private(set) var listEventsCalls: [ListEventsCall] = []
    private(set) var searchEventsCalls: [SearchEventsCall] = []
    private(set) var requestAccessCallCount = 0

    func authorizationStatus() -> AuthorizationState {
        authorizationState
    }

    func requestAccess() async throws -> AuthorizationState {
        requestAccessCallCount += 1
        return authorizationState
    }

    func listCalendars() async throws -> [CalendarSummary] {
        calendars
    }

    func getCalendar(id: String?, name: String?) async throws -> CalendarSummary {
        if let id, let calendar = calendarsByLookup["id:\(id)"] {
            return calendar
        }

        if let name, let calendar = calendarsByLookup["name:\(name)"] {
            return calendar
        }

        throw DaymarkError.notFound(resource: "calendar")
    }

    func getEvent(id: String) async throws -> CalendarEvent {
        if let event = eventByID[id] {
            return event
        }

        throw DaymarkError.notFound(resource: "event", details: ["id": id])
    }

    func listEvents(from start: Date, to end: Date, calendars: [String]) async throws -> [CalendarEvent] {
        listEventsCalls.append(
            ListEventsCall(
                start: start,
                end: end,
                calendars: calendars
            )
        )

        return events
    }

    func searchEvents(
        query: String,
        from start: Date,
        to end: Date,
        calendars: [String]
    ) async throws -> [CalendarEvent] {
        searchEventsCalls.append(
            SearchEventsCall(
                query: query,
                start: start,
                end: end,
                calendars: calendars
            )
        )

        return events.filter { $0.matchesSearchText(query) }
    }
}
