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
    static let lightFontDesc: [String:Any] = [UIFontDescriptorFamilyAttribute: "Arial",UIFontWidthTrait : UIFontWeightLight]
    static let boldFontDesc: [String:Any] = [UIFontDescriptorFamilyAttribute: "Arial",UIFontWidthTrait : UIFontWeightBold]
    
    static func buttonLightFont(ofSize size:CGFloat) -> UIFont {
        return UIFont.init(descriptor: UIFontDescriptor(fontAttributes:lightFontDesc), size: size)
    }
    
    static func labelLightFont(ofSize size:CGFloat) -> UIFont {
        return UIFont.init(descriptor: UIFontDescriptor(fontAttributes:lightFontDesc), size: size)
    }
    static func textViewLightFont(ofSize size:CGFloat) -> UIFont {
        return UIFont.init(descriptor: UIFontDescriptor(fontAttributes:lightFontDesc), size: size)
    }
    
    static func navigationBoldFont(ofSize size:CGFloat) -> UIFont {
        return UIFont.init(descriptor: UIFontDescriptor(fontAttributes:boldFontDesc), size: size)
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
    static func labelGreyHightLightColor() -> UIColor {
        return UIColor.init(red: 106/255.0, green: 107/255.0, blue: 108/255.0, alpha: 0.2)
    }
    static func titleGreyColor() -> UIColor {
        return UIColor.init(fromRGB: 0x444444,withAlpha:1.0)
    }
    static func titleGreyLightColor() -> UIColor {
        return UIColor.init(fromRGB: 0x444444,withAlpha:0.5)
    }
    
    static func buttonGreenNormal() ->UIColor {
        return UIColor.init(fromRGB: 0x30D557,withAlpha:1.0)
    }
    static func buttonGreenHightlight() ->UIColor {
        return UIColor.init(fromRGB: 0x30D557,withAlpha:0.5)
    }
    
    static func baseRedNormal() ->UIColor {
        return UIColor.init(fromRGB: 0xFF513D,withAlpha:1.0)
    }
    static func baseRedHighlight() ->UIColor {
        return UIColor.init(fromRGB: 0xEB4A38,withAlpha:1.0)
    }
    
    
    public convenience init(fromRGB rgbValue: UInt32, withAlpha alpha: CGFloat = 1) {
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat((rgbValue & 0x0000FF)) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
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

