//
//  Untitled.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 9/7/25.
//
import UIKit

class ImageCache {

    static let cache: URLCache = {
        let diskPath = "unsplash"

        if #available(iOS 13.0, *) {
            let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let cacheURL = cachesDirectory.appendingPathComponent(diskPath, isDirectory: true)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                directory: cacheURL
            )
        } else {
            #if !targetEnvironment(macCatalyst)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                diskPath: diskPath
            )
            #else
            fatalError()
            #endif
        }
    }()

    static let memoryCapacity: Int = 50.megabytes
    static let diskCapacity: Int = 100.megabytes

}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}

