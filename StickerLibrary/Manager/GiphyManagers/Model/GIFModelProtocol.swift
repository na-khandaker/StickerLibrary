//
//  GIFModel.swift
//  GIF Maker Pro
//
//  Created by BCL Device 22 on 14/1/25.
//

import Foundation

enum ContentSource : String,Codable {
    case giphy
    case tenor
    case sticker
}

enum GIFType : String, Codable{
    case emoji
    case gif
    case sticker
    case text
}

protocol GIFModelProtocol : Codable{
    /// content iD
    var id : String? {get set}
    /// gif type sticker / text or others
    var type : GIFType? {get set}
    /// there is any name
    var name : String? { get set }
    /// if there is any tag, i would be search key or any type of tag
    var tag : String? {get set}
    /// Orginal content url
    var orginalURL : String?  { get set }
    /// Thumb url for preview , we can call this as preview url also
    var thumbURL : String? { get set }
    /// GIF url
    var gifURL : String? { get set }
    ///webp URL
    var webpURL : String? { get set }
    // MP4 url if there is any
    var mp4URL : String? { get set }
    /// content height
    var height : String? { get set}
    /// content width
    var width : String? {get set}
    /// this content is added to favourite or not
    var isFavourite : Bool? { get set }
    /// there is any audio
    var hasAudio : Bool? {get set}
    /// duration of content
    var duration : Double? {get set}
    
    var source : String? {get set}
    
    /// This content from which source, like giphy or tenor or our own
    var contentSource : ContentSource? {get set}
}
