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
        labels:
          - calm
        best_for:
          - racing thoughts
        keywords:
          - breath
          - anxious
        summary: A steady breathing pattern for anxious moments.
        steps:
          - Inhale for 4 seconds.
          - Hold for 4 seconds.
          - Exhale for 4 seconds.
          - Hold for 4 seconds.
        why_it_helps: A predictable rhythm gives attention somewhere steady to land.
        duration_minutes: 3
        intensity: low
        avoid_when:
          - feeling dizzy
      - id: body-scan
        name: Body Scan
        category: Sensory
        labels:
          - body-awareness
        best_for:
          - physical tension
        keywords:
          - body
          - tension
        summary: A gentle scan through the body.
        steps:
          - Start at the top of your head.
          - Move attention slowly down to your toes.
        why_it_helps: Noticing sensation can make tension easier to meet.
        duration_minutes: 5
        intensity: low
        avoid_when: []
      - id: morning-pages
        name: Morning Pages
        category: Journaling
        labels:
          - clarity
        best_for:
          - crowded thoughts
        keywords:
          - write
          - journal
        summary: A stream-of-consciousness writing practice.
        steps:
          - Open a notebook.
          - Write without editing for the full time.
        why_it_helps: Letting thoughts move onto the page can create more room inside.
        duration_minutes: 10
        intensity: medium
        avoid_when: []
      - id: stretch-break
        name: Stretch Break
        category: Movement
        labels:
          - tension
        best_for:
          - stiffness
        keywords:
          - stretch
          - move
        summary: A short reset for stiffness.
        steps:
          - Stand up.
          - Roll your shoulders and stretch gently.
        why_it_helps: Changing posture can shift both body tension and attention.
        duration_minutes: 3
        intensity: low
        avoid_when:
          - sharp pain
    """

    static func setupPractices() {
        Practice.all = try! Practice.load(from: defaultPracticeYAML)
    }
}
