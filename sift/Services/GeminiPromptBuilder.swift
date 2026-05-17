import Foundation

struct GeminiPromptBuilder {
    var practices: [Practice] = Practice.all

    private static let trimmedPracticeLimit = 20
    private static let trimmedHistoryLimit = 5

    func buildPrompt(
        transcript: String,
        history: [SessionHistoryEntry],
        profile: UserPracticeProfile? = nil,
        experiments: AnalysisLatencyExperimentSnapshot = .baseline
    ) -> String {
        var parts: [String] = []
        let practicesToUse = experiments.promptContextTrimmingEnabled
            ? Array(practices.prefix(Self.trimmedPracticeLimit))
            : practices
        let historyToUse = experiments.promptContextTrimmingEnabled
            ? Array(history.prefix(Self.trimmedHistoryLimit))
            : history

        parts.append("## Practice Library")
        parts.append("")
        for practice in practicesToUse {
            let bestFor = practice.bestFor.joined(separator: "; ")
            let evidence = practice.evidence.researchBacked ? "evidence:yes" : "evidence:no"
            var traits = [practice.matching.worldview]
            if practice.matching.bodyFocused { traits.append("body") }
            if practice.matching.closedEye { traits.append("closed-eye") }
            if practice.matching.breathFocused { traits.append("breath") }
            if practice.matching.devotional { traits.append("devotional") }
            if practice.matching.intense { traits.append("intense") }
            parts.append("- **\(practice.name)** (id: `\(practice.id)`, category: \(practice.category), family: \(practice.matching.family), ~\(practice.durationMinutes)m, \(practice.intensity), \(evidence), traits:\(traits.joined(separator: ","))): \(practice.summary) Best for: \(bestFor).")
        }

        if let profile, profile.completionState == .completed {
            parts.append("")
            parts.append("## Intake Profile")
            parts.append("")
            parts.append("Hard constraints must not be violated unless the current check-in clearly and specifically requests an exception.")
            let hardConstraints = profile.hardConstraints
            if hardConstraints.isEmpty {
                parts.append("Hard constraints: none captured.")
            } else {
                parts.append("Hard constraints:")
                for constraint in hardConstraints {
                    parts.append("- \(constraint)")
                }
            }
            let softPriors = profile.softPriors
            if softPriors.isEmpty {
                parts.append("Soft priors: none captured.")
            } else {
                parts.append("Soft priors:")
                for prior in softPriors {
                    parts.append("- \(prior)")
                }
            }
            if !profile.desiredSupportAreas.isEmpty {
                parts.append("Desired support areas: \(profile.desiredSupportAreas.joined(separator: ", ")).")
            }
            if !profile.practiceHistory.isEmpty {
                let historySignals = profile.practiceHistory.map { "\($0.family): \($0.signal.rawValue)" }
                parts.append("Practice history signals: \(historySignals.joined(separator: "; ")).")
            }
            if profile.requiresEvidenceGrounding {
                parts.append("Evidence preference: recommend only practices marked evidence-grounded in the library.")
            }
            if profile.requiresSecularFraming && profile.allowsSpiritualLanguage {
                parts.append("Language preference: secular framing is required; spiritual or contemplative language is allowed only when it avoids religious doctrine, devotional framing, prayer, deity language, and tradition-dependent authority.")
            } else if profile.requiresSecularFraming {
                parts.append("Language preference: secular framing only.")
            } else if profile.allowsSpiritualLanguage {
                parts.append("Language preference: spiritual language is okay when relevant.")
            }
            if !profile.coachingStyles.isEmpty {
                parts.append("Coaching style preferences: \(profile.coachingStyles.joined(separator: ", ")).")
            }
        }

        if !historyToUse.isEmpty {
            parts.append("")
            parts.append("## User History")
            parts.append("")
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            for (index, entry) in historyToUse.enumerated() {
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
