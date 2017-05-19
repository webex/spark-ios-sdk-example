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

class CallToastViewController: BaseViewController {
    
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
        nameLabel.text = SparkContext.callerEmail
        fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //call callback init
        sparkCallBackInit()
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
    func sparkCallBackInit() {
        if let call = SparkContext.sharedInstance.call {
            // Callback when this *call* is disconnected (hangup, cancelled, get declined or other self device pickup the call).
            call.onDisconnected = { [weak self] disconnectionType in
                if let strongSelf = self {
                    strongSelf.dismissView()
                }
                
            }
        }
    }
    // MARK: - UI views
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
        // check the user is logically authorized.
        if SparkContext.sharedInstance.spark?.authenticator.authorized == true {
            Utils.fetchUserProfile(SparkContext.callerEmail) { [weak self] (person:Person?) in
                if person != nil {
                    if let strongSelf = self {
                        strongSelf.nameLabel.text = SparkContext.callerEmail
                        if let displayName = person!.displayName {
                            strongSelf.nameLabel.text = displayName
                        }
                        if let avatarUrl = person!.avatar {
                            strongSelf.fetchAvatarImage(avatarUrl)
                        }
                    }
                }
            }
        }
    }
}
