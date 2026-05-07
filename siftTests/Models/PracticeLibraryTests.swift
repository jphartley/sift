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
            description: A test practice description.
            duration_minutes: 5
        """
        let practices = try Practice.load(from: yaml)
        #expect(practices.count == 1)
        let p = practices[0]
        #expect(p.id == "test-practice")
        #expect(p.name == "Test Practice")
        #expect(p.category == "Test")
        #expect(p.keywords == ["test", "example"])
        #expect(p.description == "A test practice description.")
        #expect(p.durationMinutes == 5)
    }

    @Test func ignoresUnknownKeys() throws {
        let yaml = """
        practices:
          - id: extra-keys
            name: Extra Keys
            category: Test
            keywords:
              - test
            description: Has extra fields.
            duration_minutes: 2
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
            description: Duration is a string.
            duration_minutes: "not_a_number"
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
            description: First practice.
            duration_minutes: 1
          - id: second
            name: Second
            category: B
            keywords:
              - two
            description: Second practice.
            duration_minutes: 2
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
        #expect(practices.count >= 10)
    }
}
