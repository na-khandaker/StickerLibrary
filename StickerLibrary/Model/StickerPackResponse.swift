//
//  StickerPackResponse.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 14/5/24.
//

import Foundation

// MARK: - StickerPackResponse
struct StickerPackResponse: Codable {
    let status: Int
    let assetBaseURL: String
    let items: [StickerItem]
    let nextPage: Int

    enum CodingKeys: String, CodingKey {
        case status
        case assetBaseURL = "assetBaseUrl"
        case items, nextPage
    }
}

// MARK: - Item
struct StickerItem: Codable {
    let id, name: String
    let thumbBgColor: ThumbBgColor?
    let isAnimated, isPro: Bool
    let code: String
    let stickers: [String]
    let totalStickers, version: Int
    let thumb: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, thumbBgColor, isAnimated, isPro, code, stickers, totalStickers, version, thumb
    }
}
enum ThumbBgColor: String, Codable {
    case b11616 = "#b11616"
    case bf4F4F = "#bf4f4f"
    case the000000 = "#000000"
}

var GiphyInfo = [GiphyInfoModel]()

struct GiphyInfoModel {
    
    var category: GiphyCategory
    var items: [GiphyGIFModel]?
    var offset : Int = 0
    var totalCount : Int = 0
    init(category: GiphyCategory, items: [GiphyGIFModel]? = nil, offset: Int = 0, totalCount: Int = 0) {
        self.category = category
        self.items = items
        self.offset = offset
        self.totalCount = totalCount
    }

    
}
