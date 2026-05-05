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
        #expect(ModelState.loading == ModelState.loading)
        #expect(ModelState.loading != ModelState.ready)
    }

    @Test func downloadingProgressEquality() async {
        #expect(ModelState.downloading(progress: 0.5) == ModelState.downloading(progress: 0.5))
        #expect(ModelState.downloading(progress: 0.0) != ModelState.downloading(progress: 0.5))
        #expect(ModelState.downloading(progress: 0.3) != ModelState.downloading(progress: 0.7))
    }

    @Test func downloadingStateNotEqualToOtherStates() async {
        #expect(ModelState.downloading(progress: 0.5) != ModelState.notLoaded)
        #expect(ModelState.downloading(progress: 0.5) != ModelState.loading)
        #expect(ModelState.downloading(progress: 0.5) != ModelState.ready)
    }

    @Test func failedStateWithMessage() async {
        let a = ModelState.failed("error 1")
        let b = ModelState.failed("error 1")
        let c = ModelState.failed("error 2")
        #expect(a == b)
        #expect(a != c)
    }

    @Test func loadModelIdempotentWhenAlreadyReady() async {
        let service = TranscriptionService()
        service.modelState = .ready

        await service.loadModel()

        #expect(service.modelState == .ready)
    }

    @Test func loadModelIdempotentWhenAlreadyDownloading() async {
        let service = TranscriptionService()
        service.modelState = .downloading(progress: 0.5)

        await service.loadModel()

        #expect(service.modelState == .downloading(progress: 0.5))
    }

    @Test func loadModelIdempotentWhenAlreadyLoading() async {
        let service = TranscriptionService()
        service.modelState = .loading

        await service.loadModel()

        #expect(service.modelState == .loading)
    }
}
