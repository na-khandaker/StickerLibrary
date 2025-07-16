//
//  AppDelegate.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 29/6/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        try? Reachability.shared.startNotifier()
        NetworkManager.sharedInstance.requestForGetStickersData(completion: nil)
        
        GiphyAPIManager.shared.fetchGIFCategories { categories in
            GiphyAPIManager.shared.batchRequest(infoList: categories) { result in
                GiphyInfo = result
                print(result.count)
            }
        } error: { error in
            print(error)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let stoaryBoard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = stoaryBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle



}

