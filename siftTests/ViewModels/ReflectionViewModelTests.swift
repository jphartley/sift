import Testing
@testable import sift

struct ReflectionViewModelTests {

    // MARK: - wasHelpfulForSave

    @Test func wasHelpfulIsNilWithNoSelection() {
        let vm = ReflectionViewModel()
        #expect(vm.wasHelpfulForSave == nil)
    }

    @Test func helpedMapsToTrue() {
        let vm = ReflectionViewModel()
        vm.selectedHelpfulness = .helped
        #expect(vm.wasHelpfulForSave == true)
    }

    @Test func aLittleMapsToNilNotFalse() {
        // "A little" is intentionally nil, not false — it means unrated, not unhelpful
        let vm = ReflectionViewModel()
        vm.selectedHelpfulness = .aLittle
        #expect(vm.wasHelpfulForSave == nil)
    }

    @Test func notReallyMapsToFalse() {
        let vm = ReflectionViewModel()
        vm.selectedHelpfulness = .notReally
        #expect(vm.wasHelpfulForSave == false)
    }

    @Test func selectionCanBeChanged() {
        let vm = ReflectionViewModel()
        vm.selectedHelpfulness = .helped
        vm.selectedHelpfulness = .notReally
        #expect(vm.wasHelpfulForSave == false)
    }

    // MARK: - notesForSave

    @Test func emptyNotesProducesNil() {
        let vm = ReflectionViewModel()
        #expect(vm.notesForSave == nil)
    }

    @Test func nonEmptyNotesPassThrough() {
        let vm = ReflectionViewModel()
        vm.notes = "Felt calmer after"
        #expect(vm.notesForSave == "Felt calmer after")
    }

    @Test func whitespaceOnlyNotesPassThrough() {
        // No trimming — only empty string becomes nil
        let vm = ReflectionViewModel()
        vm.notes = "   "
        #expect(vm.notesForSave == "   ")
    }
}
