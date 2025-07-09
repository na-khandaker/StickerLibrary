//
//  StickerCategoryCell.swift
//  SlideShowMetal
//
//  Created by Debotosh Dey-3 on 10/5/24.
//

import UIKit

class StickerCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var bgLayer : UIView!
    static let id = "StickerCategoryCell"
    
    let DESELECTED_COLOR = UIColor(red: 0.09, green: 0.09, blue: 0.1, alpha: 1)
    let SELECTED_COLOR =  UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                categoryNameLabel.textColor = SELECTED_COLOR
                self.bgLayer.backgroundColor = UIColor.red
                self.bgLayer.layer.borderWidth = 0.0
            } else {
                categoryNameLabel.textColor = DESELECTED_COLOR
                self.bgLayer.backgroundColor = UIColor.white
                self.bgLayer.layer.borderWidth = 0.6
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgLayer.layer.borderColor = UIColor.red.cgColor
        self.bgLayer.layer.borderWidth = 0.6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgLayer.layer.cornerRadius = self.height / 2.0
    }
}
