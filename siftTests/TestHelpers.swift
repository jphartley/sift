import Foundation
import SwiftData
@testable import sift

enum TestHelpers {
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, PracticeAttempt.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }
}
