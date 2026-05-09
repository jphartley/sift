import SwiftUI

struct PrivacySection: Identifiable, Equatable {
    let id: String
    let title: String
    let paragraphs: [String]
}

enum PrivacyContent {
    static let title = "Privacy"
    static let tabLabel = "Privacy"
    static let intro = [
        "Sift is a small passion project created by Jeremy Hartley.",
        "It is built to help people turn voice check-ins into practical wellness suggestions."
    ]
    static let sections = [
        PrivacySection(
            id: "recording",
            title: "What happens when you record",
            paragraphs: [
                "Your voice stays on your phone. Sift records your audio on your device and transcribes it on your device.",
                "The audio file is temporary. Sift deletes it after transcription.",
                "Sift sends transcript text for AI suggestions. Your audio is not sent to the AI.",
                "To make suggestions more useful, Sift may include recent check-in text and whether past practices helped.",
                "Your check-ins and practice reflections are saved locally in the app. You can delete check-ins from History."
            ]
        ),
        PrivacySection(
            id: "developer-access",
            title: "What I can see",
            paragraphs: [
                "Sift does not have a server where your check-ins are stored.",
                "I cannot browse your recordings, transcripts, or history."
            ]
        ),
        PrivacySection(
            id: "ai-suggestions",
            title: "About AI suggestions",
            paragraphs: [
                "Sift sends text to Google Gemini using Sift's developer API key.",
                "Sift does not attach your name, email, or account to Gemini requests.",
                "If you say identifying details in a check-in, those words are part of the transcript sent to Gemini.",
                "Google says paid Gemini API prompts and responses are not used to improve Google products, though requests may be retained temporarily for service, safety, and abuse-prevention purposes."
            ]
        ),
        PrivacySection(
            id: "safety",
            title: "Safety",
            paragraphs: [
                "Sift is for reflection and practice suggestions. More safety guidance will live here as the beta gets ready."
            ]
        ),
        PrivacySection(
            id: "questions",
            title: "Questions",
            paragraphs: [
                "Sift is made by Jeremy Hartley.",
                "Contact: jphartley@gmail.com",
                "Last updated: 9 May 2026"
            ]
        )
    ]
}

struct PrivacyScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(PrivacyContent.intro, id: \.self) { paragraph in
                            Text(paragraph)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    ForEach(PrivacyContent.sections) { section in
                        sectionView(section)
                    }
                }
                .padding()
            }
            .navigationTitle(PrivacyContent.title)
        }
    }

    private func sectionView(_ section: PrivacySection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(section.paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    PrivacyScreen()
}
