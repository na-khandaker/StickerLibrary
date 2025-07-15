//
//  StickerPackResponse.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 14/5/24.
//

import Foundation

// MARK: - StickerPackResponse
struct StickerPackResponse: Codable {
    let status: Int?
    let assetBaseURL: String?
    let items: [StickerItem]?
    let nextPage: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case assetBaseURL = "assetBaseUrl"
        case items, nextPage
    }
}

// MARK: - Item
struct StickerItem: Codable {
    let id, name: String?
    let thumbBgColor: ThumbBgColor?
    let weight, version: Int?
    let active, isPro, activeForIos, activeForAndroid: Bool?
    let stickers: [String]?
    let totalStickers: Int?
    let code, thumb: String?
    let isAnimated: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, thumbBgColor, weight, version, active, isPro, activeForIos, activeForAndroid, stickers, totalStickers, code, thumb, isAnimated
    }
}

enum ThumbBgColor: String, Codable {
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
