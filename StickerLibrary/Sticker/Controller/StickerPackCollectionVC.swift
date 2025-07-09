//
//  StickerPackCollectionVC.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 14/5/24.
//

import Foundation
import YYImage
import SVProgressHUD
import Combine
import SDWebImage

protocol StickerPackCollectionVCDelegate: AnyObject {
    
    func fetchSticker(from urls: [String])
}

class StickerPackCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemIndex = 0
    
    private var isFetchingMore = false
    private var currentPage = 0
    private let limitPerPage = 50
    var isProcessing = false
    
    var stickerItem: StickerItem?
    var type: StickerVCTypeState = .sticker
    //    var packInfo: PackInfo?
    var gifyList: [GiphyGIFModel] = []
    //
    weak var delegate: StickerPackCollectionVCDelegate?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private enum Constants {
        static let interItemSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 17.0 : 8.0
        static let lineSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 17.0 : 8.0
        static let itemsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 6.0 : 3.0
    }
    
    deinit{
        print(#function,#file,"addasdasdasda deinti")
        if collectionView != nil {
            collectionView.visibleCells.compactMap({$0 as? StickerCell}).forEach({$0.reset()})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.collectionView.showsVerticalScrollIndicator = false
        
        Reachability.shared.whenUnreachable = { [weak self] _ in
            guard let self else { return }
            if type != .giphy {
                if shouldShowNoInterNetAlert(for: type) {
                    //  BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 0.0, disappeared: nil)
                }
            }
        }
        
        if shouldShowNoInterNetAlert(for: type) && Reachability.shared.connection == .unavailable  {
            //  BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 0.0, disappeared: nil)
        }
        
        Reachability.shared.whenReachable = { [weak self] _ in
            guard let self else { return }
            if type != .giphy {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        SDImageCache.shared.config.shouldCacheImagesInMemory = true
        SDImageCache.shared.config.maxMemoryCost = 50 * 1024 * 1024
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function,#file)
    }
    
    func shouldShowNoInterNetAlert(for type: StickerVCTypeState) -> Bool {
        guard let stickerItems = stickerItem?.stickers else { return false }
        for item in stickerItems {
            guard let stickerItems = stickerItem else { return false }
            //            let url = type == .animatedSticker ? BCAssetManager.shared.bcAssetsDirectory.appendingPathComponent("Animated Stickers/\(stickerItems.code)/Main/\(item)") : SMFileManager.shared.getFileURL(for: "Stickers/\(stickerItems.code)/\(item)")!
            let url = SMFileManager.shared.getFileURL(for: "Stickers/\(stickerItems.code)/\(item)")!
            if !SMFileManager.shared.isFileExists(at: url.path) {
                return true
            }
        }
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .animatedSticker:
            return (stickerItem?.stickers.count) ?? 0
        case .sticker:
            return (stickerItem?.stickers.count) ?? 0
        case .giphy:
            return gifyList.count
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StickerCell
        if let sticker = stickerItem {
            cell.configureCell(with: sticker.code, and: sticker.stickers[indexPath.row], isAnimating: sticker.isAnimated)
        }
        else if type == .giphy {
            cell.configureCellForGIFY(with: gifyList[indexPath.row], isAnimated: true)
            print("cell load : ",indexPath.row,gifyList[indexPath.row].id)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch type {
        case .giphy:
            break
        default:
            break
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        self.view.isUserInteractionEnabled = false
        
        var stickerFileUrl: URL = URL(fileURLWithPath: "")
        if let sticker = stickerItem {
            let stickerLocalURL = SMFileManager.shared.getFileURL(for: "Stickers/\(sticker.code)/\(sticker.stickers[indexPath.row])")!
            
            if !SMFileManager.shared.isFileExists(at: stickerLocalURL.path) && Reachability.shared.connection == .unavailable {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    //  BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 0.0, disappeared: nil)
                    self.view.isUserInteractionEnabled = true
                }
                return
            }
            stickerFileUrl = stickerLocalURL
            
        }
//        else if type == .giphy, let sticker = stickerInfo[indexPath.row].sticker {
//            stickerFileUrl = SMFileManager.shared.getFilePathForGroup(with: sticker)!
//        } else {
//            SVProgressHUD.dismiss()
//            // BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 0.0, disappeared: nil)
//            self.view.isUserInteractionEnabled = true
//            return
//        }
//        var imageArray: [String] = []
//        if let data = try? Data(contentsOf: stickerFileUrl), let image = YYImage(data: data) {
//            let frameCount = Double(image.animatedImageFrameCount())
//            if frameCount > 0 {
//                let interval = frameCount > 30.0 ? ceil(frameCount / 30.0) : 1
//                let folder = FileManager.default.createFolderInTemporary(with: "stickerMaker-\(UUID().uuidString)")
//                for i in stride(from: 0, to: frameCount, by: interval) {
//                    if let frame = image.animatedImageFrame(at: UInt(i)) {
//                        let url = FileManager.default.getImageURL(for: "image_\(UUID().uuidString).png", folder: folder)
//                        do {
//                            if let resizedFrame = frame.resize512() {
//                                try resizedFrame.writePNG(to: url, shouldResize: false)
//                                imageArray.append(url.path)
//                            }
//                        } catch {
//                            print(error)
//                        }
//                    }
//                }
//            } else {
//                do {
//                    let folder = FileManager.default.createFolderInTemporary(with: "stickerMaker-\(UUID().uuidString)")
//                    let url = FileManager.default.getImageURL(for: "image_\(UUID().uuidString).png", folder: folder)
//                    try image.writePNG(to: url, shouldResize: false)
//                    imageArray = [url.path]
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        guard imageArray.count > 0 else {
//            SVProgressHUD.dismiss()
//            // BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 0.0, disappeared: nil)
//            self.view.isUserInteractionEnabled = true
//            return
//        }
//        DispatchQueue.main.async {
//            self.delegate?.fetchSticker(from: imageArray)
//        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Constants.interItemSpacing * (Constants.itemsPerRow - 1.0)
        let contentInset = collectionView.contentInset.left + collectionView.contentInset.right
        let width = ((UIScreen.main.bounds.width - contentInset - spacing) / Constants.itemsPerRow).rounded(.down)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.lineSpacing
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard type == .giphy else { return }
        
        let thresholdIndex = gifyList.count - 10
        if indexPath.row == thresholdIndex {
            nextPageGiphy()
        }
    }
    
    //    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        guard type == .myPack else { return }
    //            if collectionView == containerCollectionView,
    //                sticketItemType == .gif,
    //                indexPath.row == gifDataSource.count - 10{
    //                self.nextPageGiphy()
    //                print(#function)
    //            }
    //        }
    
    
    func nextPageGiphy(){
        guard !isProcessing else{return}
        isProcessing = true
        GiphyAPIManager.shared.nextPage{[weak self] result in
            guard let self else {return}
            let lastIndex = self.gifyList.count
            let newIndex : [IndexPath] = (lastIndex..<(lastIndex+result.count)).map({IndexPath(row: $0, section: 0)})
            self.gifyList.append(contentsOf: result)
            self.collectionView.insertItems(at: newIndex)
            self.isProcessing = false
        } error: { error in
            print(#function,error)
            self.isProcessing = false
        }
    }
}


import Foundation
import UniformTypeIdentifiers

extension FileManager{
    
    func tempImageURL(with name : String, fileType : String = "png")-> URL{
        let epocTime = Int(Date().timeIntervalSince1970)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(name)_\(epocTime).\(fileType)")
        return url
    }
    
    func getImageURL(for name : String, folder directory : URL)-> URL{
        let imageURL = directory.appendingPathComponent(name)
        return imageURL
    }
    func createFolderInTemporary(with name : String)-> URL{
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path){
            do{
                try FileManager.default.removeItem(at: url)
            }catch{
                print(error.localizedDescription)
            }
        }
        do{
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }catch{
            print(error.localizedDescription)
        }
        return url
    }
    
    
    //    func getImageItemsFrom(url : URL,fileExtension  : String = "png") throws -> [URL]{
    //        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil,options: .skipsHiddenFiles)
    //            .filter({$0.pathExtension == fileExtension}).sorted { lhs , rhs in
    //                guard let lhsCreate = lhs.creation, let rhsCreate = rhs.creation else {return false}
    //                return lhsCreate < rhsCreate
    //            }
    //    }
    
    //    func getOriginalImagesFromFolder(with url: URL) throws -> [URL] {
    //        return try getImageItemsFrom(url: url).filter { url in
    //            !url.path.contains("_Segmented") && !url.path.contains("_Edited") && !url.path.contains("_Cartoonify")
    //        }
    //    }
    //
    func createNewFolder(folderName: String, at directory: URL) -> URL? {
        var isSuccess = false
        let folderURL = directory.appendingPathComponent(folderName)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            isSuccess = self.createDirectory(at: folderURL.path)
        } else {
            isSuccess = true
        }
        return isSuccess ? folderURL : nil
    }
    private func createDirectory(at path: String) -> Bool {
        var isSuccess = false
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            isSuccess = true
        } catch {
            print(error.localizedDescription);
            isSuccess = false
        }
        return isSuccess
    }
}
import Foundation
import UIKit
import AVFoundation
extension UIImage{
    @discardableResult
    
    func writeJPG(to : URL) throws{
        let imageData = self.jpegData(compressionQuality: 0.8)
        try imageData?.write(to: to, options: .atomic)
    }
    func resize960()-> UIImage?{
        // Removed condition for size less than 980 in order to always make sticker 980 by 980
        var rect = AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: .init(width: 960, height: 960))).integral
        rect.size.width = rect.width.truncatingRemainder(dividingBy: 2) == 0 ? rect.width : rect.width - 1
        rect.size.height = rect.height.truncatingRemainder(dividingBy: 2) == 0 ? rect.height : rect.height - 1
        //        if size.width <= 980 && size.height <= 980{
        //            return self
        //        }
        let formar = UIGraphicsImageRendererFormat()
        formar.scale = 1
        let renderer = UIGraphicsImageRenderer(size: rect.size,format: formar)
        
        let image = renderer.image { context in
            self.draw(in: .init(origin: .zero, size: rect.size))
        }
        
        return image
    }
    
    func resize512()-> UIImage?{
        // Removed condition for size less than 980 in order to always make sticker 512 by 512
        var rect = AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: .init(width: 512, height: 512))).integral
        rect.size.width = rect.width.truncatingRemainder(dividingBy: 2) == 0 ? rect.width : rect.width - 1
        rect.size.height = rect.height.truncatingRemainder(dividingBy: 2) == 0 ? rect.height : rect.height - 1
        let formar = UIGraphicsImageRendererFormat()
        formar.scale = 1
        let renderer = UIGraphicsImageRenderer(size: rect.size,format: formar)
        
        let image = renderer.image { context in
            self.draw(in: .init(origin: .zero, size: rect.size))
        }
        
        return image
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        var rect = CGRect(origin: .zero, size: newSize).integral
        rect.size.width = rect.width.truncatingRemainder(dividingBy: 2) == 0 ? rect.width : rect.width - 1
        rect.size.height = rect.height.truncatingRemainder(dividingBy: 2) == 0 ? rect.height : rect.height - 1
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resize(size : CGSize, scale : CGFloat = UIScreen.main.scale)-> UIImage{
        var rect = AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: size)).integral
        rect.size.width = rect.width.truncatingRemainder(dividingBy: 2) == 0 ? rect.width : rect.width - 1
        rect.size.height = rect.height.truncatingRemainder(dividingBy: 2) == 0 ? rect.height : rect.height - 1
        let formar = UIGraphicsImageRendererFormat()
        formar.scale = scale
        let renderer = UIGraphicsImageRenderer(size: rect.size,format: formar)
        
        let image = renderer.image { context in
            self.draw(in: .init(origin: .zero, size: rect.size))
        }
        
        return image
    }
    func aspectFill(size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        // Calculate the scaling ratio for aspect fill
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let scaleFactor = max(widthRatio, heightRatio)
        
        // Calculate the new size that maintains the aspect ratio
        let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        // Set up the renderer with the specified scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        // Render the image with aspect fill
        let image = renderer.image { context in
            // Calculate the origin to center the image
            let origin = CGPoint(
                x: (size.width - scaledSize.width) / 2,
                y: (size.height - scaledSize.height) / 2
            )
            self.draw(in: CGRect(origin: origin, size: scaledSize))
        }
        
        return image
    }
    ///this resize dont care about aspect ratio
    ///just resize into target size
    func resize(to size : CGSize, scale : CGFloat = UIScreen.main.scale)-> UIImage{
        // Set up the renderer with the specified scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        // Render the image with aspect fill
        let image = renderer.image { context in
            
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}
public extension UIImage{
    @discardableResult
    func writePNG(to : URL? = nil) throws -> URL{
        var url : URL
        if let to = to{
            url = to
        }else{
            let saveUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
            url = saveUrl
        }
        //let resizeImage = self.resize980()
        let data = self.pngData()
        try data?.write(to: url,options: .atomic)
        return url
    }
    
    func resize980()-> UIImage?{
        // Removed condition for size less than 980 in order to always make sticker 980 by 980
        var rect = AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: .init(width: 980, height: 980))).integral
        rect.size.width = rect.width.truncatingRemainder(dividingBy: 2) == 0 ? rect.width : rect.width - 1
        rect.size.height = rect.height.truncatingRemainder(dividingBy: 2) == 0 ? rect.height : rect.height - 1
        if size.width <= 980 && size.height <= 980{
            return self
        }
        let formar = UIGraphicsImageRendererFormat()
        formar.scale = 1
        let renderer = UIGraphicsImageRenderer(size: rect.size,format: formar)
        
        let image = renderer.image { context in
            self.draw(in: .init(origin: .zero, size: rect.size))
        }
        
        return image
    }
    
    func trimmed() -> UIImage {
        let newRect = cropRect()
        if let imageRef = cgImage?.cropping(to: newRect.applying(CGAffineTransform(scaleX: 1.03, y: 1.03))) {
            return UIImage(cgImage: imageRef)
        }
        return self
    }
    
    func cropRect() -> CGRect {
        guard let cgImage = self.cgImage
        else {
            return CGRect(origin: .zero, size: size)
        }
        
        let bitmapBytesPerRow = cgImage.width * 4
        let bitmapByteCount = bitmapBytesPerRow * cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        
        if bitmapData == nil {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        guard let context = CGContext(
            data: bitmapData,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            return CGRect(origin: .zero, size: size)
        }
        
        let height = cgImage.height
        let width = cgImage.width
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.clear(rect)
        context.draw(cgImage, in: rect)
        
        guard let data = context.data else {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        var lowX = width
        var lowY = height
        var highX: Int = 0
        var highY: Int = 0
        
        // Filter through data and look for non-transparent pixels.
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                let color = data.load(fromByteOffset: pixelIndex, as: UInt32.self)
                
                if color != 0 { // Alpha value is not zero pixel is not transparent.
                    if x < lowX {
                        lowX = x
                    }
                    if x > highX {
                        highX = x
                    }
                    if y < lowY {
                        lowY = y
                    }
                    if y > highY {
                        highY = y
                    }
                }
            }
        }
        
        return CGRect(x: lowX, y: lowY, width: highX - lowX, height: highY - lowY)
    }
    
    static func image(from layer: CALayer) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: layer.frame.size)
        let image = renderer.image { _ in
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        return image
    }
}
