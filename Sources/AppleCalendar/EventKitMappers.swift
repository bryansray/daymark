import Core
import EventKit
import Foundation

enum EventKitMappers {
    static func calendarSummary(from calendar: EKCalendar) -> CalendarSummary {
        CalendarSummary(
            id: calendar.calendarIdentifier,
            title: calendar.title,
            source: calendar.source.title,
            isWritable: calendar.allowsContentModifications
        )
    }

    static func calendarEvent(from event: EKEvent) -> CalendarEvent {
        CalendarEvent(
            id: event.eventIdentifier,
            calendarID: event.calendar.calendarIdentifier,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            location: event.location,
            notes: event.notes
        )
    }
}
