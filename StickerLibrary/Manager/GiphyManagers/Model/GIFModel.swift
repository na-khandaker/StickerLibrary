//
//  GIFModel.swift
//  GIF Maker Pro
//
//  Created by BCL Device 22 on 20/1/25.
//

import Foundation

struct GIFModel : GIFModelProtocol{
    
    var id: String?
    
    var type: GIFType?
    
    var name: String?
    
    var tag: String?
    
    var orginalURL: String?
    
    var thumbURL: String?
    
    var gifURL: String?
    
    var webpURL: String?
    
    var mp4URL: String?
    
    var height: String?
    
    var width: String?
    
    var isFavourite: Bool? = false
    
    var hasAudio: Bool?
    
    var duration: Double?
    
    var source: String?
    
    var contentSource: ContentSource?
    
    var isPro : Bool = false
    
    init(){
        self.id = UUID().uuidString
        self.contentSource = .sticker
    }
    
    init(giphy : GiphyGIFModel){
        self.id = giphy.id
        
        self.type = giphy.type
        
        self.name = giphy.title
        
        self.tag = giphy.animatedTextStyle
        
        self.orginalURL = giphy.images?.original?.url
        
        self.thumbURL = giphy.images?.previewGIF?.url
        
        self.gifURL = giphy.images?.previewGIF?.url
        
        self.mp4URL = giphy.images?.original?.mp4
        
        self.webpURL = giphy.images?.original?.webp
        
        self.height = giphy.images?.previewWebp?.height
        
        self.width = giphy.images?.previewWebp?.width
        
        self.hasAudio = false
        
        self.duration = 0.0
        
        self.source = giphy.source
        
        self.contentSource = .giphy
    }
    
//    init(with tenor : TenorGIF){
//        self.id = tenor.id
//        self.type = .gif
//        self.name = tenor.title
//        self.tag = tenor.tags.first
//        self.orginalURL = tenor.getGIFurl()
//        
//        let gif = tenor.getGIF()
//        let mp4 = tenor.getMP4()
//        
//        self.gifURL = gif?.url
//        self.mp4URL = mp4?.url
//    
//        self.thumbURL = gif?.url
//        self.width = "\(gif?.dims.first ?? 0)"
//        self.height = "\(gif?.dims.last ?? 0)"
//        self.duration = gif?.duration
//        self.hasAudio = tenor.hasaudio
//        self.isFavourite = false
//        self.source = tenor.sourceID
//        
//        self.contentSource = .tenor
//    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(GIFType.self, forKey: .type)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.tag = try container.decodeIfPresent(String.self, forKey: .tag)
        self.orginalURL = try container.decodeIfPresent(String.self, forKey: .orginalURL)
        self.thumbURL = try container.decodeIfPresent(String.self, forKey: .thumbURL)
        self.gifURL = try container.decodeIfPresent(String.self, forKey: .gifURL)
        self.webpURL = try container.decodeIfPresent(String.self, forKey: .webpURL)
        self.mp4URL = try container.decodeIfPresent(String.self, forKey: .mp4URL)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.isFavourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite)
        self.hasAudio = try container.decodeIfPresent(Bool.self, forKey: .hasAudio)
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.contentSource = try container.decodeIfPresent(ContentSource.self, forKey: .contentSource)
        self.isPro = try container.decodeIfPresent(Bool.self, forKey: .isPro) ?? false
    }
    enum CodingKeys: CodingKey {
        case id
        case type
        case name
        case tag
        case orginalURL
        case thumbURL
        case gifURL
        case webpURL
        case mp4URL
        case height
        case width
        case isFavourite
        case hasAudio
        case duration
        case source
        case contentSource
        case isPro
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.tag, forKey: .tag)
        try container.encodeIfPresent(self.orginalURL, forKey: .orginalURL)
        try container.encodeIfPresent(self.thumbURL, forKey: .thumbURL)
        try container.encodeIfPresent(self.gifURL, forKey: .gifURL)
        try container.encodeIfPresent(self.webpURL, forKey: .webpURL)
        try container.encodeIfPresent(self.mp4URL, forKey: .mp4URL)
        try container.encodeIfPresent(self.height, forKey: .height)
        try container.encodeIfPresent(self.width, forKey: .width)
        try container.encodeIfPresent(self.isFavourite, forKey: .isFavourite)
        try container.encodeIfPresent(self.hasAudio, forKey: .hasAudio)
        try container.encodeIfPresent(self.duration, forKey: .duration)
        try container.encodeIfPresent(self.source, forKey: .source)
        try container.encodeIfPresent(self.contentSource, forKey: .contentSource)
        try container.encodeIfPresent(self.isPro, forKey: .isPro)
    }
}
