//
//  UIKitExtension.swift
//  KitchenSink
//
//  Created by panzh on 28/03/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import UIKit
extension UIFont {
    static func buttonLightFont(_ size:CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight:UIFontWeightLight)
    }
}

extension UIColor {
    static func buttonBlueNormal() -> UIColor {
        return UIColor.init(red: 7/255.0, green: 193/255.0, blue: 228/255.0, alpha: 1.0)
    }
    
    static func buttonBlueHightlight() -> UIColor {
        return UIColor.init(red: 6/255.0, green: 177/255.0, blue: 210/255.0, alpha: 1.0)
    }
    static func labelGreyColor() -> UIColor {
        return UIColor.init(red: 106/255.0, green: 107/255.0, blue: 108/255.0, alpha: 1.0)
    }
}

extension UIImage {
   static func imageWithColor(_ color:UIColor ,background:UIColor?) -> UIImage? {
        let scaledUnti: CGFloat = 1.0/UIScreen.main.scale
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: scaledUnti, height: scaledUnti)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        if let backgroundColor = background {
            backgroundColor.setFill()
            UIRectFillUsingBlendMode(rect, .normal)
        }
        color.setFill()
        UIRectFillUsingBlendMode(rect, .normal)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.resizableImage(withCapInsets: .zero)
    }
}
