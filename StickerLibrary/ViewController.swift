//
//  ViewController.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 29/6/25.
//

import UIKit

class ViewController: UIViewController, StickerVCDelegate {
    
    func showPurchasePage(from parentVC: StickerVC) {
        
    }
    
    func isPurchased() -> Bool {
        false
    }
    
    func didSelectStickerItem(with stickerImage: UIImage, url: URL, isAnimated: Bool) {
        print(">>>> ",url)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StickerVC" {
            if let stickerVC = segue.destination as? StickerVC {
                stickerVC.delegate = self
            }
        }
    }

    @IBAction func tappedOnStikerButton(_ sender: UIButton) {
        performSegue(withIdentifier: "StickerVC", sender: nil)
    }
    
}

