import Testing
@testable import sift

struct PrivacyContentTests {
    @Test func tabAndTitleUsePrivacyNotProviderNames() {
        #expect(PrivacyContent.tabLabel == "Privacy")
        #expect(PrivacyContent.title == "Privacy")
        #expect(PrivacyContent.tabLabel != "Gemini")
        #expect(PrivacyContent.tabLabel != "LLM")
        #expect(PrivacyContent.title != "Gemini")
        #expect(PrivacyContent.title != "LLM")
    }

    @Test func introNamesJeremyAndPlainPurpose() {
        let text = allPrivacyText()

        #expect(text.contains("Sift is a small passion project created by Jeremy Hartley."))
        #expect(text.contains("It is built to help people turn voice check-ins into practical wellness suggestions."))
    }

    @Test func dataFlowExplainsAudioTranscriptAndLocalHistory() {
        let text = allPrivacyText()

        #expect(text.contains("Your voice stays on your phone"))
        #expect(text.contains("transcribes it on your device"))
        #expect(text.contains("deletes it after transcription"))
        #expect(text.contains("Your audio is not sent to the AI"))
        #expect(text.contains("Sift sends transcript text for AI suggestions"))
        #expect(text.contains("recent check-in text and whether past practices helped"))
        #expect(text.contains("saved locally in the app"))
        #expect(text.contains("delete check-ins from History"))
    }

    @Test func developerAccessAndContactAreClear() {
        let text = allPrivacyText()

        #expect(text.contains("Sift does not have a server where your check-ins are stored"))
        #expect(text.contains("I cannot browse your recordings, transcripts, or history"))
        #expect(text.contains("Sift is made by Jeremy Hartley."))
        #expect(text.contains("Contact: jphartley@gmail.com"))
        #expect(text.contains("Last updated: 9 May 2026"))
    }

    @Test func aiSuggestionDisclosureAvoidsOverclaimingAnonymity() {
        let text = allPrivacyText()

        #expect(text.contains("Sift sends text to Google Gemini using Sift's developer API key"))
        #expect(text.contains("Sift does not attach your name, email, or account to Gemini requests"))
        #expect(text.contains("identifying details in a check-in"))
        #expect(text.contains("part of the transcript sent to Gemini"))
        #expect(text.contains("paid Gemini API prompts and responses are not used to improve Google products"))
        #expect(text.contains("retained temporarily for service, safety, and abuse-prevention purposes"))
        #expect(!text.localizedCaseInsensitiveContains("anonymous"))
    }

    @Test func safetySectionExistsInsidePrivacyContent() {
        #expect(PrivacyContent.sections.contains { $0.title == "Safety" })
    }

    @Test func safetySectionStatesPurposeAndNonTherapyBoundary() {
        let text = safetySectionText()

        #expect(text.contains("Sift is here for reflection and practice suggestions."))
        #expect(text.contains("It is not a therapist, doctor, or crisis service."))
    }

    @Test func safetySectionSupportsUserAgency() {
        let text = safetySectionText()

        #expect(text.contains("pause, skip, adapt, or stop a practice"))
        #expect(text.contains("choose the gentlest next step available"))
        #expect(text.contains("reach out to someone you trust"))
    }

    @Test func safetySectionGivesUrgentSupportGuidance() {
        let text = safetySectionText()

        #expect(text.contains("risk of hurting yourself or someone else"))
        #expect(text.contains("do not feel safe"))
        #expect(text.contains("contact emergency support or a trusted person right away"))
    }

    private func safetySectionText() -> String {
        guard let section = PrivacyContent.sections.first(where: { $0.title == "Safety" }) else {
            return ""
        }
        return section.paragraphs.joined(separator: "\n")
    }

    private func allPrivacyText() -> String {
        (PrivacyContent.intro + PrivacyContent.sections.flatMap { [$0.title] + $0.paragraphs })
            .joined(separator: "\n")
    }
}
