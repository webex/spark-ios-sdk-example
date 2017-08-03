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

class HomeTableViewController: BaseTableViewController {
    
    // MARK: - UI outlets variables
    @IBOutlet weak var statusLabel: UILabel!
    fileprivate var registerState = "connecting"
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var buttonFontScaleCollection: [UIButton]!
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sparkRegisterPhone()
        self.updateStatusLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.sparkGetUserInfo()
    }
    
    // MARK: - SparkPhone register | SparkUser get Info
    
    func sparkRegisterPhone() {
        /*  
           Registers this phone to Cisco Spark cloud on behalf of the authenticated user.
           It also creates the websocket and connects to Cisco Spark cloud.
           - note: make sure register device before calling
         */
        sparkSDK?.phone.register() { [weak self] error in
            if let strongSelf = self {
                if error != nil {
                    //register phone fail codes here...
                    strongSelf.registerState = "fail"
                    strongSelf.showPhoneRegisterFailAlert()
                    
                } else {
                    //register phone success codes here...
                    strongSelf.registerState = "ok"
                    strongSelf.updateStatusLabel()

                }
            }
        }
    }
    
    func sparkGetUserInfo() {
        /*
            Retrieves the details for the authenticated user.
        */
        sparkSDK?.people.getMe() {[weak self] response in
            if let strongSelf = self {
                switch response.result {
                case .success(let person):
                    loggedInUser = person
                    strongSelf.updateStatusLabel()
                case .failure:
                    loggedInUser = nil
                    strongSelf.updateStatusLabel()
                }
            }
        }
    }
    
    /// deauthorize sparkSDK when logging out
    @IBAction func logoutButtonClicked() {
        guard sparkSDK != nil else {
            _ = navigationController?.popToRootViewController(animated: true)
            return
        }
        
        /*
           Removes this *phone* from Cisco Spark cloud on behalf of the authenticated user.
           It also disconnects the websocket from Cisco Spark cloud.
           Subsequent invocations of this method behave as a no-op.
         */
        sparkSDK!.phone.deregister() { ret in
            // Deauthorizes the current user and clears any persistent state with regards to the current user.
            // If the *phone* is registered, it should be deregistered before calling this method.
            sparkSDK?.authenticator.deauthorize()
            loggedInUser = nil
            sparkSDK = nil
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: - UI Implementation
    
    override func initView() {
        for label in labelFontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        
        for button in buttonFontScaleCollection {
            button.titleLabel?.font = UIFont.buttonLightFont(ofSize: (button.titleLabel?.font.pointSize)! * Utils.HEIGHT_SCALE)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
            button.clipsToBounds = true
            button.layer.cornerRadius = buttonHeight.constant/2
        }
        
        var frame = footerView.frame
        frame.size.height *= Utils.HEIGHT_SCALE
        footerView.frame = frame
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 80 * Utils.HEIGHT_SCALE
        }
        else if indexPath.section == 0 && indexPath.row == 0 {
            return 80 * Utils.HEIGHT_SCALE
        }
        else if indexPath.section == 1 {
            return 75 * Utils.HEIGHT_SCALE
        }
        return super.tableView(tableView, heightForRowAt: indexPath) * Utils.HEIGHT_SCALE
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 4 {
            self.logoutButtonClicked()
        }
    }
    
    fileprivate func updateStatusLabel() {
        statusLabel.text = "login as \(loggedInUser?.displayName ?? "NONE")"
        statusLabel.text = statusLabel.text! + "\nRegistration to Cisco cloud : " + registerState
    }
    
    fileprivate func showPhoneRegisterFailAlert() {
        let alert = UIAlertController(title: "Alert", message: "Phone register fail", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
