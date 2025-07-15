//
//  StickerVC.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 9/5/24.
//

import UIKit
import SVProgressHUD

@objc
protocol SMDismissViewControllerProtocol{
    @objc optional func didDismissController()
}

protocol StickerVCDelegate: AnyObject,SMDismissViewControllerProtocol {
    func addSticker(from stickerURLs: [String], controller: StickerVC)
    func showPurchasePage() 
    func didSelectStickerItem(with stickerImage: UIImage, url: URL, isAnimated: Bool)
}

enum StickerVCTypeState: String {
    case sticker = "Sticker"
    case animatedSticker = "Animated"
    case giphy = "Giphy"
}

class StickerVC: UIViewController, SMSegmentedControlDelegate {
    
    @IBOutlet weak var segmentControlWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stickerCategoryCollectionView: UICollectionView!
    @IBOutlet weak var segmentControlView: SMSegmentedControl!
    @IBOutlet weak var stickerContainerView: UIView!
    @IBOutlet weak var stickerTitleView: UIView!
    @IBOutlet weak var containerView: UIView!
    var isVideo = true
    
    weak var delegate: StickerVCDelegate?
    
    var stickerObject: StickerPackResponse?
    var stickerCollections: [StickerItem] = []
    var gifyList: [GiphyGIFModel] = []
    var ghipyCategories: [GiphyCategory] = []
    
    var selectedType: StickerVCTypeState = .sticker
    
    private var currentSelected: Int = 0
    private var staticStickerSelected: Int = 0
    private var animatedStickerSelected: Int = 0
    private var giphyStickerSelected: Int = 0
    
    weak var stickerPageViewController: StickerPageViewController?
    
    deinit{
        print(#function,#file,"addasdasdasda deinti")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGhipyCategory()
        
        segmentControlView.numberOfSegments = 3
        segmentControlView.segmentsTitle = "STATIC,ANIMATED,GIPHY"
        segmentControlWidthConstraint.constant = 300
        
        
        segmentControlView.delegate = self
        
        stickerTitleView.layer.cornerRadius = 14
        stickerTitleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if getStickerPackResponse() {
            configureStickerPack()
        } else {
            requestForStickerData()
        }
        
        Reachability.shared.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            self.requestForStickerData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            stickerCategoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  UIScreen.main.bounds.size.width - 414)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didDismissController?()
    }
    
    func configureGhipyCategory() {
        ghipyCategories = loadCachedGIFCategories()
        if ghipyCategories.isEmpty {
            GiphyAPIManager.shared.fetchGIFCategories { categories in
                self.ghipyCategories = categories
                self.stickerPageViewController?.ghipyCategories = categories
                
            } error: { error in
                print(error)
            }
        }
    }
    
    func loadCachedGIFCategories() -> [GiphyCategory] {
        guard let data = UserDefaults.standard.data(forKey: "GIF_CATEGORIES") else {
            return []
        }
        do {
            let decoded = try JSONDecoder().decode([GiphyCategory].self, from: data)
            return decoded
        } catch {
            print("Failed to decode cached categories:", error)
            return []
        }
    }
    
    func fetchItemsInGiphyCategory(categories: [GiphyCategory]) {
        for category in categories {
            if let categoryName = category.name {
//                GiphyAPIManager.shared.searchGiphy(searchKeyWord: categoryName) { items in
//                    GiphyInfo.append(GiphyInfoModel(keywords: category, items: items))
//                } error: { error in
//                    
//                }
            }
        }
    }
    
    func didTapSegment(_ idx: Int) {
        print(idx)
        
        if idx == 2 {
            stickerCategoryCollectionView.reloadData()
        }
        var direction: UIPageViewController.NavigationDirection = .forward
        if (isVideo && idx == 2) || (!isVideo && idx == 1) {
            guard selectedType != .giphy else {
                return
            }
            selectedType = .giphy
            direction = .forward
        } else if (isVideo && idx == 1) {
            guard selectedType != .animatedSticker else {
                return
            }
            direction = selectedType == .giphy ? .reverse : .forward
            selectedType = .animatedSticker
        } else {
            guard selectedType != .sticker else {
                return
            }
            selectedType = .sticker
            direction = .reverse
        }
        self.configureStickerPack(direction: direction)
        
    }
    
    func requestForStickerData() {
        NetworkManager.sharedInstance.requestForGetStickersData { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(_):
                if self.getStickerPackResponse() {
                    self.configureStickerPack()
                }
            case .failure(_):
                break
            }
        }
    }
    
    func configureStickerPack(direction: UIPageViewController.NavigationDirection? = nil) {
        
        stickerPageViewController?.type = selectedType
        
        /*
         stickerPageViewController?.packInfo = packInfo
         stickerPageViewController?.stickerInfo = stickerInfo
         */
        
        let isAnimating = selectedType == .animatedSticker
        stickerCollections = getStickerCollections(isAnimating: isAnimating)
        stickerPageViewController?.animatedStickers = stickerCollections
        
        var selection = 0
        switch selectedType {
        case .sticker:
            selection = staticStickerSelected
        case .animatedSticker:
            selection = animatedStickerSelected
        case .giphy:
            selection = giphyStickerSelected
        }
        
        self.currentSelected = selection
        DispatchQueue.main.async {
            self.stickerPageViewController?.jumpToPage(at: selection, direction: direction, isAnimated: direction != nil)
            self.stickerCategoryCollectionView.reloadData()
            
            switch self.selectedType {
            case .giphy:
                if self.gifyList.count > 0 {
                    self.stickerCategoryCollectionView.selectItem(at: IndexPath(row: selection, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                }
            default:
                if self.stickerCollections.count > 0 {
                    self.stickerCategoryCollectionView.selectItem(at: IndexPath(row: selection, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                }
            }
        }
    }
    
    func fetchMyPacks() {
        GiphyAPIManager.shared.fetchTrendingGiphy(type: .sticker) { [weak self] result in
            guard let self = self else { return }
            print(result.count)
            self.gifyList = result
            stickerPageViewController?.gifyList = gifyList
        } error: { message in
            
        }
    }
    
    func getStickerCollections(isAnimating: Bool)-> [StickerItem] {
        
        //        let collections = isAnimating ? stickerObject?.items.filter { $0.isAnimated } ? stickerObject?.items.filter { !$0.isAnimated }
        
        if isAnimating {
            return stickerObject?.items?.filter { $0.isAnimated ?? false } ?? [StickerItem]()
        } else {
            return stickerObject?.items?.filter { !($0.isAnimated ?? false) } ?? [StickerItem]()
        }
    }
    
    func getStickerPackResponse() -> Bool {
        if let result = UserDefaults.standard.string(forKey: "StickerAPIResponseKey") {
            do {
                let decoder = JSONDecoder()
                let data = result.data(using: .utf8)!
                let response = try decoder.decode(StickerPackResponse.self, from: data)
                //                let nonAnimatingItems = response.items.filter { !$0.isAnimated }
                //                let newResponse = StickerPackResponse(status: response.status, assetBaseURL: response.assetBaseURL, items: nonAnimatingItems, nextPage: response.nextPage)
                stickerObject = response
                for allItems in response.items! {
                    print("Animated >>",allItems.isAnimated)
                }
                return true
            } catch {
                print("Sticker DECODE ERROR")
                return false
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PageVC" {
            
            fetchMyPacks()
            stickerPageViewController = segue.destination as? StickerPageViewController
            stickerPageViewController?.pageDelegate = self
            stickerPageViewController?.gifyList = gifyList
            stickerPageViewController?.animatedStickers = getStickerCollections(isAnimating: true)
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension StickerVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedType {
        case .giphy:
            return GiphyInfo.count
        default :
            return stickerCollections.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCategoryCell.id, for: indexPath) as! StickerCategoryCell
        switch selectedType {
        case .giphy:
            cell.categoryNameLabel.text = GiphyInfo[indexPath.row].category.name
            cell.showProIcon(isPro: true)
        default :
            cell.showProIcon(isPro: stickerCollections[indexPath.row].isPro ?? false )
            cell.categoryNameLabel.text = stickerCollections[indexPath.row].name?.uppercased()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard currentSelected != indexPath.row else {
            return
        }
        currentSelected = indexPath.row
        switch selectedType {
        case .sticker:
            staticStickerSelected = indexPath.row
        case .animatedSticker:
            animatedStickerSelected = indexPath.row
        case .giphy:
            giphyStickerSelected = indexPath.row
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if selectedType == .giphy {
            
            if GiphyInfo.count > 0 {
                
                if let items =  GiphyInfo[indexPath.row].items {
                    if items.count > 0 {
                        GiphyAPIManager.shared.setSearch(key: ghipyCategories[indexPath.row].nameEncoded ?? "", offest: GiphyInfo[indexPath.row].offset, totalCount: GiphyInfo[indexPath.row].totalCount)
                        self.gifyList = items
                        self.stickerPageViewController?.gifyList = self.gifyList
                        self.stickerPageViewController?.jumpToPage(at: indexPath.row)
                        
                    } else {
                        SVProgressHUD.show(withStatus: "fetching giphy...")
                        GiphyAPIManager.shared.searchGiphy(searchKeyWord: GiphyInfo[indexPath.row].category.nameEncoded ?? "") { result in
                            if let index = GiphyInfo.firstIndex(where: { $0.category.nameEncoded == GiphyInfo[indexPath.row].category.nameEncoded }) {
                                GiphyInfo[index].items = result
                                self.gifyList = result
                                self.stickerPageViewController?.gifyList = self.gifyList
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    self.stickerPageViewController?.jumpToPage(at: indexPath.row)
                                }
                            }
                        } error: { errro in
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                            }
                        }
                    }
                }
            }
        } else {
            stickerPageViewController?.jumpToPage(at: indexPath.row)
        }
    }
}

extension StickerVC: UICollectionViewDelegateFlowLayout {
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //
    //        let nameText = stickerObject?.items[indexPath.row].name ?? "String"
    //        var size = " \(nameText) ".size(withAttributes: nil)
    //        size.width = size.width + 22
    //        size.height = stickerCategoryCollectionView.bounds.height
    //        return size
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


extension StickerVC: StickerPageViewControllerDelegate {
    
    func showPurchasePage() {
        self.dismiss(animated: true) {
            self.delegate?.showPurchasePage()
        }
    }
    
    
    func getSticker(from stickerURLs: [String]) {
        
    }
    
    func didSelectStickerItem(withImage image: UIImage, url: URL, isAnimated: Bool) {
        self.dismiss(animated: true) {
            self.delegate?.didSelectStickerItem(with: image, url: url, isAnimated: isAnimated)
        }
    }
    
    func selectStickerCategoryItem(at index: Int) {
        switch selectedType {
        case .sticker:
            staticStickerSelected = index
        case .animatedSticker:
            animatedStickerSelected = index
        case .giphy:
            giphyStickerSelected = index
        }
        stickerCategoryCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
}
