import Core
import EventKit
import Foundation

public final class AppleCalendarProvider: CalendarProvider, @unchecked Sendable {
    private let store: EKEventStore

    public init(store: EKEventStore = EKEventStore()) {
        self.store = store
    }

    public func authorizationStatus() -> AuthorizationState {
        EventKitAuthorization.map(EKEventStore.authorizationStatus(for: .event))
    }

    public func requestAccess() async throws -> AuthorizationState {
        if #available(macOS 14.0, *) {
            let granted = try await store.requestFullAccessToEvents()
            return granted ? .fullAccess : .denied
        } else {
            let granted = try await store.requestAccess(to: .event)
            return granted ? .fullAccess : .denied
        }
    }

    public func listCalendars() async throws -> [CalendarSummary] {
        try ensureReadAccess()

        return store.calendars(for: .event)
            .map(EventKitMappers.calendarSummary)
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    public func getCalendar(id: String?, name: String?) async throws -> CalendarSummary {
        let calendars = try await listCalendars()

        if let id,
           let calendar = calendars.first(where: { $0.id == id })
        {
            return calendar
        }

        if let name,
           let calendar = calendars.first(where: { $0.title == name })
        {
            return calendar
        }

        throw DaymarkError.notFound(
            resource: "calendar",
            details: [
                "id": id ?? "",
                "name": name ?? ""
            ].filter { $0.value.isEmpty == false }
        )
    }

    public func getEvent(id: String) async throws -> CalendarEvent {
        try ensureReadAccess()

        guard let event = store.event(withIdentifier: id) else {
            throw DaymarkError.notFound(resource: "event", details: ["id": id])
        }

        return EventKitMappers.calendarEvent(from: event)
    }

    public func listEvents(from start: Date, to end: Date, calendars: [String]) async throws -> [CalendarEvent] {
        try ensureReadAccess()

        let selectedCalendars = matchingCalendars(calendars)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: selectedCalendars)

        return store.events(matching: predicate)
            .map(EventKitMappers.calendarEvent)
            .sorted { $0.startDate < $1.startDate }
    }

    public func searchEvents(
        query: String,
        from start: Date,
        to end: Date,
        calendars: [String]
    ) async throws -> [CalendarEvent] {
        try ensureReadAccess()
        return try await listEvents(from: start, to: end, calendars: calendars)
            .filter { $0.matchesSearchText(query) }
    }

    private func matchingCalendars(_ filters: [String]) -> [EKCalendar]? {
        guard filters.isEmpty == false else {
            return nil
        }

        let allCalendars = store.calendars(for: .event)
        return allCalendars.filter { calendar in
            filters.contains(calendar.calendarIdentifier) || filters.contains(calendar.title)
        }
    }

    private func ensureReadAccess() throws {
        switch authorizationStatus() {
        case .fullAccess, .writeOnly:
            return
        case .notDetermined:
            throw DaymarkError.authorizationRequired
        case .denied, .restricted:
            throw DaymarkError.permissionDenied
        }
    }
}
