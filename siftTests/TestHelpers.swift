import Foundation
import SwiftData
@testable import sift

enum TestHelpers {
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Session.self, PracticeAttempt.self, MetricEvent.self, UserPracticeProfile.self])
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
        evidence:
          research_backed: true
          notes: Breathing regulation has explicit stress and arousal research grounding.
          tags:
            - breathing
            - arousal-regulation
        matching:
          family: breathwork
          worldview: secular
          body_focused: false
          closed_eye: false
          breath_focused: true
          devotional: false
          intense: false
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
        evidence:
          research_backed: true
          notes: Body awareness practices have explicit mindfulness research grounding.
          tags:
            - mindfulness
            - body-awareness
        matching:
          family: grounding
          worldview: secular
          body_focused: true
          closed_eye: false
          breath_focused: false
          devotional: false
          intense: false
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
        evidence:
          research_backed: false
          notes: Useful expressive writing lineage, but no explicit grounding for this exact catalogue variant.
          tags:
            - journaling
        matching:
          family: journaling
          worldview: secular
          body_focused: false
          closed_eye: false
          breath_focused: false
          devotional: false
          intense: false
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
        evidence:
          research_backed: true
          notes: Movement breaks have explicit wellbeing and tension-reduction grounding.
          tags:
            - movement
            - tension
        matching:
          family: yoga-or-movement
          worldview: secular
          body_focused: true
          closed_eye: false
          breath_focused: false
          devotional: false
          intense: false
    """

    static func setupPractices() {
        Practice.all = try! Practice.load(from: defaultPracticeYAML)
    }
}
