//
//  UIViewExt.swift
//  StickerLibrary
//
//  Created by BCL-Device-11 on 9/7/25.
//
import UIKit

extension UIView {
    var x: CGFloat {
        get { frame.origin.x }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    var y: CGFloat {
        get { frame.origin.y }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    var width: CGFloat {
        get { frame.width }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    var height: CGFloat {
        get { frame.height }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    var size: CGSize {
        get { frame.size }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    var centerX: CGFloat {
        get { center.x }
        set {
            var point = center
            point.x = newValue
            center = point
        }
    }
    var centerY: CGFloat {
        get { center.y }
        set {
            var point = center
            point.y = newValue
            center = point
        }
    }
    
    var viewController: UIViewController? {
        var next = superview
        while next != nil {
            let nextResponder = next?.next
            if nextResponder is UINavigationController ||
                nextResponder is UIViewController {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }
        return nil
    }
    
    func cornersRound(radius: CGFloat, corner: UIRectCorner) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = corner.mask
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corner,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIRectCorner {
    var mask: CACornerMask {
        switch self {
        case .allCorners:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        default:
            return .init(rawValue: rawValue)
        }
    }
}
