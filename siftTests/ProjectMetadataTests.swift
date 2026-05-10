import Foundation
import Testing

struct ProjectMetadataTests {
    @Test func appDisplayNameIsSiftAndReflect() throws {
        let project = try projectFileText()

        #expect(project.contains("INFOPLIST_KEY_CFBundleDisplayName = \"Sift and Reflect\";"))
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

    @Test func applicationSupportDirectoryIsPreparedBeforeSwiftDataContainer() throws {
        let appSource = try appSourceText()

        let preparationCall = try #require(appSource.range(of: "try AppStoragePreparation.prepareApplicationSupportDirectory()"))
        let containerInitialization = try #require(appSource.range(of: "ModelContainer(for: Session.self, PracticeAttempt.self)"))

        #expect(preparationCall.lowerBound < containerInitialization.lowerBound)
        #expect(!appSource.contains("ModelConfiguration("))
        #expect(!appSource.contains("default.store"))
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

    private func appSourceText() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let appSourceFile = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("sift")
            .appendingPathComponent("siftApp.swift")
        return try String(contentsOf: appSourceFile, encoding: .utf8)
    }
}
