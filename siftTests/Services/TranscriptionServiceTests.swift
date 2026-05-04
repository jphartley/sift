import Testing
@testable import sift

struct TranscriptionServiceTests {

    @Test func modelNotLoadedErrorDescriptionNonEmpty() async {
        let error = TranscriptionError.modelNotLoaded
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test func fileNotFoundErrorDescriptionNonEmpty() async {
        let error = TranscriptionError.fileNotFound
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test func modelStateEquality() async {
        #expect(ModelState.notLoaded == ModelState.notLoaded)
        #expect(ModelState.ready == ModelState.ready)
        #expect(ModelState.notLoaded != ModelState.ready)
    }

    @Test func failedStateWithMessage() async {
        let a = ModelState.failed("error 1")
        let b = ModelState.failed("error 1")
        let c = ModelState.failed("error 2")
        #expect(a == b)
        #expect(a != c)
    }
}
