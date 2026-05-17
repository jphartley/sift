import Foundation
import Testing
@testable import sift

struct IntakeContentTests {

    @Test func introductionCopyMatchesApprovedLanguage() {
        #expect(IntakeCopy.introduction == "Before your first check-in, Sift will ask a few questions about you: what you are looking for, what you have tried, and what you want it to respect.")
        #expect(IntakeCopy.voiceIntroduction == "Tap the microphone to answer in your own words. This helps Sift understand you with more nuance, but you can also tap quick answers or skip anything.")
    }

    @Test func primaryPromptCopyAndChipLabelsMatchApprovedLanguage() {
        #expect(IntakeCopy.primaryPrompts[0].title == "What are you hoping Sift can help you with?")
        #expect(IntakeCopy.primaryPrompts[0].chips.map(\.label) == [
            "Calming down",
            "Feeling less overwhelmed",
            "Processing emotions",
            "Getting unstuck",
            "Being kinder to myself",
            "Finding focus",
            "Sleeping better",
            "Making sense of things",
            "Building a regular practice"
        ])
        #expect(IntakeCopy.primaryPrompts[0].voiceHint == "Tap the microphone if you want to give Sift a fuller picture.")

        #expect(IntakeCopy.primaryPrompts[1].title == "What have you tried before? What worked, and what didn’t?")
        #expect(IntakeCopy.primaryPrompts[1].chips.map(\.label) == [
            "Meditation",
            "Breathwork",
            "Journaling",
            "Yoga or movement",
            "Grounding exercises",
            "Self-compassion",
            "Prayer or spiritual practice",
            "Creative practices",
            "Nothing much yet"
        ])
        #expect(IntakeCopy.selectedItemLabels == ["Worked for me", "Helped sometimes", "Didn’t really help", "Please avoid"])
        #expect(IntakeCopy.primaryPrompts[1].voiceHint == "These are just starting points. Tap the microphone to tell Sift what you’ve tried, what worked, what didn’t, and what you want it to avoid.")

        #expect(IntakeCopy.primaryPrompts[2].title == "Is there anything you want Sift to respect or avoid?")
        #expect(IntakeCopy.primaryPrompts[2].chips.map(\.label) == [
            "Secular only",
            "Spiritual language is okay",
            "Research-backed only",
            "No body-focused practices",
            "No closed-eye practices",
            "Keep practices short",
            "Keep it practical",
            "No preference"
        ])
        #expect(IntakeCopy.primaryPrompts[2].voiceHint == "Tap the microphone if there’s anything Sift should avoid or be careful with.")
    }

    @Test func optionalPromptCopyAndActionsMatchApprovedLanguage() {
        #expect(IntakeCopy.optionalTuning == "That’s enough to get started. You can answer a few more to give Sift a fuller picture, or begin your first check-in now.")
        #expect(IntakeCopy.answerMoreAction == "Answer a few more")
        #expect(IntakeCopy.beginCheckInAction == "Begin check-in")

        #expect(IntakeCopy.optionalPrompts[0].title == "How much experience do you have with practices like mindfulness, yoga, journaling, or breathwork?")
        #expect(IntakeCopy.optionalPrompts[0].chips.map(\.label) == ["None yet", "Beginner", "Some experience", "Regular practice", "Experienced"])
        #expect(IntakeCopy.optionalPrompts[1].title == "When you are having a hard time, what tends to help?")
        #expect(IntakeCopy.optionalPrompts[1].chips.map(\.label) == ["Stillness", "Movement", "Writing", "Talking to someone", "Sensory grounding", "Structure", "Self-compassion", "A practical next step"])
        #expect(IntakeCopy.optionalPrompts[2].title == "What tends to get in the way when you try practices like this?")
        #expect(IntakeCopy.optionalPrompts[2].chips.map(\.label) == ["Restlessness", "Overthinking", "Feeling numb", "Self-criticism", "Not enough time", "Sticking with it", "It can feel fake", "Physical discomfort"])
        #expect(IntakeCopy.optionalPrompts[3].title == "What style of guidance feels best to you?")
        #expect(IntakeCopy.optionalPrompts[3].chips.map(\.label) == ["Gentle", "Direct", "Practical", "Structured", "Brief", "Low-pressure", "Quirky", "Spiritual"])
    }

    @Test func firstLaunchGateShowsOnlyWhenNoProfileExists() {
        #expect(IntakeGate.shouldShowIntake(profiles: []))
        #expect(!IntakeGate.shouldShowIntake(profiles: [.skipped()]))
        #expect(!IntakeGate.shouldShowIntake(profiles: [UserPracticeProfile(completionState: .completed)]))
    }
}
