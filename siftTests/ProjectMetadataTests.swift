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

        let marketingValues = extractAssignments(of: "MARKETING_VERSION", in: project)
        let projectVersionValues = extractAssignments(of: "CURRENT_PROJECT_VERSION", in: project)

        #expect(!marketingValues.isEmpty, "MARKETING_VERSION must appear in the project file")
        #expect(!projectVersionValues.isEmpty, "CURRENT_PROJECT_VERSION must appear in the project file")

        for value in marketingValues + projectVersionValues {
            #expect(!value.isEmpty, "Version values must not be empty")
            #expect(!value.hasPrefix("$"), "Version values must be explicit literals, not interpolations: \(value)")
        }
    }

    @Test func applicationSupportDirectoryIsPreparedBeforeSwiftDataContainer() throws {
        let appSource = try appSourceText()

        let preparationCall = try #require(appSource.range(of: "try AppStoragePreparation.prepareApplicationSupportDirectory()"))
        let containerInitialization = try #require(appSource.range(of: "ModelContainer(for: Session.self, PracticeAttempt.self, MetricEvent.self, UserPracticeProfile.self)"))

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

    private func extractAssignments(of key: String, in source: String) -> [String] {
        let pattern = "\(NSRegularExpression.escapedPattern(for: key)) = ([^;]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(source.startIndex..., in: source)
        return regex.matches(in: source, range: range).compactMap { match in
            guard match.numberOfRanges > 1, let valueRange = Range(match.range(at: 1), in: source) else {
                return nil
            }
            return String(source[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
