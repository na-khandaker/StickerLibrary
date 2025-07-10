//
//  GiphyTendingKeywordModel.swift
//  GIF Maker Pro
//
//  Created by BCL Device 22 on 26/12/24.
//

import Foundation

// MARK: - GiphyTendingKeywordModel
struct GiphyResponseModel<T: Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let pagination: Pagination?
}

// MARK: - Meta
struct Meta: Codable {
    let status: Int
    let msg, responseID: String

    enum CodingKeys: String, CodingKey {
        case status, msg
        case responseID = "response_id"
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let totalCount, count, offset: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case count, offset
    }
}


struct GiphyCategoryResponse: Codable {
    let data: [GiphyCategory]
    let meta: Meta
    let pagination: Pagination
}

// MARK: - Datum
struct GiphyCategory: Codable {
    let name, nameEncoded: String
    let subcategories: [Subcategory]
    let gif: GiphyObject

    enum CodingKeys: String, CodingKey {
        case name
        case nameEncoded = "name_encoded"
        case subcategories, gif
    }
}

struct Subcategory: Codable {
    let name, nameEncoded: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case nameEncoded = "name_encoded"
    }
}

// MARK: - GIF
struct GiphyObject: Codable {
    let type: GIFType
    let id: String
    let url: String
    let slug: String
    let bitlyGIFURL, bitlyURL: String
    let embedURL: String
    let username: String
    let source: String
    let title: String
    let rating: Rating
    let contentURL, sourceTLD: String
    let sourcePostURL: String
    let isSticker: Int
    let importDatetime, trendingDatetime: String
    let images: GiphyImages
    let analyticsResponsePayload: String
    let analytics: Analytics
    let altText: String
    let user: User?
    let isLowContrast: Bool?

    enum CodingKeys: String, CodingKey {
        case type, id, url, slug
        case bitlyGIFURL = "bitly_gif_url"
        case bitlyURL = "bitly_url"
        case embedURL = "embed_url"
        case username, source, title, rating
        case contentURL = "content_url"
        case sourceTLD = "source_tld"
        case sourcePostURL = "source_post_url"
        case isSticker = "is_sticker"
        case importDatetime = "import_datetime"
        case trendingDatetime = "trending_datetime"
        case images
        case analyticsResponsePayload = "analytics_response_payload"
        case analytics
        case altText = "alt_text"
        case user
        case isLowContrast = "is_low_contrast"
    }
}


struct GiphyGIFModel: Codable {
    let type: GIFType?
    let id: String?
    let isDynamic: Int?
    let url: String?
    let slug: String?
    let bitlyGIFURL, bitlyURL: String?
    let embedURL: String?
    let username: String?
    let source: String?
    let title: String?
    let rating: String?
    let contentURL: String?
    let sourceTLD: String?
    let sourcePostURL: String?
    let isSticker: Int?
    let importDatetime, trendingDatetime: String?
    let images: GiphyImages?
    let user: User?
    let analyticsResponsePayload: String?
    let analytics: Analytics?
    let altText: String?
    let cta: Cta?
    let animatedTextStyle: String?

    enum CodingKeys: String, CodingKey {
        case type, id, url, slug
        case isDynamic = "is_dynamic"
        case bitlyGIFURL = "bitly_gif_url"
        case bitlyURL = "bitly_url"
        case embedURL = "embed_url"
        case username, source, title, rating
        case contentURL = "content_url"
        case sourceTLD = "source_tld"
        case sourcePostURL = "source_post_url"
        case isSticker = "is_sticker"
        case importDatetime = "import_datetime"
        case trendingDatetime = "trending_datetime"
        case images, user
        case analyticsResponsePayload = "analytics_response_payload"
        case analytics
        case altText = "alt_text"
        case cta
        case animatedTextStyle = "animated_text_style"
    }
}

enum Rating: String, Codable {
    case g = "g"
    case pg = "pg"
}


// MARK: - User
struct User: Codable {
    let avatarURL, bannerImage, bannerURL: String?
    let profileURL: String?
    let username, displayName, description: String?
    let instagramURL: String?
    let websiteURL: String?
    let isVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case bannerImage = "banner_image"
        case bannerURL = "banner_url"
        case profileURL = "profile_url"
        case username
        case displayName = "display_name"
        case description
        case instagramURL = "instagram_url"
        case websiteURL = "website_url"
        case isVerified = "is_verified"
    }
}
// MARK: - Cta
struct Cta: Codable {
    let link: String?
    let text: String?
}
// MARK: - Analytics
struct Analytics: Codable {
    let onload, onclick, onsent, onstart: Onclick?
}
// MARK: - Onclick
struct Onclick: Codable {
    let url: String?
}
// MARK: - Images
struct GiphyImages: Codable {
    let original: FixedHeight?
    let downsized, downsizedLarge, downsizedMedium: The480_WStill?
    let downsizedSmall: The4_K?
    let downsizedStill: The480_WStill?
    let fixedHeight, fixedHeightDownsampled, fixedHeightSmall: FixedHeight?
    let fixedHeightSmallStill, fixedHeightStill: The480_WStill?
    let fixedWidth, fixedWidthDownsampled, fixedWidthSmall: FixedHeight?
    let fixedWidthSmallStill, fixedWidthStill: The480_WStill?
    let looping: Looping?
    let originalStill: The480_WStill?
    let originalMp4, preview: The4_K?
    let previewGIF, previewWebp, the480WStill: The480_WStill?
    let hd, the4K: The4_K?
    let giphyMedium, giphySmall: FixedHeight?
    
    enum CodingKeys: String, CodingKey {
        case original, downsized
        case downsizedLarge = "downsized_large"
        case downsizedMedium = "downsized_medium"
        case downsizedSmall = "downsized_small"
        case downsizedStill = "downsized_still"
        case fixedHeight = "fixed_height"
        case fixedHeightDownsampled = "fixed_height_downsampled"
        case fixedHeightSmall = "fixed_height_small"
        case fixedHeightSmallStill = "fixed_height_small_still"
        case fixedHeightStill = "fixed_height_still"
        case fixedWidth = "fixed_width"
        case fixedWidthDownsampled = "fixed_width_downsampled"
        case fixedWidthSmall = "fixed_width_small"
        case fixedWidthSmallStill = "fixed_width_small_still"
        case fixedWidthStill = "fixed_width_still"
        case looping
        case originalStill = "original_still"
        case originalMp4 = "original_mp4"
        case preview
        case previewGIF = "preview_gif"
        case previewWebp = "preview_webp"
        case the480WStill = "480w_still"
        case hd
        case the4K = "4k"
        case giphyMedium = "giphy_medium"
        case giphySmall = "giphy_small"
    }
}
// MARK: - The480_WStill
struct The480_WStill: Codable {
    let url: String?
    let width, height, size: String?
}

// MARK: - The4_K
struct The4_K: Codable {
    let height, width, mp4Size: String?
    let mp4: String?

    enum CodingKeys: String, CodingKey {
        case height, width
        case mp4Size = "mp4_size"
        case mp4
    }
}

// MARK: - FixedHeight
struct FixedHeight: Codable {
    let height, width, size: String?
    let url: String?
    let mp4Size: String?
    let mp4: String?
    let webpSize: String?
    let webp: String?
    let frames, hash: String?

    enum CodingKeys: String, CodingKey {
        case height, width, size, url
        case mp4Size = "mp4_size"
        case mp4
        case webpSize = "webp_size"
        case webp, frames, hash
    }
}

// MARK: - Looping
struct Looping: Codable {
    let mp4Size: String?
    let mp4: String?

    enum CodingKeys: String, CodingKey {
        case mp4Size = "mp4_size"
        case mp4
    }
}

extension GiphyResponseModel {
    /// Returns a new instance of `GiphyResponseModel` with invalid items removed from the `data` array.
    func cleaned(requiredFields: [(T) -> Any?]) -> GiphyResponseModel {
        guard let data = data else {
            return self // Return the model as-is if the data array is nil
        }
        let filteredData = data.compactMap { item in
            // Keep the item only if all required fields are non-nil
            requiredFields.allSatisfy { $0(item) != nil } ? item : nil
        }
        return GiphyResponseModel(data: filteredData, meta: meta, pagination: pagination)
    }
}
