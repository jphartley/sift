import Testing
@testable import sift

struct PracticeLibraryTests {

    @Test func matchEmptyTranscriptReturnsAllWithZeroScore() async {
        let results = Practice.match(transcript: "")
        #expect(results.count == Practice.all.count)
        for (_, score) in results {
            #expect(score == 0)
        }
    }

    @Test func singleKeywordMatch() async {
        let results = Practice.match(transcript: "breath")
        let topTwo = results.prefix(2).map(\.practice.name)
        #expect(topTwo.contains("Box Breathing"))
        #expect(topTwo.contains("4-7-8 Breathing"))
        #expect(results.first?.score ?? 0 > 0)
    }

    @Test func shortWordsAreIgnored() async {
        let results = Practice.match(transcript: "a an in it")
        for (_, score) in results {
            #expect(score == 0)
        }
    }

    @Test func compoundScoring() async {
        let results = Practice.match(transcript: "anxious stressed tense")
        #expect(results.first?.score ?? 0 >= 1)
        let topScore = results.first?.score ?? 0
        let topGroup = results.filter { $0.score == topScore }
        let bottomGroup = results.filter { $0.score < topScore && $0.score > 0 }
        #expect(topGroup.count <= bottomGroup.count || bottomGroup.isEmpty)
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
}
