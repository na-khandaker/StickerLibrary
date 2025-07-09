//
//  NetworkingConstants.swift
//  StickerMakerNew4.0
//
//  Created by Bcl Device 13 on 3/6/24.
//

import Foundation

class NetworkConstants {
    static let baseUrl = "http://api.sticker-maker.com/"
    static let userName = "7liAmLyJLU05u4Dfy9CYKpXWqXaFtMD6EU6d2uGfgB2qi7"
    static let password = "54jdKKFG8u9JwACVbLbHk5GsT8h5nckaMGeQEntV8zRdFIRxYHeIO"
    static var assetBaseUrl = "https://static.stickermakerpro.com/"
    static let webStickerBaseUrl = "http://api.sticker-maker.com/"
    struct API {
        static let landingPageLayout = "item/get-category-and-items"
        static let getStickerImage = "%@items/%@/%@"
        static let getStickerPack = "%@items/%@/main.zip"
        static let searchPack = "item/search"
        static let getCategoryListThumb = "%@category-thumbs/%@"
        static let getAllItemsByCategoryId = "item/category/%@"
        static let getWebUserSticker = "item/%@/stickers/web-user"
        static let getCategories = "item/get-categories"
    }
}

public enum RequestMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}
