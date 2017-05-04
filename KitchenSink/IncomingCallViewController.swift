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

class IncomingCallViewController: BaseViewController, IncomingCallDelegate {
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    
    private var waittingTimer: Timer?
    @IBOutlet weak var animationLabel: UILabel!
    
    override var navigationTitle: String? {
        get {
            return SparkContext.sharedInstance.selfInfo?.displayName
        }
        set(newValue) {
            title = newValue
        }
    }
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //call callback init
        sparkCallBackInit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startWaitingAnimation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWaitingAnimation()
    }
    
    // MARK: - PhoneObserver
    func sparkCallBackInit() {
        if let phone = SparkContext.sharedInstance.spark?.phone {
            phone.onIncoming = { [weak self] call in
                if let strongSelf = self {
                    SparkContext.sharedInstance.call = call
                    strongSelf.presentCallToastView(call)
                }
            }
        }
    }
    
    // MARK: - IncomingCallDelegate
    func didAnswerIncomingCall() {
        self.presentVideoCallView(SparkContext.callerEmail)
    }
    
    func didDeclineIncomingCall() {
        SparkContext.sharedInstance.call?.reject()
    }
    
    // MARK: - UI views
    override func initView() {
        for label in labelFontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
    }
    
    func startWaitingAnimation() {
        stopWaitingAnimation()
        waittingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(waitingAnimation), userInfo: nil, repeats: true)
    }
    
    func stopWaitingAnimation() {
        if let timer = waittingTimer {
            if timer.isValid {
                timer.invalidate()
            }
            waittingTimer = nil
        }
    }
    
    func waitingAnimation() {
        if let labelText = animationLabel.text {
            if labelText.characters.count > 2 {
                animationLabel.text = ""
            }
            else {
                animationLabel.text!.append(".")
            }
        }
        
    }
    
    
    
    fileprivate func presentCallToastView(_ call: Call) {
        if let callToastViewController = storyboard?.instantiateViewController(withIdentifier: "CallToastViewController") as? CallToastViewController {
            
            callToastViewController.incomingCallDelegate = self
            callToastViewController.modalPresentationStyle = .fullScreen
            callToastViewController.modalTransitionStyle = .coverVertical
            present(callToastViewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func presentVideoCallView(_ remoteAddr: String) {
        if let videoCallViewController = storyboard?.instantiateViewController(withIdentifier: "VideoCallViewController") as? VideoCallViewController! {
            
            videoCallViewController.videoCallRole = .Callee(remoteAddr)
            navigationController?.pushViewController(videoCallViewController, animated: true)
        }
    }
}
