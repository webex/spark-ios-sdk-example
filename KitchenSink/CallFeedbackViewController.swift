// Copyright 2016 Cisco Systems Inc
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
import Cosmos

class CallFeedbackViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet weak var userCommentsTextView: UITextView!
    @IBOutlet weak var includeLogSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var callRateView: CosmosView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var buttonFontScaleCollection: [UIButton]!
    @IBOutlet weak var sendFeedBackButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var titleTopToSuperViewConstraint: NSLayoutConstraint!
    private var topToSuperView: CGFloat = 0
    var dissmissBlock: (()->())? = nil
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallFeedbackViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CallFeedbackViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        topToSuperView = titleTopToSuperViewConstraint.constant
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    override func initView() {
        
        for label in labelFontScaleCollection {
            label.font = UIFont.systemFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for button in buttonFontScaleCollection {
            button.titleLabel?.font = UIFont.systemFont(ofSize: (button.titleLabel?.font.pointSize)! * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        userCommentsTextView.font = UIFont.systemFont(ofSize: (userCommentsTextView.font?.pointSize)! * Utils.HEIGHT_SCALE)
        
        
        
        userCommentsTextView.layer.borderColor = UIColor.gray.cgColor
        userCommentsTextView.layer.borderWidth = 1.0
        userCommentsTextView.layer.cornerRadius = 8
        userCommentsTextView.delegate = self
        
        cancelButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        cancelButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        cancelButton.layer.cornerRadius = buttonHeight.constant/2
        
        sendFeedBackButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        sendFeedBackButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        sendFeedBackButton.layer.cornerRadius = buttonHeight.constant/2
        
    }
    
    // MARK: - Call sendFeedback
    
    @IBAction func sendFeedback(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.sendFeedbackWith(rating: Int(callRateView.rating), comments: userCommentsTextView.text!, includeLogs: includeLogSwitch.isOn)
        
        dismiss(animated: true)
        {
            self.dissmissBlock?()
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            placeholderLabel.isHidden = true
        }
        else {
            placeholderLabel.isHidden = false
        }
    }
    
    // MARK: - UI views
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true)
        {
            self.dissmissBlock?()
        }
    }
    
    @IBAction func IncludeLogs(_ sender: AnyObject) {
        updateStatusLabel()
    }
    
    func updateStatusLabel() {
        statusLabel.text = "User rating: " + String(Int(callRateView.rating))
        statusLabel.text = statusLabel.text! + "\nUser comments : " + userCommentsTextView.text!
        statusLabel.text = statusLabel.text! + "\nInclude logs : " + includeLogSwitch.isOn.description
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - Keyboard show/hide
    func keyboardWillShow(notification:NSNotification) {
        guard titleTopToSuperViewConstraint.constant != 0 else {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard keyboardSize.size.height > 0 else {
                return
            }

            let textViewButtom = userCommentsTextView.frame.origin.y + userCommentsTextView.frame.size.height
            let keyboardY = UIScreen.main.bounds.height - keyboardSize.size.height
            //print("textViewButtom:\(textViewButtom) , keyboardY :\(keyboardY)")
            if keyboardY < textViewButtom {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.titleTopToSuperViewConstraint.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if titleTopToSuperViewConstraint.constant != topToSuperView {
            UIView.animate(withDuration: 0.5) { [weak self] in
                if let strongSelf = self {
                    strongSelf.titleTopToSuperViewConstraint.constant = strongSelf.topToSuperView
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
    }
}
