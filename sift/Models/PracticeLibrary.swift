import Foundation

struct Practice: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let category: String
    let keywords: [String]
    let description: String
    let durationMinutes: Int

    static let all: [Practice] = [
        Practice(
            id: "box-breathing",
            name: "Box Breathing",
            category: "Breathwork",
            keywords: ["breath", "breathing", "anxious", "calm", "stress", "anxiety", "nervous"],
            description: "Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. Repeat 4 times.",
            durationMinutes: 3
        ),
        Practice(
            id: "478-breathing",
            name: "4-7-8 Breathing",
            category: "Breathwork",
            keywords: ["breath", "breathing", "sleep", "calm", "restless", "wind down", "can't sleep"],
            description: "Inhale for 4 seconds, hold for 7, exhale for 8. Repeat 3–5 times.",
            durationMinutes: 3
        ),
        Practice(
            id: "body-scan",
            name: "Body Scan",
            category: "Sensory",
            keywords: ["body", "scan", "tension", "physical", "tight", "ache", "pain", "sore", "stiff"],
            description: "Slowly move attention from head to toes, noticing sensations without judgment.",
            durationMinutes: 5
        ),
        Practice(
            id: "short-walk",
            name: "5-Minute Walk",
            category: "Movement",
            keywords: ["walk", "move", "outside", "fresh air", "stuck", "restless", "sit", "sitting", "desk"],
            description: "Step outside for a short walk with no destination. Notice the air and light.",
            durationMinutes: 5
        ),
        Practice(
            id: "morning-pages",
            name: "Morning Pages",
            category: "Journaling",
            keywords: ["write", "journal", "thoughts", "clear", "overwhelm", "brain dump", "racing", "mind"],
            description: "Write 3 pages of stream-of-consciousness. Don't edit — just move the pen.",
            durationMinutes: 10
        ),
        Practice(
            id: "gratitude-list",
            name: "Gratitude List",
            category: "Journaling",
            keywords: ["grateful", "gratitude", "appreciate", "positive", "thankful", "good things", "blessing"],
            description: "Write down 3 things you're grateful for right now. Be specific.",
            durationMinutes: 3
        ),
        Practice(
            id: "call-friend",
            name: "Call a Friend",
            category: "Social",
            keywords: ["call", "friend", "talk", "lonely", "connect", "alone", "someone", "isolated", "miss"],
            description: "Call or text someone you trust. You don't need a reason.",
            durationMinutes: 10
        ),
        Practice(
            id: "grounding-54321",
            name: "5-4-3-2-1 Grounding",
            category: "Sensory",
            keywords: ["ground", "senses", "present", "anxious", "spinning", "panic", "scattered", "unreal"],
            description: "Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste.",
            durationMinutes: 3
        ),
        Practice(
            id: "progressive-relaxation",
            name: "Progressive Muscle Relaxation",
            category: "Sensory",
            keywords: ["relax", "muscle", "tension", "unwind", "tight", "clench", "stress", "body"],
            description: "Tense each muscle group for 5 seconds, then release. Work from feet to face.",
            durationMinutes: 7
        ),
        Practice(
            id: "stretch-break",
            name: "Stretch Break",
            category: "Movement",
            keywords: ["stretch", "move", "stiff", "sitting", "desk", "body", "back", "neck", "shoulder"],
            description: "Stand up and stretch — reach high, touch toes, roll shoulders and neck.",
            durationMinutes: 3
        )
    ]

    static func match(transcript: String) -> [(practice: Practice, score: Int)] {
        let words = transcript.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let wordSet = Set(words.filter { $0.count > 2 })

        return all.map { practice in
            let matchCount = practice.keywords.reduce(0) { count, keyword in
                let keywordWords = Set(keyword.lowercased().components(separatedBy: .whitespacesAndNewlines))
                let hits = keywordWords.intersection(wordSet).count
                return count + hits
            }
            return (practice, matchCount)
        }
        .sorted { $0.score > $1.score }
    }
}
