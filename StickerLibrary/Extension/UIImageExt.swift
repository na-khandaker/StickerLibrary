//
//  UIImageExt.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 9/7/25.
//

import UIKit

extension UIImage {

    func preloadedImage() -> UIImage {
        guard let imageRef = self.cgImage else {
            return self
        }
        let width = imageRef.width
        let height = imageRef.height
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        guard let imageContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colourSpace, bitmapInfo: bitmapInfo) else {
            return self //failed
        }
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        imageContext.draw(imageRef, in: rect)
        if let outputImage = imageContext.makeImage() {
            let cachedImage = UIImage(cgImage: outputImage, scale: scale, orientation: imageOrientation)
            return cachedImage
        }
        return self
    }

}

extension UIImage{
    
    //creates a UIImage given a UIColor
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1),scale : CGFloat = UIScreen.main.scale) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
