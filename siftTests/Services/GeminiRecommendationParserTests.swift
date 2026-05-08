import Testing
@testable import sift

struct GeminiRecommendationParserTests {

    @Test func validJSONParsesRecommendationResult() throws {
        let parser = GeminiRecommendationParser()
        let result = try parser.parse(
            text: """
            {
              "rationale": "Because you mentioned stress",
              "practices": [
                {
                  "practice_id": "box-breathing",
                  "relevance": "This helps with stress"
                },
                {
                  "practice_id": "body-scan",
                  "relevance": "This helps you settle"
                }
              ],
              "confidence": 0.85
            }
            """,
            modelUsed: GeminiRecommendationRouter.flashModel,
            wasEscalated: false
        )

        #expect(result.rationale == "Because you mentioned stress")
        #expect(result.practices.count == 2)
        #expect(result.practices[0].practiceID == "box-breathing")
        #expect(result.practices[0].relevance == "This helps with stress")
        #expect(result.confidence == 0.85)
        #expect(result.modelUsed == GeminiRecommendationRouter.flashModel)
        #expect(!result.wasEscalated)
    }

    @Test func malformedJSONThrowsParseError() {
        let parser = GeminiRecommendationParser()

        expectGeminiError(.jsonParseError) {
            try parser.parse(
                text: "not json",
                modelUsed: GeminiRecommendationRouter.flashModel,
                wasEscalated: false
            )
        }
    }

    @Test func missingRequiredFieldThrowsParseError() {
        let parser = GeminiRecommendationParser()

        expectGeminiError(.jsonParseError) {
            try parser.parse(
                text: """
                {
                  "rationale": "Because",
                  "practices": [
                    {
                      "practice_id": "box-breathing",
                      "relevance": "Relevant"
                    }
                  ]
                }
                """,
                modelUsed: GeminiRecommendationRouter.flashModel,
                wasEscalated: false
            )
        }
    }

    @Test func malformedPracticeEntriesAreSkipped() throws {
        let parser = GeminiRecommendationParser()
        let result = try parser.parse(
            text: """
            {
              "rationale": "Because",
              "practices": [
                {
                  "practice_id": "missing-relevance"
                },
                {
                  "practice_id": "box-breathing",
                  "relevance": "Relevant"
                }
              ],
              "confidence": 0.75
            }
            """,
            modelUsed: GeminiRecommendationRouter.flashModel,
            wasEscalated: false
        )

        #expect(result.practices.count == 1)
        #expect(result.practices[0].practiceID == "box-breathing")
    }

    @Test func emptyPracticesThrowsEmptyPracticesError() {
        let parser = GeminiRecommendationParser()

        expectGeminiError(.emptyPractices) {
            try parser.parse(
                text: """
                {
                  "rationale": "Because",
                  "practices": [],
                  "confidence": 0.75
                }
                """,
                modelUsed: GeminiRecommendationRouter.flashModel,
                wasEscalated: false
            )
        }
    }

    @Test func allMalformedPracticesThrowsEmptyPracticesError() {
        let parser = GeminiRecommendationParser()

        expectGeminiError(.emptyPractices) {
            try parser.parse(
                text: """
                {
                  "rationale": "Because",
                  "practices": [
                    {
                      "practice_id": "missing-relevance"
                    }
                  ],
                  "confidence": 0.75
                }
                """,
                modelUsed: GeminiRecommendationRouter.flashModel,
                wasEscalated: false
            )
        }
    }

    private func expectGeminiError(
        _ expected: GeminiError,
        performing operation: () throws -> RecommendationResult
    ) {
        do {
            _ = try operation()
            Issue.record("Expected \(expected), but no error was thrown")
        } catch let error as GeminiError {
            #expect(error == expected)
        } catch {
            Issue.record("Expected \(expected), got \(error)")
        }
    }
}
