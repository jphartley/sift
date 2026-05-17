import Foundation

protocol IntakeAnalyzing {
    func analyze(responses: [IntakeResponse], optionalTuningCompleted: Bool) async throws -> UserPracticeProfile
}

enum IntakeAnalysisError: LocalizedError, Equatable {
    case failed

    var errorDescription: String? {
        "Sift could not save that context yet."
    }
}

struct LocalIntakeAnalyzer: IntakeAnalyzing {
    func analyze(responses: [IntakeResponse], optionalTuningCompleted: Bool) async throws -> UserPracticeProfile {
        let desiredSupport = labels(for: .desiredSupport, selectedIn: responses)
        let boundaryIDs = selectedIDs(for: .boundaries, in: responses)
        let sourceNotes = responses.map(\.voiceTranscript)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let sourceText = sourceNotes.joined(separator: " ").lowercased()
        let practiceHistory = practiceHistory(from: responses, sourceText: sourceText)
        let hardConstraints = hardConstraints(from: boundaryIDs, sourceText: sourceText, practiceHistory: practiceHistory)
        let softPriors = softPriors(from: responses, boundaryIDs: boundaryIDs, sourceText: sourceText, practiceHistory: practiceHistory)
        let avoidedFamilies = practiceHistory
            .filter { $0.signal == .pleaseAvoid }
            .map(\.family)
            .sorted()
        let preferredFamilies = practiceHistory
            .filter { $0.signal == .workedForMe }
            .map(\.family)
            .sorted()
        let loweredPriorityFamilies = practiceHistory
            .filter { $0.signal == .helpedSometimes || $0.signal == .didNotReallyHelp }
            .map(\.family)
            .sorted()
        let coachingStyles = labels(for: .guidanceStyle, selectedIn: responses)

        return UserPracticeProfile(
            completionState: .completed,
            optionalTuningCompleted: optionalTuningCompleted,
            desiredSupportAreas: desiredSupport,
            practiceHistory: practiceHistory,
            hardConstraints: hardConstraints,
            softPriors: softPriors,
            avoidedPracticeFamilies: avoidedFamilies,
            preferredPracticeFamilies: preferredFamilies,
            loweredPriorityPracticeFamilies: loweredPriorityFamilies,
            coachingStyles: coachingStyles,
            sourceNotes: sourceNotes,
            requiresSecularFraming: boundaryIDs.contains("secular-only") || sourceText.contains("secular only"),
            allowsSpiritualLanguage: boundaryIDs.contains("spiritual-language-okay"),
            requiresEvidenceGrounding: boundaryIDs.contains("research-backed-only") || sourceText.contains("research-backed only"),
            avoidsBodyFocused: boundaryIDs.contains("avoid-body-focused") || sourceText.contains("body-focused") || sourceText.contains("body focused"),
            avoidsClosedEye: boundaryIDs.contains("avoid-closed-eye") || sourceText.contains("closed-eye") || sourceText.contains("closed eye"),
            avoidsBreathFocused: sourceText.contains("avoid breath") || sourceText.contains("no breathwork"),
            avoidsIntensePractices: sourceText.contains("nothing intense") || sourceText.contains("avoid intense"),
            preferredDurationMaxMinutes: boundaryIDs.contains("short-practices") ? 5 : nil
        )
    }

    private func selectedIDs(for promptID: IntakePromptID, in responses: [IntakeResponse]) -> Set<String> {
        responses.first { $0.promptID == promptID }?.selectedChipIDs ?? []
    }

    private func labels(for promptID: IntakePromptID, selectedIn responses: [IntakeResponse]) -> [String] {
        let prompt = (IntakeCopy.primaryPrompts + IntakeCopy.optionalPrompts).first { $0.id == promptID }
        let selectedIDs = selectedIDs(for: promptID, in: responses)
        return prompt?.chips.filter { selectedIDs.contains($0.id) }.map(\.label) ?? []
    }

    private func practiceHistory(from responses: [IntakeResponse], sourceText: String) -> [PracticeFamilyPreference] {
        var signals = responses.first { $0.promptID == .priorPractice }?.practiceSignals ?? [:]
        if sourceText.contains("avoid meditation") || sourceText.contains("no meditation") {
            signals["meditation"] = .pleaseAvoid
        }
        if sourceText.contains("avoid breathwork") || sourceText.contains("no breathwork") {
            signals["breathwork"] = .pleaseAvoid
        } else if sourceText.contains("breathwork helped sometimes") {
            signals["breathwork"] = .helpedSometimes
        }
        return signals
            .filter { $0.key != "little-or-no-prior-practice" }
            .map { PracticeFamilyPreference(family: $0.key, signal: $0.value) }
            .sorted { $0.family < $1.family }
    }

    private func hardConstraints(
        from boundaryIDs: Set<String>,
        sourceText: String,
        practiceHistory: [PracticeFamilyPreference]
    ) -> [String] {
        var constraints: [String] = []
        if boundaryIDs.contains("secular-only") || sourceText.contains("secular only") {
            constraints.append("Use secular framing; avoid religious doctrine, devotional framing, prayer, deity language, and tradition-dependent authority unless the current check-in clearly requests it.")
        }
        if boundaryIDs.contains("research-backed-only") || sourceText.contains("research-backed only") {
            constraints.append("Recommend only practices with explicit evidence grounding.")
        }
        if boundaryIDs.contains("avoid-body-focused") || sourceText.contains("body-focused") || sourceText.contains("body focused") {
            constraints.append("Avoid body-focused practices.")
        }
        if boundaryIDs.contains("avoid-closed-eye") || sourceText.contains("closed-eye") || sourceText.contains("closed eye") {
            constraints.append("Avoid closed-eye practices.")
        }
        if sourceText.contains("avoid breath") || sourceText.contains("no breathwork") {
            constraints.append("Avoid breath-focused practices.")
        }
        if sourceText.contains("nothing intense") || sourceText.contains("avoid intense") {
            constraints.append("Avoid intense practices.")
        }
        for family in practiceHistory where family.signal == .pleaseAvoid {
            constraints.append("Avoid \(family.family) practices.")
        }
        return constraints
    }

    private func softPriors(
        from responses: [IntakeResponse],
        boundaryIDs: Set<String>,
        sourceText: String,
        practiceHistory: [PracticeFamilyPreference]
    ) -> [String] {
        var priors: [String] = []
        if boundaryIDs.contains("spiritual-language-okay") {
            priors.append("Spiritual or contemplative language is okay when it remains compatible with hard constraints.")
        }
        if boundaryIDs.contains("practical-guidance") {
            priors.append("Prefer grounded, usable guidance.")
        }
        if boundaryIDs.contains("short-practices") {
            priors.append("Prefer short practices around five minutes or less.")
        }
        for family in practiceHistory {
            switch family.signal {
            case .workedForMe:
                priors.append("\(family.family) has worked before.")
            case .helpedSometimes:
                priors.append("\(family.family) helped sometimes; recommend it only when especially relevant.")
            case .didNotReallyHelp:
                priors.append("\(family.family) did not really help; lower its priority without banning it.")
            case .pleaseAvoid:
                break
            }
        }
        for label in labels(for: .hardMomentSupport, selectedIn: responses) {
            priors.append("During hard moments, \(label.lowercased()) tends to help.")
        }
        for label in labels(for: .obstacles, selectedIn: responses) {
            priors.append("Obstacle to account for: \(label).")
        }
        if sourceText.contains("gentle") {
            priors.append("Prefer gentle guidance.")
        }
        return priors
    }
}
