import Foundation

enum Secrets {
    static var geminiApiKey: String {
        localGeminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static var localGeminiApiKey: String {
        #if DEBUG
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("GeminiAPIKey.local")
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        #else
        return ""
        #endif
    }
}
