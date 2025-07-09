//
//  GiphyAPIManager.swift
//  GifKeyboard
//
//  Created by BCL Device 22 on 26/12/24.
//

import UIKit
import Combine



enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(String)
    case custom(String)
}

class GiphyAPIService: NSObject {
    
    static let shared : GiphyAPIService = GiphyAPIService()
    
    private let API_KEY = "KNBaAN41qUQHYro70w9zkcHQJSBMshLN"
    private let BASE_URL_GIFS = "https://api.giphy.com/v1/gif"
    private let BASE_URL_STICKERS = "https://api.giphy.com/v1/sticker"
    private let BASE_URL_EMOJI = "https://api.giphy.com/v1/emoji"
    private let BASE_URL_TEXTS = "https://api.giphy.com/v1/text"
    
    private var tendingSearchKeywordURL : String{
        return "https://api.giphy.com/v1/trending/searches"
    }
    private lazy var searchByKeywordURL : (_ : String, _ : Int)-> String = {[unowned self] key,offset in
        return "\(self.CURRENT_BASE_URL)/search?q=\(key)&offset=\(offset)&api_key=\(self.API_KEY)"
    }
    
    private lazy var tendingGifsURL : (_ : Int)-> String = {[unowned self] offset in
        return "\(self.CURRENT_BASE_URL)/trending?offset=\(offset)&api_key=\(self.API_KEY)"
    }
    
    private var CURRENT_BASE_URL: String {
        switch gifType {
        case .gif: return BASE_URL_GIFS.appending("s")
        case .sticker: return BASE_URL_STICKERS.appending("s")
        case .text: return BASE_URL_TEXTS
            ///this case is not tested
            ///we can use this emoji as sticker temporary
        case .emoji: return BASE_URL_EMOJI
            
        }
    }
    
    internal var gifType : GIFType = .gif
    private var currentOffset : Int = 0
    
    @available(iOSApplicationExtension 13.0, *)
    func fetchTrendingSearchesKeywords() -> AnyPublisher<GiphyResponseModel<String>, Error> {
        // Build the URL with the API key
        guard var components = URLComponents(string: tendingSearchKeywordURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: API_KEY)
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Make the network call
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // Extract data from the response
            .decode(type: GiphyResponseModel<String>.self, decoder: JSONDecoder()) // Decode JSON
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .eraseToAnyPublisher() // Erase publisher type
    }
    
    @available(iOSApplicationExtension 13.0, *)
    func fetchTrendingGIFS(offset : Int) -> AnyPublisher<GiphyResponseModel<GiphyGIFModel>, Error> {
        // Build the URL with the API key
        guard var components = URLComponents(string: tendingGifsURL(offset)) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        //when you use queryItems you must add key value query here otherwise its not work
        components.queryItems = [
            URLQueryItem(name: "api_key", value: API_KEY),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Make the network call
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ response in
                let str = String(data: response.data, encoding: .ascii)
                print( str ?? "Invalid JSON")
            
                if let JSONString = String(data: response.data, encoding: String.Encoding.utf8) {
                    print("response json > ",JSONString)
                    UserDefaults.standard.setValue(JSONString, forKey: "TrendingGIFSKey")
                }
                return response.data
            })
            .decode(type: GiphyResponseModel<GiphyGIFModel>.self, decoder: JSONDecoder()) // Decode JSON
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .eraseToAnyPublisher() // Erase publisher type
    }
    @available(iOSApplicationExtension 13.0, *)
    func fetchBySearch(keyword : String, offset : Int) -> AnyPublisher<GiphyResponseModel<GiphyGIFModel>, Error> {
        guard let url = URL(string: searchByKeywordURL(keyword, offset)) else{
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Make the network call
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ response in
                return response.data
            })
            .decode(type: GiphyResponseModel<GiphyGIFModel>.self, decoder: JSONDecoder()) // Decode JSON
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .eraseToAnyPublisher() // Erase publisher type
    }
}
