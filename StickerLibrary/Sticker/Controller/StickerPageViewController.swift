//
//  StickerCollectionPageVC.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 10/5/24.
//

import UIKit

protocol StickerPageViewControllerDelegate: AnyObject {
    func selectStickerCategoryItem(at index: Int)
    func getSticker(from stickerURLs: [String])
    func didSelectStickerItem(withImage image: UIImage, url: URL, isAnimated: Bool)
    func showPurchasePage()
}

class StickerPageViewController: UIPageViewController {
    
    var currentIndex = -1
    var animatedStickers: [StickerItem] = []
    var type: StickerVCTypeState = .sticker
    
//    var gifyList: [GiphyGIFModel] = []
//    var ghipyCategories: [GiphyCategory] = []
//    var stickerInfo: [[StickerInfo]] = []
    
    weak var pageDelegate: StickerPageViewControllerDelegate?

    deinit{
        print(#function,#file,"addasdasdasda deinti")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        self.setViewControllers([viewControllerAtIndex(index: 0)!], direction: .forward, animated: true)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Reachability.shared.connection == .unavailable {
            BFToast.show(inViewCenter: "Make sure you have internet connection and try again.", after: 2.0, delay: 1.0, disappeared: nil)
        }
    }
    
    func jumpToPage(at index:Int, direction: NavigationDirection? = nil, isAnimated: Bool = true)  {
//        if currentIndex == index { return }
        let pageDirection: UIPageViewController.NavigationDirection = direction != nil ? direction! : (currentIndex >  index ? .reverse : .forward)
        self.setViewControllers([viewControllerAtIndex(index: index)!], direction: pageDirection, animated: isAnimated)
    }

    func viewControllerAtIndex(index: Int) -> UIViewController? {
        
        guard let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "collectVC") as? StickerPackCollectionVC else {
            return nil
        }
        switch type {
            
        case .giphy:
            if GiphyInfo.count == 0 || index >= GiphyInfo.count {
                guard let emptyVC = storyboard?.instantiateViewController(withIdentifier: "NoStickerVC") else {
                    return nil
                }
                return emptyVC
            }
             
         default:
            if self.animatedStickers.count == 0 || index >= self.animatedStickers.count {
                guard let emptyVC = storyboard?.instantiateViewController(withIdentifier: "NoStickerVC") else {
                    return nil
                }
                return emptyVC
            }

        }
        pageContentViewController.delegate = self
        pageContentViewController.itemIndex = index
        pageContentViewController.type = type
        if type == .giphy {
            if GiphyInfo.count > 0 {
                pageContentViewController.gifyList = GiphyInfo[index].items ?? []
            }
        }  else {
            pageContentViewController.stickerItem = animatedStickers[index]
        }
        
        currentIndex = index
        return pageContentViewController
    }
}

//MARK: - UIPageViewControllerDelegate

extension StickerPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        switch type {
            
            case .giphy:
                return GiphyInfo.count == 0 ? 1 : GiphyInfo.count
           default:
            return animatedStickers.count == 0 ? 1 : animatedStickers.count
        }
    }
    
    //    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    //        // When we toggle a new page from collectionView, we need to make pageControl index match correct index
    //        //        if let vc = pageViewController.viewControllers?.last as? DataViewController, let index = model.index(of: vc.dataObject) {
    //        //            return index
    //        //        }
    //        return 0
    //    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        var totalVC = 0
        switch type {
            case .giphy:
                totalVC = GiphyInfo.count
            default:
                totalVC = animatedStickers.count
        }
        if totalVC == 0 { return }
        
        if completed {
            if let vc = pageViewController.viewControllers?.last as? StickerPackCollectionVC {
                pageDelegate?.selectStickerCategoryItem(at: vc.itemIndex)
                //currentIndex = vc.itemIndex
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? StickerPackCollectionVC)?.itemIndex else {
            return nil
        }
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? StickerPackCollectionVC)?.itemIndex else {
            return nil
        }
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        switch type {
        case .giphy:
            if (index == GiphyInfo.count) {
                return nil
            }
             
        default:
            if (index == animatedStickers.count) {
                return nil
            }
        }
        
        return viewControllerAtIndex(index: index)
    }
}

//MARK: - StickerPackCollectionVCDelegate

extension StickerPageViewController: StickerPackCollectionVCDelegate {
    func showPurchasePage() {
        self.pageDelegate?.showPurchasePage()
    }
    
    func didSelectStickerItem(with stickerImage: UIImage, url: URL, isAnimated: Bool) {
        self.pageDelegate?.didSelectStickerItem(withImage: stickerImage, url: url, isAnimated: true)
    }
    
    func fetchSticker(from urls: [String]) {
        pageDelegate?.getSticker(from: urls)
    }
}
