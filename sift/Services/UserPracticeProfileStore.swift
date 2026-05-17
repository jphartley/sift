import Foundation
import SwiftData

protocol UserPracticeProfileStore: AnyObject {
    func currentProfile() throws -> UserPracticeProfile?
    func save(_ profile: UserPracticeProfile) throws
    func markSkipped() throws
}

final class SwiftDataUserPracticeProfileStore: UserPracticeProfileStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func currentProfile() throws -> UserPracticeProfile? {
        var descriptor = FetchDescriptor<UserPracticeProfile>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func save(_ profile: UserPracticeProfile) throws {
        if let existing = try currentProfile() {
            existing.replace(with: profile)
        } else {
            modelContext.insert(profile)
        }
        try modelContext.save()
    }

    func markSkipped() throws {
        try save(.skipped())
    }
}
