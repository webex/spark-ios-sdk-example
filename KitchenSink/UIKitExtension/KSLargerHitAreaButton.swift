//
//  KSLargerHitAreaButton.swift
//  KitchenSink
//
//  Created by panzh on 12/04/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import UIKit

class KSLargerHitAreaButton: UIButton {
    
    fileprivate let minimumHitArea = CGSize(width: 44, height: 44)
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        return (largerFrame.contains(point)) ? self : nil
    }
    
    
}
