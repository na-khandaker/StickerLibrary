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
        var offset: Int
        var totalCount: Int? = nil
    }

    // MARK: - Properties
    private let apiService: GiphyAPIService = .shared
    private var cancellables = Set<AnyCancellable>()
    private var currentRequest: AnyCancellable?
    private var offset: Int = 0

    private var latestComplete: (([GiphyGIFModel]) -> Void)?
    private var latestError: ((String) -> Void)?

    @Published private var fetchTrigger: FetchState?
    private var searchItem : FetchState?
    
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

    func setSearch(key : String,type : GIFType = .sticker,offest : Int, totalCount : Int){
        self.fetchTrigger = nil
        self.searchItem = .init(keyword: key, type: type, isNextPage: true, offset: offset,totalCount: totalCount)
    }
    
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
        type: GIFType = .sticker,
        isNext: Bool = false,
        offset: Int = 0,
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        fetchTrigger = FetchState(keyword: "", type: type, isNextPage: isNext, offset: offset)
    }

    func searchGiphy(
        searchKeyWord: String,
        type: GIFType = .sticker,
        isNext: Bool = false,
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        fetchTrigger = FetchState(keyword: searchKeyWord, type: type, isNextPage: isNext, offset: 0)
    }
    
    func nextPage(
        complete: @escaping ([GiphyGIFModel]) -> Void,
        error: @escaping (String) -> Void
    ) {
        latestComplete = complete
        latestError = error
        if let last = fetchTrigger{
            fetchTrigger = FetchState(keyword: last.keyword, type: last.type, isNextPage: true, offset: last.offset)
        }else{
            self.fetchTrigger = self.searchItem
        }
       
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

                let newOffset = (result.pagination?.offset ?? 0) + (result.pagination?.count ?? 0)
                self.offset = newOffset
//                self.fetchTrigger?.offset = newOffset
//                self.fetchTrigger?.totalCount = result.pagination?.totalCount

                let validGIFs = data.filter { $0.images?.previewGIF != nil }
                self.latestComplete?(validGIFs)
            })
    }   

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

    func batchRequest(infoList: [GiphyCategory], complete: @escaping ([GiphyInfoModel]) -> Void) {
        var resultArray: [GiphyInfoModel] = infoList.map { gc in
            return .init(category: gc)
        }
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3

        let group: DispatchGroup = DispatchGroup()
        let task: DispatchQueue = .init(label: "giphy.category.batch", qos: .userInitiated)

        for i in 0..<infoList.count {
            let model = infoList[i]
            group.enter()
            task.async {
                let op = BlockOperation {
                    self.fetchCategory(category: model) { info in
                        resultArray[i] = info
                        group.leave()
                    } error: { error in
                        print(error)
                        group.leave()
                    }
                }
                operationQueue.addOperation(op)
            }
        }

        group.notify(queue: .main) {
            complete(resultArray)
            print("complete", resultArray)
        }
    }

    private func fetchCategory(category: GiphyCategory, complete: @escaping (GiphyInfoModel) -> Void, error: @escaping (String) -> Void) {
        apiService.fetchDateFromCategory(category: category)
            .sink(receiveCompletion: { completionResult in
                if case let .failure(err) = completionResult {
                    error(err.localizedDescription)
                }
            }, receiveValue: { result in
                let offset = (result.pagination?.offset ?? 0) + (result.pagination?.count ?? 0)
                let cat = GiphyInfoModel(
                    category: category,
                    items: result.data,
                    offset: offset,
                    totalCount: result.pagination?.totalCount ?? 0
                )
                complete(cat)
            })
            .store(in: &cancellables)
    }
}
