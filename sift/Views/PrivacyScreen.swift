import SwiftUI

struct PrivacySection {
    let title: String
    let paragraphs: [String]
}

enum PrivacyContent {
    static let tabLabel = "Privacy"
    static let title = "Privacy"
    static let displayTitle = "Your voice stays here."

    static let intro: [String] = [
        "Sift is a small passion project created by Jeremy Hartley.",
        "It is built to help people turn voice check-ins into practical wellness suggestions.",
    ]

    static let sections: [PrivacySection] = [
        PrivacySection(
            title: "Your voice",
            paragraphs: [
                "Your voice stays on your phone. Sift records audio locally and transcribes it on your device using on-device speech recognition. Sift deletes it after transcription. Your audio is not sent to the AI.",
                "Sift sends transcript text for AI suggestions. Your local check-in history — recent check-in text and whether past practices helped — is saved locally in the app. You can delete check-ins from History at any time.",
            ]
        ),
        PrivacySection(
            title: "AI and your data",
            paragraphs: [
                "Sift sends text to Google Gemini using Sift's developer API key. Sift does not attach your name, email, or account to Gemini requests. If you share identifying details in a check-in, that information becomes part of the transcript sent to Gemini.",
                "Google says paid Gemini API prompts and responses are not used to improve Google products, though requests are retained temporarily for service, safety, and abuse-prevention purposes.",
            ]
        ),
        PrivacySection(
            title: "Developer access",
            paragraphs: [
                "Sift does not have a server where your check-ins are stored. I cannot browse your recordings, transcripts, or history.",
                "Sift is made by Jeremy Hartley.\nContact: jphartley@gmail.com\nLast updated: 9 May 2026",
            ]
        ),
        PrivacySection(
            title: "Safety",
            paragraphs: [
                "Sift is here for reflection and practice suggestions. It is not a therapist, doctor, or crisis service.",
                "You are always allowed to pause, skip, adapt, or stop a practice. If something feels like too much, choose the gentlest next step available — put the phone down, feel your feet, take a breath, or reach out to someone you trust.",
                "If you are at risk of hurting yourself or someone else, or do not feel safe, please contact emergency support or a trusted person right away.",
            ]
        ),
    ]
}

struct PrivacyFeatureRow: Identifiable {
    let id: String
    let iconKind: String
    let heading: String
    let body: String
}

let privacyFeatureRows: [PrivacyFeatureRow] = [
    PrivacyFeatureRow(
        id: "on-device",
        iconKind: "Grounding",
        heading: "Transcribed on your phone",
        body: "Sift records your voice and transcribes it on your device using on-device speech recognition. The audio file is deleted right after. Your voice never leaves your phone."
    ),
    PrivacyFeatureRow(
        id: "no-access",
        iconKind: "Self-Compassion",
        heading: "Your data stays with you",
        body: "Sift has no server where your check-ins are stored. Only transcript text is sent to Gemini for practice suggestions — using Sift's API key, never attached to your name or account."
    ),
    PrivacyFeatureRow(
        id: "opt-in",
        iconKind: "Values & Intention",
        heading: "Opt-in cloud reflection",
        body: "Google says paid Gemini API prompts are not used to improve Google products, though requests may be temporarily retained for safety and abuse prevention."
    ),
]

struct PrivacyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                Text(PrivacyContent.displayTitle)
                    .font(SiftFont.display)
                    .foregroundStyle(SiftColor.ink)
                    .padding(.top, 60)

                ForEach(privacyFeatureRows) { row in
                    featureRow(row)
                }

                safetySection

                Divider().background(SiftColor.line)

                footnote

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
        .background(SiftColor.bg.ignoresSafeArea())
    }

    private func featureRow(_ row: PrivacyFeatureRow) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: SiftRadius.tile)
                    .fill(SiftColor.surfaceAlt)
                    .frame(width: 42, height: 42)
                CategoryIcon(kind: row.iconKind, size: 22)
                    .foregroundStyle(SiftColor.accentInk)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(row.heading)
                    .font(SiftFont.heading)
                    .foregroundStyle(SiftColor.ink)
                Text(row.body)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var safetySection: some View {
        let safety = PrivacyContent.sections.first(where: { $0.title == "Safety" })
        return VStack(alignment: .leading, spacing: 10) {
            Text("SAFETY")
                .font(SiftFont.eyebrow)
                .tracking(1.2)
                .foregroundStyle(SiftColor.quiet)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(safety?.paragraphs ?? [], id: \.self) { paragraph in
                    Text(paragraph)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                }
            }
        }
    }

    private var footnote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sift is made by Jeremy Hartley.")
                .font(SiftFont.caption)
                .foregroundStyle(SiftColor.quiet)
            Text("Contact: jphartley@gmail.com")
                .font(SiftFont.caption)
                .foregroundStyle(SiftColor.quiet)
            Text("Last updated: 9 May 2026")
                .font(SiftFont.caption)
                .foregroundStyle(SiftColor.quiet)
        }
    }
}

#Preview {
    PrivacyScreen()
}
