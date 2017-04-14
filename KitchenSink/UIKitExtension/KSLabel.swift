//
//  KSLabel.swift
//  KitchenSink
//
//  Created by panzh on 10/04/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import UIKit

class KSLabel: UILabel {
    private let insetValue = 10 * Utils.HEIGHT_SCALE
    
    override func drawText(in rect: CGRect) {
        
        let insets = UIEdgeInsets.init(top: 0, left: insetValue, bottom: 0, right: insetValue)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var size = super.intrinsicContentSize
            size.height += (insetValue*2)
            size.width += (insetValue*2)
            return size
        }
    }
    
}
