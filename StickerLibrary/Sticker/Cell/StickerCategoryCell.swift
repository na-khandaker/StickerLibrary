//
//  StickerCategoryCell.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 10/5/24.
//

import UIKit

class StickerCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var proIconView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var bgLayer : UIView!
    static let id = "StickerCategoryCell"
    
    let DESELECTED_COLOR = "#7F7F7F"
    let SELECTED_COLOR = "#FF9500"
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                categoryNameLabel.textColor = UIColor(hexaString: SELECTED_COLOR)
//                self.bgLayer.backgroundColor = UIColor.red
//                self.bgLayer.layer.borderWidth = 0.0
            } else {
                categoryNameLabel.textColor = UIColor(hexaString: DESELECTED_COLOR)
//                self.bgLayer.backgroundColor = UIColor.white
//                self.bgLayer.layer.borderWidth = 0.6
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.bgLayer.layer.borderColor = UIColor.red.cgColor
//        self.bgLayer.layer.borderWidth = 0.6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.bgLayer.layer.cornerRadius = self.height / 2.0
    }
    
    func showProIcon(isPro: Bool = true) {
        proIconView.isHidden = !isPro
    }
}
