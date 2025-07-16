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

enum GiphyDownloadError: Error {
    case invalidURL
    case downloadFailed
    case unknown
}

protocol StickerPackCollectionVCDelegate: AnyObject {
    
    func didSelectStickerItem(with stickerImage: UIImage, url: URL, isAnimated: Bool)
    func showPurchasePage()
}

class StickerPackCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemIndex = 0
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
                      BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 1.0, disappeared: nil)
                }
            }
        }
        
        if shouldShowNoInterNetAlert(for: type) && Reachability.shared.connection == .unavailable  {
             BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 1.0, disappeared: nil)
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
            return (stickerItem?.stickers?.count) ?? 0
        case .sticker:
            return (stickerItem?.stickers?.count) ?? 0
        case .giphy:
            return gifyList.count
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StickerCell
        if let sticker = stickerItem {
            cell.configureCell(with: sticker.code ?? "", and: sticker.stickers?[indexPath.row] ?? "", isAnimating: sticker.isAnimated ?? false)
        }
        else if type == .giphy {
            cell.configureCellForGIFY(with: gifyList[indexPath.row], isAnimated: true)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var stickerFileUrl: URL = URL(fileURLWithPath: "")
        var isAnimated = true
       
        switch type {
        case .giphy:
            
            #warning("Check is Purchase")
            
            guard let path = gifyList[indexPath.row].images?.original?.url else { return }
            
            if  Reachability.shared.connection == .unavailable {
                BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 1.0, disappeared: nil)
                return
            }
            if let url = URL(string: path) {
                SVProgressHUD.show(withStatus: "Loading...")
                
                downloadGhipy(from: url) { retsult in
                   
                    switch retsult {
                        
                    case .success(let url):
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            stickerFileUrl = url
                            self.delegate?.didSelectStickerItem(with: UIImage(contentsOfFile: stickerFileUrl.path)!, url: stickerFileUrl, isAnimated: isAnimated)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            BFToast.show(inViewCenter: "\(error.localizedDescription)", after: 0.0, delay: 1.0, disappeared: nil)
                            return
                        }
                    }
                }
            }
            
        default:
            if let sticker = stickerItem {
                isAnimated = sticker.isAnimated ?? false
                
                let isPurchased = false
                #warning("Check is Purchased")
                if sticker.isPro ?? false  && !isPurchased {
                    self.delegate?.showPurchasePage()
                    return
                }
                
                let stickerLocalURL = SMFileManager.shared.getFileURL(for: "Stickers/\(sticker.code ?? "")/\(sticker.stickers?[indexPath.row] ?? "")")!
                
                if !SMFileManager.shared.isFileExists(at: stickerLocalURL.path) && Reachability.shared.connection == .unavailable {
                    DispatchQueue.main.async {
                          BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 0.0, delay: 1.0, disappeared: nil)
                    }
                    return
                }
                stickerFileUrl = stickerLocalURL
                self.delegate?.didSelectStickerItem(with: UIImage(contentsOfFile: stickerFileUrl.path)!, url: stickerFileUrl, isAnimated: isAnimated)
            }
        }
//        self.delegate?.didSelectStickerItem(with: UIImage(contentsOfFile: stickerFileUrl.path)!, url: stickerFileUrl, isAnimated: isAnimated)

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
    
    func downloadGhipy(from giphyURL: URL,completion: @escaping (Result<URL, Error>) -> Void) {
        
        let url = SMFileManager.shared.getFileURL(for: "Stickers/Giphy")!
        let _ = SMFileManager.shared.createNewFolder(folderName: "", at: url)
        
        print("REquest url >> ",giphyURL)
        FileDownloader.loadFileAsync(url: giphyURL, folderName: "Giphy", uniqueID: UUID().uuidString) { [weak self] downloadedUrl, error in
            if error == nil {
                DispatchQueue.main.async {
                    if let urlString = downloadedUrl, let url = URL(string: urlString)  {
                        completion(.success(url))
                    }
                }
            } else {
                completion(.failure(error ?? GiphyDownloadError.downloadFailed))
            }
        }
        
    }
    
    func nextPageGiphy(){
        guard !isProcessing else{
            return
        }

        isProcessing = true
        GiphyAPIManager.shared.nextPage{[weak self] result in
            
            guard let self else { return }
            
            let lastIndex = self.gifyList.count
            
            print("lastIndex >>>",lastIndex)
            
            let newIndex : [IndexPath] = (lastIndex..<(lastIndex+result.count)).map({IndexPath(row: $0, section: 0)})
            
            self.gifyList.append(contentsOf: result)
            
            if GiphyInfo.count > 0 {
                GiphyInfo[itemIndex].items = gifyList
                GiphyInfo[itemIndex].offset = GiphyInfo[itemIndex].items?.count ?? 0
            }

            print("NOW TOTAL === ",gifyList.count)
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
