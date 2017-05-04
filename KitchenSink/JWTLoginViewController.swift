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

class JWTLoginViewController: BaseViewController {
    
    
    @IBOutlet weak var jwtTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var jwtLoginButton: UIButton!
    private var jwtAuthStrategy: JWTAuthStrategy!
    @IBOutlet weak var waitingView: UIActivityIndicatorView!
    
    @IBOutlet var textFieldFontScaleCollection: [UITextField]!
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var buttonFontScaleCollection: [UIButton]!

    @IBOutlet weak var imageTopToSuperView: NSLayoutConstraint!
    private var topToSuperView: CGFloat = 0
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        topToSuperView = imageTopToSuperView.constant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SparkContext.initSparkForJWTLogin()
        jwtAuthStrategy = SparkContext.sharedInstance.spark?.authenticator as! JWTAuthStrategy!
        Spark.toggleConsoleLogger(true)
        hideWaitingView()
        jwtTextField.becomeFirstResponder()
    }
    // MARK: - View style and context init
    override func initView()
    {
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
        for textField in textFieldFontScaleCollection {
            textField.font = UIFont.textViewLightFont(ofSize: (textField.font?.pointSize)! * Utils.HEIGHT_SCALE)
        }
        statusLabel.text = "Powered by SparkSDK v" + Spark.version
        jwtLoginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        jwtLoginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        jwtLoginButton.layer.cornerRadius = buttonHeightConstraint.constant/2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - JWT Text Field & Button Enable/Disable
    @IBAction func jwtTextFieldChanged(_ sender: UITextField) {
        jwtLoginButton.isEnabled = !((jwtTextField.text?.isEmpty) ?? false)
        jwtLoginButton.alpha = (jwtLoginButton.isEnabled) ? 1.0 : 0.5
    }

    // MARK: - Login/Auth handling
    @IBAction func loginWithSpark(_ sender: UIButton) {
        guard let jwt = jwtTextField.text else {
            return
        }
        self.jwtTextField.resignFirstResponder()
        showWaitingView()

        if !jwtAuthStrategy.authorized {
            jwtAuthStrategy.authorizedWith(jwt: jwt)
        }

        if jwtAuthStrategy.authorized == true {
            SparkContext.sharedInstance.spark?.people.getMe() { response in
                self.hideWaitingView()
                
                switch response.result {
                case .success(let person):
                    SparkContext.sharedInstance.selfInfo = person
                    let emailAddress = (person.emails ?? []).first
                    let emailString = emailAddress == nil ? "NONE" : emailAddress!.toString()
                    let alert = UIAlertController(title: "Logged in", message: "Logged in as \(person.displayName ?? "NONE") with id \n\(emailString)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.showApplicationHome()
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                    
                case .failure(let error):
                    SparkContext.sharedInstance.selfInfo = nil
                    let alert = UIAlertController(title: "Could Not Get Personal Info", message: "Unable to retrieve information about the user logged in using the JWT: Please make sure your JWT is correct. \(error)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            }
        } else {
            hideWaitingView()
            showLoginError()
        }
    }
    
    private func showApplicationHome() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HomeTableTableViewController") as! HomeTableTableViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLoginError() {
        let alert = UIAlertController(title: "Could Not Login", message: "Unable to Login: Please make sure your JWT is correct.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) {
            action in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func showWaitingView() {
        waitingView.startAnimating()
        jwtLoginButton.setTitleColor(UIColor.clear, for: UIControlState.disabled)
        jwtLoginButton.isEnabled = false
        jwtLoginButton.alpha = 0.5
    }
    
    func hideWaitingView() {
        waitingView.stopAnimating()
        jwtLoginButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
        jwtLoginButton.alpha = 1
        jwtTextFieldChanged(jwtTextField)
    }
    
    // MARK: - Keyboard show/hide
    func keyboardWillShow(notification:NSNotification) {
        guard imageTopToSuperView.constant != 0 else {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard keyboardSize.size.height > 0 else {
                return
            }
            
            let textViewButtom = jwtLoginButton.frame.origin.y + jwtLoginButton.frame.size.height
            let keyboardY = UIScreen.main.bounds.height - keyboardSize.size.height
            if keyboardY < textViewButtom {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.imageTopToSuperView.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if imageTopToSuperView.constant != topToSuperView {
            UIView.animate(withDuration: 0.5) { [weak self] in
                if let strongSelf = self {
                    strongSelf.imageTopToSuperView.constant = strongSelf.topToSuperView
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
    }
    
}
