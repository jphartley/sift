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

    static let defaultPracticeYAML = """
    practices:
      - id: box-breathing
        name: Box Breathing
        category: Breathwork
        keywords:
          - breath
          - anxious
        description: |
          Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4.
        duration_minutes: 3
      - id: body-scan
        name: Body Scan
        category: Sensory
        keywords:
          - body
          - tension
        description: |
          Slowly move attention from head to toes.
        duration_minutes: 5
      - id: morning-pages
        name: Morning Pages
        category: Journaling
        keywords:
          - write
          - journal
        description: |
          Write 3 pages of stream-of-consciousness.
        duration_minutes: 10
      - id: stretch-break
        name: Stretch Break
        category: Movement
        keywords:
          - stretch
          - move
        description: |
          Stand up and stretch.
        duration_minutes: 3
    """

    static func setupPractices() {
        Practice.all = try! Practice.load(from: defaultPracticeYAML)
    }
}
