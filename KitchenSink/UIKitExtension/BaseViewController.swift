//
//  BaseNavigationViewController.swift
//  KitchenSink
//
//  Created by panzh on 21/03/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import UIKit
import FontAwesome_swift

class BaseNavigationViewController: UINavigationController,UIGestureRecognizerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = self
            self.delegate = self
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if self.topViewController is HomeTableTableViewController || self.topViewController is VideoCallViewController{
            self.interactivePopGestureRecognizer?.isEnabled = false
            return
        }
        self.interactivePopGestureRecognizer?.isEnabled = self.viewControllers.count > 1
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        return true
    }
    
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
    var navigationTitle :String? {
        get {
            return title
        }
        set(newValue){
            self.title = newValue
        }
    }
    
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
    
    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initDefaultNavigationBar(navigationTitle)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func initView() {
        
    }
    
    func dissmissKeyboard() {
        self.view.endEditing(true)
    }
    
    func initDefaultNavigationBar(_ titleName:String?){
        
        //navigation bar title
        if titleName != nil && !titleName!.isEmpty {
            let titleLable = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 44))
            titleLable.text = titleName
            titleLable.font = UIFont.navigationBoldFont(ofSize: 22 * Utils.WIDTH_SCALE)
            titleLable.textColor = UIColor.titleGreyColor()
            titleLable.textAlignment = .center
            navigationItem.titleView = titleLable
        }
        
        let previousButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        
        let previousImage = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 32 * Utils.WIDTH_SCALE , height: 44))
        let previousLightImage = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.titleGreyLightColor(), size: CGSize.init(width: 32 * Utils.WIDTH_SCALE, height: 44))
        previousButton.setImage(previousImage, for: .normal)
        previousButton.setImage(previousLightImage, for: .highlighted)
        previousButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        
        let leftView = UIView.init(frame:CGRect.init(x: 0, y: 0, width: 44, height: 44))
        leftView.addSubview(previousButton)
        let leftButtonItem = UIBarButtonItem.init(customView: leftView)
        
        
        let fixBarSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixBarSpacer.width = -20 * (2 - Utils.WIDTH_SCALE)
        navigationItem.leftBarButtonItems = [fixBarSpacer,leftButtonItem]
    }
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
}

class BaseTableViewController: UITableViewController {
    var navigationTitle :String? {
        get {
            return title
        }
        set(newValue){
            self.title = newValue
        }
    }
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
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func initView() {
        
    }
    func dissmissKeyboard() {
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
