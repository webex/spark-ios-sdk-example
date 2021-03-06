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
    
    // MARK: - UI outlets variables
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var buttonFontScaleCollection: [UIButton]!
    @IBOutlet weak var loginButtonHeight: NSLayoutConstraint!
    
    /// saparkSDK reperesent for the SparkSDK API instance
    var sparkSDK: Spark?
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusLabel.text = "Powered by SparkSDK v" + Spark.version
    }
    override func viewDidAppear(_ animated: Bool) {
        /*
         An [OAuth](https://oauth.net/2/) based authentication strategy
         is to be used to authenticate a user on Cisco Spark.
         */
        let authenticator = OAuthAuthenticator(clientId: SparkEnvirmonment.ClientId, clientSecret: SparkEnvirmonment.ClientSecret, scope: SparkEnvirmonment.Scope, redirectUri: SparkEnvirmonment.RedirectUri)
        self.sparkSDK = Spark(authenticator: authenticator)
        self.sparkSDK?.logger = KSLogger() //Register a console logger into SDK
        
        
        /*
         Check wether sparkSDK is already authorized, sparkSDk saves authorization info in device key-chain
         -note: if user didn't logged out or didn't deauthorize, "self.sparkSDK.authenticator" function will return true
         -note: if sparkSDK is authorized, directly jump to login success process
         */
        if (self.sparkSDK?.authenticator as! OAuthAuthenticator).authorized{
            self.sparkSDK?.authenticator.accessToken{ res in
                print("\(res ?? "")")
                
            }
            self.loginSuccessProcess()
            return
        }
    }
    
    
    // MARK: - SparkSDK: sparkID Login
    @IBAction func sparkLoginBtnClicked(_ sender: AnyObject) {
        /*
         An [OAuth](https://oauth.net/2/) based authentication strategy
         is to be used to authenticate a user on Cisco Spark.
         */
        let authenticator = OAuthAuthenticator(clientId: SparkEnvirmonment.ClientId, clientSecret: SparkEnvirmonment.ClientSecret, scope: SparkEnvirmonment.Scope, redirectUri: SparkEnvirmonment.RedirectUri)
        self.sparkSDK = Spark(authenticator: authenticator)
        self.sparkSDK?.logger = KSLogger() //Register a console logger into SDK
        
        /*
         Brings up a web-based authorization view controller and directs the user through the OAuth process.
         -note: parentViewController must contain a navigation Controller,so that the OAuth view controller can push on it. 
         */
        (self.sparkSDK?.authenticator as! OAuthAuthenticator).authorize(parentViewController: self) { [weak self] success in
            if success {
                /* Spark Login Success codes here... */
                if let strongSelf = self {
                    strongSelf.loginSuccessProcess()
                }
            }
            else {
                /* Spark Login Fail codes here... */
                if let strongSelf = self {
                    strongSelf.loginFailureProcess()
                }
            }
        }
    }
    
    private func loginSuccessProcess() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeTableViewController") as! HomeTableViewController
        homeViewController.sparkSDK = self.sparkSDK
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    fileprivate func loginFailureProcess() {
        let alert = UIAlertController(title: "Alert", message: "Spark login failed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UI Implementation
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
}
