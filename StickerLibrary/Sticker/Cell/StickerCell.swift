//
//  StickerCell.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 10/5/24.
//

import UIKit
import YYImage
import SDWebImage

class StickerCell: UICollectionViewCell {
    
    @IBOutlet weak var animatedImageView: YYAnimatedImageView!
    @IBOutlet weak var stickerLoadingIndicator: UIActivityIndicatorView?
    @IBOutlet weak var imageView: SDAnimatedImageView!
    
    var imageDownloader : ImageDownloader? = ImageDownloader()
    var currentPhotoID: String?
    
    static let id = "StickerCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit{
        reset()
        self.stickerLoadingIndicator = nil
        self.animatedImageView = nil
        self.imageView = nil
        for subview in subviews {
            subview.removeConstraints(subview.constraints)
            subview.removeFromSuperview()
        }
        self.removeFromSuperview()
        imageDownloader = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset(){
        imageDownloader?.cancel()
        imageView.stopAnimating()
        imageView.clearBufferWhenStopped = true
        imageView.sd_cancelCurrentImageLoad()
        
        imageView.image = nil
        animatedImageView.stopAnimating()
        animatedImageView.image = nil
        self.stickerLoadingIndicator?.stopAnimating()
    }
    
    func commonInit() {
//        self.layer.cornerRadius = 14
//        self.layer.borderColor = UIColor.red.cgColor
//        self.layer.borderWidth = 0.5
    }
    
    func configureCellForGIFY(with giphyGIFModelInfo: GiphyGIFModel, isAnimated: Bool) {
        DispatchQueue.main.async {
            self.stickerLoadingIndicator?.startAnimating()
        }
        guard let url = giphyGIFModelInfo.images?.previewGIF?.url else { return }
        
        self.imageView.sd_setImage(with: URL(string: url), placeholderImage: nil) { image , error , cacheType , imageURL in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.stickerLoadingIndicator?.stopAnimating()
            }
            self.imageView.image = image
            self.imageView.startAnimating()
        }
    }
    
    func configureCell(with code: String, and stickerPath : String, isAnimating: Bool) {
        let stickerFileUrl = SMFileManager.shared.getFileURL(for: "Stickers/\(code)/\(stickerPath)")!
        print("stickerFileUrl >> ",stickerFileUrl)
        if SMFileManager.shared.isFileExists(at: stickerFileUrl.path) {
            loadImage(with: stickerFileUrl.path, isAnimated: isAnimating)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.stickerLoadingIndicator?.stopAnimating()
            }
        } else  {
            //Check Reachebility Before Download
            //            if Reachability.shared.connection == .unavailable {
            //                self.stickerLoadingIndicator?.stopAnimating()
            ////                imageView.image = UIImage(systemName: "wifi.exclamationmark")
            //                imageView.image = nil
            //            } else {
            DispatchQueue.main.async {
                self.stickerLoadingIndicator?.startAnimating()
            }
            
            var baseURl = "https://d1fmtkv107yu6a.cloudfront.net/stickers"
            if let result = UserDefaults.standard.string(forKey: "StickerAPIResponseKey") {
                do {
                    let decoder = JSONDecoder()
                    let data = result.data(using: .utf8)!
                    let response = try decoder.decode(StickerPackResponse.self, from: data)
                    baseURl = response.assetBaseURL ?? baseURl
                } catch {
                    print("Error")
                }
            }
            requestToDownloadImage(with: baseURl, folderName: code, filePath: stickerPath, isAnimating: isAnimating)
            //  }
        }
    }
    
    func loadImage(with imagePath: String, isAnimated: Bool = false) {
        stickerLoadingIndicator?.stopAnimating()
        if isAnimated {
            animatedImageView.image = YYImage(contentsOfFile: imagePath)
            animatedImageView.startAnimating()
            imageView.isHidden = true
            animatedImageView.isHidden = false
        } else {
            imageView.isHidden = false
            imageView.image = UIImage(contentsOfFile: imagePath)
            animatedImageView.isHidden = true
        }
    }
    
    func requestToDownloadImage(with baseUrl: String, folderName:String, filePath: String, isAnimating: Bool) {
        
        let url = SMFileManager.shared.getFileURL(for: "Stickers/\(folderName)")!
        let _ = SMFileManager.shared.createNewFolder(folderName: "", at: url)
        let requestURL = baseUrl + folderName + "/" + filePath
        if let url = URL(string: requestURL) {
            print("REquest url >> ",requestURL)
            FileDownloader.loadFileAsync(url: url, folderName: folderName) { [weak self] downloadedUrl, error in
                if error == nil {
                    DispatchQueue.main.async {
                        if let url = downloadedUrl {
                            self?.loadImage(with: url,isAnimated: isAnimating)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.stickerLoadingIndicator?.startAnimating()
                    }
                }
            }
        }
    }
    
    func requestToDownloadGIFY(with baseUrl: String, folderName:String = "GIFY") {
        
        let url = SMFileManager.shared.getFileURL(for: "Stickers/\(folderName)")!
        let _ = SMFileManager.shared.createNewFolder(folderName: "", at: url)
        if let reqURL = URL(string: baseUrl) {
            FileDownloader.loadFileAsync(url: reqURL, folderName: folderName) { [weak self] downloadedUrl, error in
                if error == nil {
                    DispatchQueue.main.async {
                        if let url = downloadedUrl {
                            self?.loadImage(with: url,isAnimated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.stickerLoadingIndicator?.startAnimating()
                    }
                }
            }
        }
    }
    
    private func downloadImage(with url: URL, and id: String) {
        let downloadPhotoID = id
        imageDownloader?.downloadPhoto(with: url, completion: { [weak self] (image, isCached) in
            guard let strongSelf = self, strongSelf.currentPhotoID == downloadPhotoID else {
                return }
            
            if isCached {
                strongSelf.imageView.image = image
            } else {
                UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.imageView.image = image
                }, completion: nil)
            }
        })
    }
}


