import Foundation
import Testing

struct ProjectMetadataTests {
    @Test func appDisplayNameIsSift() throws {
        let project = try projectFileText()

        #expect(project.contains("INFOPLIST_KEY_CFBundleDisplayName = Sift;"))
    }

    @Test func microphoneUsageDescriptionMatchesVoiceCheckInPurpose() throws {
        let project = try projectFileText()

        #expect(project.contains("record your voice check-in"))
        #expect(project.contains("transcribe it on your device"))
        #expect(!project.localizedCaseInsensitiveContains("voice samples"))
        #expect(!project.localizedCaseInsensitiveContains("speech-to-text evaluation"))
    }

    @Test func appVersionMetadataIsExplicit() throws {
        let project = try projectFileText()

        #expect(project.contains("MARKETING_VERSION = 0.1;"))
        #expect(project.contains("CURRENT_PROJECT_VERSION = 1;"))
    }

    private func projectFileText() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let projectFile = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("sift.xcodeproj")
            .appendingPathComponent("project.pbxproj")
        return try String(contentsOf: projectFile, encoding: .utf8)
    }
}
