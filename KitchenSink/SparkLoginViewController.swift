// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SparkSDK
import Toast_Swift

class SparkLoginViewController: BaseViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    private var oauthenticator: OAuthStrategy!
    
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var buttonFontScaleCollection: [UIButton]!
    @IBOutlet weak var loginButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SparkContext.initSparkForSparkIdLogin()
        oauthenticator = SparkContext.sharedInstance.spark?.authenticator as! OAuthStrategy
    }
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusLabel.text = "Powered by SparkSDK v" + Spark.version
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauthenticator.authorized {
            showApplicationHome()
        }
    }
    // MARK: - UIView 
    override func initView() {
        for label in labelFontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for button in buttonFontScaleCollection {
            button.titleLabel?.font = UIFont.buttonLightFont(ofSize: (button.titleLabel?.font.pointSize)! * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        
        loginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        loginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        loginButton.layer.cornerRadius = loginButtonHeight.constant/2
    }
    // MARK: - Login/Auth handling
    @IBAction func loginWithSpark(_ sender: AnyObject) {
        oauthenticator.authorize(parentViewController: self) { success in
            if success {
                print("loginWithSpark success")
            }
        }
    }
    
    private func showApplicationHome() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HomeTableTableViewController") as! HomeTableTableViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}
