//
//  CustomSegmentedControl.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 10/7/25.
//
import UIKit

class CustomSegmentedControl: UISegmentedControl{
    private let segmentInset: CGFloat = 2       //your inset amount
    private let segmentImage: UIImage? = UIImage(color: UIColor.white)    //your color
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        //background
        layer.cornerRadius = bounds.height/2
        //foreground
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView
        {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
            foregroundImageView.image = segmentImage    //substitute with our own colored image
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")    //this removes the weird scaling animation!
            foregroundImageView.layer.masksToBounds = true
            
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
        }
    }
}



