import Testing
@testable import sift

struct RecordingScreenRecoveryTests {
    #if !targetEnvironment(macCatalyst)
    @Test func settingsActionTargetsAppSettingsPage() {
        #expect(RecordingScreenSettings.appSettingsURL?.absoluteString == "app-settings:")
    }
    #endif
}
