import Foundation

public extension CalendarEvent {
    func matchesSearchText(_ query: String) -> Bool {
        let needle = query.lowercased()

        return title.lowercased().contains(needle)
            || (location?.lowercased().contains(needle) ?? false)
            || (notes?.lowercased().contains(needle) ?? false)
    }

    func matchesPartialID(_ partialID: String) -> Bool {
        id.localizedCaseInsensitiveContains(partialID)
    }
}
