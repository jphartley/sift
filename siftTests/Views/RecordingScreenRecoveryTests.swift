import Testing
@testable import sift

struct RecordingScreenRecoveryTests {
    @Test func settingsActionTargetsAppSettingsPage() {
        #expect(RecordingScreenSettings.appSettingsURL?.absoluteString == "app-settings:")
    }
}
