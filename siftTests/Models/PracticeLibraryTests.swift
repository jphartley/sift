import Foundation
import Testing
@testable import sift

struct PracticeLibraryTests {

    init() {
        TestHelpers.setupPractices()
    }

    @Test func allPracticesHaveUniqueIDs() async {
        let ids = Practice.all.map(\.id)
        #expect(Set(ids).count == Practice.all.count)
    }

    @Test func allPracticesHaveNonEmptyKeywords() async {
        for practice in Practice.all {
            #expect(!practice.keywords.isEmpty)
        }
    }

    @Test func allPracticesHaveNonEmptyMetadata() async {
        for practice in Practice.all {
            #expect(!practice.labels.isEmpty)
            #expect(!practice.bestFor.isEmpty)
            #expect(!practice.summary.isEmpty)
            #expect(!practice.steps.isEmpty)
            #expect(!practice.whyItHelps.isEmpty)
            #expect(!practice.intensity.isEmpty)
        }
    }

    @Test func allPracticesHavePositiveDuration() async {
        for practice in Practice.all {
            #expect(practice.durationMinutes > 0)
        }
    }

    @Test func decodesValidPractice() throws {
        let yaml = """
        practices:
          - id: test-practice
            name: Test Practice
            category: Test
            keywords:
              - test
              - example
            labels:
              - calm
            best_for:
              - testing the loader
            summary: A test practice summary.
            steps:
              - Try the test step.
            why_it_helps: It verifies richer practice metadata.
            duration_minutes: 5
            intensity: low
            avoid_when:
              - never
            evidence:
              research_backed: true
              notes: Test evidence note.
              tags:
                - test
            matching:
              family: grounding
              worldview: secular
              body_focused: false
              closed_eye: false
              breath_focused: false
              devotional: false
              intense: false
        """
        let practices = try Practice.load(from: yaml)
        #expect(practices.count == 1)
        let p = practices[0]
        #expect(p.id == "test-practice")
        #expect(p.name == "Test Practice")
        #expect(p.category == "Test")
        #expect(p.keywords == ["test", "example"])
        #expect(p.labels == ["calm"])
        #expect(p.bestFor == ["testing the loader"])
        #expect(p.summary == "A test practice summary.")
        #expect(p.steps == ["Try the test step."])
        #expect(p.whyItHelps == "It verifies richer practice metadata.")
        #expect(p.durationMinutes == 5)
        #expect(p.intensity == "low")
        #expect(p.avoidWhen == ["never"])
        #expect(p.evidence.researchBacked)
        #expect(p.evidence.notes == "Test evidence note.")
        #expect(p.evidence.tags == ["test"])
        #expect(p.matching.family == "grounding")
        #expect(p.matching.worldview == "secular")
        #expect(!p.matching.bodyFocused)
        #expect(!p.matching.closedEye)
        #expect(!p.matching.breathFocused)
        #expect(!p.matching.devotional)
        #expect(!p.matching.intense)
    }

    @Test func ignoresUnknownKeys() throws {
        let yaml = """
        practices:
          - id: extra-keys
            name: Extra Keys
            category: Test
            keywords:
              - test
            labels:
              - calm
            best_for:
              - loader checks
            summary: Has extra fields.
            steps:
              - Decode this.
            why_it_helps: It keeps decoding resilient.
            duration_minutes: 2
            intensity: low
            avoid_when: []
            evidence:
              research_backed: true
              notes: Test evidence note.
              tags:
                - test
            matching:
              family: grounding
              worldview: secular
              body_focused: false
              closed_eye: false
              breath_focused: false
              devotional: false
              intense: false
            unknown_field: ignored
            another_unknown: also_ignored
        """
        let practices = try Practice.load(from: yaml)
        #expect(practices.count == 1)
        #expect(practices[0].id == "extra-keys")
    }

    @Test func malformedYAMLThrowsError() {
        let yaml = """
        practices:
          - id: missing-name
            category: Test
            keywords: [test]
        """
        #expect(throws: (any Error).self) {
            try Practice.load(from: yaml)
        }
    }

    @Test func invalidTypeThrowsError() {
        let yaml = """
        practices:
          - id: wrong-type
            name: Wrong Type
            category: Test
            keywords:
              - test
            labels:
              - calm
            best_for:
              - invalid decoding
            summary: Duration is a string.
            steps:
              - Decode this.
            why_it_helps: It should throw.
            duration_minutes: "not_a_number"
            intensity: low
            avoid_when: []
            evidence:
              research_backed: true
              notes: Test evidence note.
              tags:
                - test
            matching:
              family: grounding
              worldview: secular
              body_focused: false
              closed_eye: false
              breath_focused: false
              devotional: false
              intense: false
        """
        #expect(throws: (any Error).self) {
            try Practice.load(from: yaml)
        }
    }

    @Test func decodesMultiplePractices() throws {
        let yaml = """
        practices:
          - id: first
            name: First
            category: A
            keywords:
              - one
            labels:
              - first
            best_for:
              - first checks
            summary: First practice.
            steps:
              - Do the first thing.
            why_it_helps: It checks ordering.
            duration_minutes: 1
            intensity: low
            avoid_when: []
            evidence:
              research_backed: true
              notes: First evidence note.
              tags:
                - first
            matching:
              family: grounding
              worldview: secular
              body_focused: false
              closed_eye: false
              breath_focused: false
              devotional: false
              intense: false
          - id: second
            name: Second
            category: B
            keywords:
              - two
            labels:
              - second
            best_for:
              - second checks
            summary: Second practice.
            steps:
              - Do the second thing.
            why_it_helps: It checks multiple decode.
            duration_minutes: 2
            intensity: low
            avoid_when: []
            evidence:
              research_backed: false
              notes: Second evidence note.
              tags:
                - second
            matching:
              family: journaling
              worldview: secular
              body_focused: false
              closed_eye: false
              breath_focused: false
              devotional: false
              intense: false
        """
        let practices = try Practice.load(from: yaml)
        #expect(practices.count == 2)
        #expect(practices[0].id == "first")
        #expect(practices[1].id == "second")
    }

    @Test func bundledYAMLDecodesCorrectly() throws {
        guard let url = Bundle.main.url(forResource: "practices", withExtension: "yaml") else {
            return
        }
        let yamlString = try String(contentsOf: url, encoding: .utf8)
        let practices = try Practice.load(from: yamlString)
        #expect(practices.count == 140)
    }

    @Test func bundledYAMLIncludesExpandedCategoryCoverage() throws {
        guard let url = Bundle.main.url(forResource: "practices", withExtension: "yaml") else {
            return
        }
        let yamlString = try String(contentsOf: url, encoding: .utf8)
        let practices = try Practice.load(from: yamlString)
        let categoryCounts = Dictionary(grouping: practices, by: \.category)
            .mapValues(\.count)

        #expect(categoryCounts["Breathwork"] == 14)
        #expect(categoryCounts["Meditation"] == 12)
        #expect(categoryCounts["Grounding"] == 6)
        #expect(categoryCounts["Movement"] == 10)
        #expect(categoryCounts["Journaling"] == 12)
        #expect(categoryCounts["Emotional Processing"] == 9)
        #expect(categoryCounts["Social Connection"] == 12)
        #expect(categoryCounts["Nature"] == 10)
        #expect(categoryCounts["Creative Expression"] == 11)
        #expect(categoryCounts["Practical Care"] == 10)
        #expect(categoryCounts["Sleep & Wind-Down"] == 12)
        #expect(categoryCounts["Self-Compassion"] == 7)
        #expect(categoryCounts["Values & Intention"] == 7)
        #expect(categoryCounts["Spiritual / Contemplative"] == 8)
    }

    @Test func allPracticesHaveExplicitEvidenceMetadata() async {
        let researchBackedValues = Set(Practice.all.map(\.evidence.researchBacked))
        for practice in Practice.all {
            #expect(!practice.evidence.notes.isEmpty)
            #expect(!practice.evidence.tags.isEmpty)
        }
        #expect(researchBackedValues.contains(true))
        #expect(researchBackedValues.contains(false))
    }

    @Test func allPracticesHaveExplicitMatchingMetadata() async {
        for practice in Practice.all {
            #expect(!practice.matching.family.isEmpty)
            #expect(!practice.matching.worldview.isEmpty)
            #expect(["low", "medium", "high"].contains(practice.intensity))
            if practice.intensity == "high" {
                #expect(practice.matching.intense)
            }
        }
    }
}
