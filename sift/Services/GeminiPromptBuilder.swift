import Foundation

struct GeminiPromptBuilder {
    var practices: [Practice] = Practice.all

    func buildPrompt(transcript: String, history: [SessionHistoryEntry]) -> String {
        var parts: [String] = []

        parts.append("## Practice Library")
        parts.append("")
        for practice in practices {
            parts.append("- **\(practice.name)** (id: `\(practice.id)`, \(practice.category), ~\(practice.durationMinutes)m): \(practice.description)")
        }

        if !history.isEmpty {
            parts.append("")
            parts.append("## User History")
            parts.append("")
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            for (index, entry) in history.enumerated() {
                let dateStr = formatter.string(from: entry.timestamp)
                parts.append("### Session \(index + 1) (\(dateStr))")
                parts.append("What they said: \"\(entry.transcript)\"")
                if let name = entry.practiceName {
                    if let helpful = entry.wasHelpful {
                        parts.append("Practice tried: \(name) — \(helpful ? "Helpful" : "Not helpful")")
                    } else {
                        parts.append("Practice tried: \(name) — No rating")
                    }
                } else {
                    parts.append("No practice was tried.")
                }
                parts.append("")
            }
        }

        parts.append("## Current Check-In")
        parts.append("")
        parts.append("The user just said: \"\(transcript)\"")
        parts.append("")
        parts.append("Recommend 2-3 practices from the library above that would help them right now.")

        return parts.joined(separator: "\n")
    }
}
