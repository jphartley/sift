import Foundation

enum IntakePromptID: String, CaseIterable, Codable, Equatable, Hashable {
    case desiredSupport
    case priorPractice
    case boundaries
    case experience
    case hardMomentSupport
    case obstacles
    case guidanceStyle
}

struct IntakeChip: Identifiable, Equatable, Hashable {
    let id: String
    let label: String
}

struct IntakePrompt: Identifiable, Equatable {
    let id: IntakePromptID
    let title: String
    let chips: [IntakeChip]
    let voiceHint: String?
}

enum IntakeCopy {
    static let introduction = "Before your first check-in, Sift will ask a few questions about you: what you are looking for, what you have tried, and what you want it to respect."
    static let voiceIntroduction = "Tap the microphone to answer in your own words. This helps Sift understand you with more nuance, but you can also tap quick answers or skip anything."
    static let optionalTuning = "That’s enough to get started. You can answer a few more to give Sift a fuller picture, or begin your first check-in now."
    static let answerMoreAction = "Answer a few more"
    static let beginCheckInAction = "Begin check-in"
    static let nextAction = "Next"
    static let skipAction = "Skip"
    static let skipIntakeAction = "Skip intake"
    static let retryAction = "Retry"
    static let continueWithoutAnalysisAction = "Begin check-in without this"
    static let voiceAction = "Add voice answer"
    static let stopVoiceAction = "Stop"
    static let selectedItemLabels = ["Worked for me", "Helped sometimes", "Didn’t really help", "Please avoid"]

    static let primaryPrompts: [IntakePrompt] = [
        IntakePrompt(
            id: .desiredSupport,
            title: "What are you hoping Sift can help you with?",
            chips: [
                IntakeChip(id: "calming-down", label: "Calming down"),
                IntakeChip(id: "less-overwhelmed", label: "Feeling less overwhelmed"),
                IntakeChip(id: "processing-emotions", label: "Processing emotions"),
                IntakeChip(id: "getting-unstuck", label: "Getting unstuck"),
                IntakeChip(id: "kinder-to-myself", label: "Being kinder to myself"),
                IntakeChip(id: "finding-focus", label: "Finding focus"),
                IntakeChip(id: "sleeping-better", label: "Sleeping better"),
                IntakeChip(id: "making-sense", label: "Making sense of things"),
                IntakeChip(id: "regular-practice", label: "Building a regular practice")
            ],
            voiceHint: "Tap the microphone if you want to give Sift a fuller picture."
        ),
        IntakePrompt(
            id: .priorPractice,
            title: "What have you tried before? What worked, and what didn’t?",
            chips: [
                IntakeChip(id: "meditation", label: "Meditation"),
                IntakeChip(id: "breathwork", label: "Breathwork"),
                IntakeChip(id: "journaling", label: "Journaling"),
                IntakeChip(id: "yoga-or-movement", label: "Yoga or movement"),
                IntakeChip(id: "grounding", label: "Grounding exercises"),
                IntakeChip(id: "self-compassion", label: "Self-compassion"),
                IntakeChip(id: "prayer-or-spiritual-practice", label: "Prayer or spiritual practice"),
                IntakeChip(id: "creative-practices", label: "Creative practices"),
                IntakeChip(id: "little-or-no-prior-practice", label: "Nothing much yet")
            ],
            voiceHint: "These are just starting points. Tap the microphone to tell Sift what you’ve tried, what worked, what didn’t, and what you want it to avoid."
        ),
        IntakePrompt(
            id: .boundaries,
            title: "Is there anything you want Sift to respect or avoid?",
            chips: [
                IntakeChip(id: "secular-only", label: "Secular only"),
                IntakeChip(id: "spiritual-language-okay", label: "Spiritual language is okay"),
                IntakeChip(id: "research-backed-only", label: "Research-backed only"),
                IntakeChip(id: "avoid-body-focused", label: "No body-focused practices"),
                IntakeChip(id: "avoid-closed-eye", label: "No closed-eye practices"),
                IntakeChip(id: "short-practices", label: "Keep practices short"),
                IntakeChip(id: "practical-guidance", label: "Keep it practical"),
                IntakeChip(id: "no-preference", label: "No preference")
            ],
            voiceHint: "Tap the microphone if there’s anything Sift should avoid or be careful with."
        )
    ]

    static let optionalPrompts: [IntakePrompt] = [
        IntakePrompt(
            id: .experience,
            title: "How much experience do you have with practices like mindfulness, yoga, journaling, or breathwork?",
            chips: ["None yet", "Beginner", "Some experience", "Regular practice", "Experienced"].map { IntakeChip(id: $0.normalizedIntakeID, label: $0) },
            voiceHint: nil
        ),
        IntakePrompt(
            id: .hardMomentSupport,
            title: "When you are having a hard time, what tends to help?",
            chips: ["Stillness", "Movement", "Writing", "Talking to someone", "Sensory grounding", "Structure", "Self-compassion", "A practical next step"].map { IntakeChip(id: $0.normalizedIntakeID, label: $0) },
            voiceHint: nil
        ),
        IntakePrompt(
            id: .obstacles,
            title: "What tends to get in the way when you try practices like this?",
            chips: ["Restlessness", "Overthinking", "Feeling numb", "Self-criticism", "Not enough time", "Sticking with it", "It can feel fake", "Physical discomfort"].map { IntakeChip(id: $0.normalizedIntakeID, label: $0) },
            voiceHint: nil
        ),
        IntakePrompt(
            id: .guidanceStyle,
            title: "What style of guidance feels best to you?",
            chips: ["Gentle", "Direct", "Practical", "Structured", "Brief", "Low-pressure", "Quirky", "Spiritual"].map { IntakeChip(id: $0.normalizedIntakeID, label: $0) },
            voiceHint: nil
        )
    ]
}

struct IntakeResponse: Equatable {
    var promptID: IntakePromptID
    var selectedChipIDs: Set<String> = []
    var practiceSignals: [String: PracticeExperienceSignal] = [:]
    var voiceTranscript: String = ""
}

extension String {
    var normalizedIntakeID: String {
        lowercased()
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "&", with: "and")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}
