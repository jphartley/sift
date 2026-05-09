import Foundation
import Testing

struct GeminiLoggingTests {
    @Test func geminiLoggingDoesNotPrintRawPromptOrResponseText() throws {
        let source = try String(contentsOf: geminiRecommendationRouterSourceURL(), encoding: .utf8)
        let printLines = source
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.contains("print(") }
            .joined(separator: "\n")

        #expect(!printLines.contains("Partial response text"))
        #expect(!printLines.contains("response.text"))
        #expect(!printLines.contains("\\(prompt)"))
        #expect(!printLines.contains("transcript"))
        #expect(printLines.contains("modelName"))
    }

    private func geminiRecommendationRouterSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("sift/Services/GeminiRecommendationRouter.swift")
    }
}
