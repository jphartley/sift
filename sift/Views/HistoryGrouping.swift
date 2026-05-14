import Foundation

enum HistoryGrouping {
    static func group(
        sessions: [Session],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [(label: String, sessions: [Session])] {
        let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek) ?? now

        var thisWeek: [Session] = []
        var lastWeek: [Session] = []
        var earlier:  [Session] = []

        for session in sessions {
            if session.timestamp >= startOfThisWeek {
                thisWeek.append(session)
            } else if session.timestamp >= startOfLastWeek {
                lastWeek.append(session)
            } else {
                earlier.append(session)
            }
        }

        var groups: [(label: String, sessions: [Session])] = []
        if !thisWeek.isEmpty { groups.append((label: "This week", sessions: thisWeek)) }
        if !lastWeek.isEmpty { groups.append((label: "Last week", sessions: lastWeek)) }
        if !earlier.isEmpty  { groups.append((label: "Earlier",   sessions: earlier))  }
        return groups
    }
}
