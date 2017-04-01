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

class CallToastViewController: BaseViewController, CallObserver {
    
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet weak var previewRenderView: MediaRenderView!
    
    @IBOutlet weak var avatarViewHeight: NSLayoutConstraint!
    
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    
    weak var incomingCallDelegate: IncomingCallDelegate?
    
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = SparkContext.sharedInstance.call?.from
        fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SparkContext.sharedInstance.spark?.callNotificationCenter.add(observer: self)
        //SparkContext.sharedInstance.spark?.phone.showPreview(previewRenderView)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //SparkContext.sharedInstance.spark?.phone.stopPreview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SparkContext.sharedInstance.spark?.callNotificationCenter.remove(observer: self)
    }
    
    // MARK: - Call answer/reject
    
    @IBAction private func answerButtonPressed(_ sender: AnyObject) {
        incomingCallDelegate?.didAnswerIncomingCall()
        dismissView()
    }
    
    @IBAction private func declineButtonPressed(_ sender: AnyObject) {
        incomingCallDelegate?.didDeclineIncomingCall()
        dismissView()
    }
    
    // MARK: - CallObserver
    
    func callDidDisconnect(_ call: Call, disconnectionType: DisconnectionType) {
        dismissView()
    }
    
    // MARK: - UI views
    override func initView() {
        for label in labelFontScaleCollection {
            label.font = UIFont.systemFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        avatarImage.layer.cornerRadius = avatarViewHeight.constant/2
        
    }
    private func fetchAvatarImage(_ avatarUrl: String) {
        Utils.downloadAvatarImage(avatarUrl, completionHandler: { [weak self] avatarImage in
            if let strongSelf = self {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    strongSelf.avatarImage.alpha = 1
                    strongSelf.avatarImage.alpha = 0.1
                    strongSelf.view.layoutIfNeeded()
                }, completion: { [weak self] finished in
                    if let strongSelf = self {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                            strongSelf.avatarImage.image = avatarImage
                            strongSelf.avatarImage.alpha = 1
                            strongSelf.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                })
            }
        })
    }
    
    private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - People API
    
    private func fetchUserProfile() {
        if SparkContext.sharedInstance.spark?.authenticationStrategy.authorized == true, let email = SparkContext.sharedInstance.call?.from {
            Utils.fetchUserProfile(email) { [weak self] (displayName: String, avatarUrl: String) in
                if let strongSelf = self {
                    strongSelf.fetchAvatarImage(avatarUrl)
                    strongSelf.nameLabel.text = displayName
                }
            }
        }
    }
}
