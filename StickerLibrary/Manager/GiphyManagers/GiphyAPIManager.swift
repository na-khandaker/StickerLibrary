import Combine
import Foundation
@available(iOSApplicationExtension 13.0, *)
final class GiphyAPIManager {
    
    // MARK: - Singleton
    static let shared = GiphyAPIManager()
    private init() {
        setupBindings()
    }
    
    // MARK: - Types
    private struct FetchState: Equatable {
        let keyword: String
        let type: GIFType
        let isNextPage: Bool
    }

    // MARK: - Properties
    private let apiService: GiphyAPIService = .shared
    private var cancellables = Set<AnyCancellable>()
    private var currentRequest: AnyCancellable?
    
    private var offset: Int = 0
    
    private var latestComplete: (([GiphyGIFModel]) -> Void)?
    private var latestError: ((String) -> Void)?
    
    @Published private var fetchTrigger: FetchState?
    
    // MARK: - Binding Setup
    private func setupBindings() {
        $fetchTrigger
            .compactMap { $0 }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] state in
                self?.performFetch(for: state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    func fetchTrendingSearchesKeywords(
        complete: @escaping ([String]) -> Void,
        error: @escaping (String) -> Void
    ) {
        apiService.fetchTrendingSearchesKeywords()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    error(err.localizedDescription)
                }
            }, receiveValue: { result in
                complete(result.data ?? [])
            })
            .store(in: &cancellables)
    }
    
    func fetchTrendingGiphy(
        type: GIFType = .gif,
        isNext: Bool = false,
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        fetchTrigger = FetchState(keyword: "", type: type, isNextPage: isNext)
    }
    
    func searchGiphy(
        searchKeyWord: String,
        type: GIFType = .gif,
        isNext: Bool = false,
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        fetchTrigger = FetchState(keyword: searchKeyWord, type: type, isNextPage: isNext)
    }
    
    func nextPage(
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        
        guard let last = fetchTrigger else {
            error("No previous search or trending context")
            return
        }
        
        fetchTrigger = FetchState(keyword: last.keyword, type: last.type, isNextPage: true)
    }

    // MARK: - Request Cancellation
    
    func cancelCurrentRequest() {
        currentRequest?.cancel()
        currentRequest = nil
    }
    
    func reset() {
        cancelCurrentRequest()
        offset = 0
        latestComplete = nil
        latestError = nil
        fetchTrigger = nil
    }

    // MARK: - Private

    private func performFetch(for state: FetchState) {
        // Cancel any ongoing request before starting a new one
        cancelCurrentRequest()
        
        if !state.isNextPage {
            self.offset = 0
        }
        
        apiService.gifType = state.type
        
        let publisher: AnyPublisher<GiphyResponseModel<GiphyGIFModel>, Error> = {
            if state.keyword.isEmpty {
                return apiService.fetchTrendingGIFS(offset: offset)
            } else {
                return apiService.fetchBySearch(keyword: state.keyword, offset: offset)
            }
        }()
        
        currentRequest = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.currentRequest = nil
                
                if case let .failure(err) = completion {
                    // Don't report error if the request was cancelled
                    if (err as? URLError)?.code != .cancelled {
                        self.latestError?(err.localizedDescription)
                    }
                }
            }, receiveValue: { [weak self] result in
                guard let self else { return }
                guard let data = result.data else {
                    self.latestError?("Invalid data")
                    return
                }
                
                self.offset = (result.pagination?.offset ?? 0) + (result.pagination?.count ?? 0)
                let validGIFs = data.filter { $0.images?.previewGIF != nil }
                self.latestComplete?(validGIFs)
            })
    }
    
//    @available(iOSApplicationExtension 13.0, *)
//    func fetchGIFCategories(
//        complete: @escaping ([GiphyCategory]) -> Void,
//        error: @escaping (String) -> Void
//    ) {
//        apiService.fetchGIFCategories()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completionResult in
//                if case let .failure(err) = completionResult {
//                    error(err.localizedDescription)
//                }
//            }, receiveValue: { result in
//                complete(result.data ?? [])
//            })
//            .store(in: &cancellables)
//    }

    
    @available(iOSApplicationExtension 13.0, *)
    func fetchGIFCategories(
        complete: @escaping ([GiphyCategory]) -> Void,
        error: @escaping (String) -> Void
    ) {
        apiService.fetchGIFCategories()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                if case let .failure(err) = completionResult {
                    error(err.localizedDescription)
                }
            }, receiveValue: { result in
                let categories = result.data ?? []
                
                // Encode and store in UserDefaults
                do {
                    let encoded = try JSONEncoder().encode(categories)
                    UserDefaults.standard.set(encoded, forKey: "GIF_CATEGORIES")
                } catch {
                    print("Failed to encode categories:", error)
                }
                
                complete(categories)
            })
            .store(in: &cancellables)
    }

}
