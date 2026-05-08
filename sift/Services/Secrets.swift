import Foundation

enum Secrets {
    static var geminiApiKey: String {
        geminiApiKey(in: .main)
    }

    static func geminiApiKey(in bundle: Bundle) -> String {
        guard let url = bundle.url(forResource: "GeminiAPIKey", withExtension: "local"),
              let key = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }

        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
