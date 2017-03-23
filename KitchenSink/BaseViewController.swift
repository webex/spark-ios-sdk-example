//
//  BaseNavigationViewController.swift
//  KitchenSink
//
//  Created by panzh on 21/03/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    // MARK: - Orientation manage
    override var shouldAutorotate: Bool {
        guard viewControllers.last != nil else {
            return false
        }
        return viewControllers.last!.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard viewControllers.last != nil else {
            return .portrait
        }
        return viewControllers.last!.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard viewControllers.last != nil else {
            return UIInterfaceOrientation.portrait
        }
        return viewControllers.last!.preferredInterfaceOrientationForPresentation
    }
}

class BaseViewController: UIViewController {
    // MARK: - Orientation manage
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

class BaseTableViewController: UITableViewController {
    
    // MARK: - Orientation manage
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
