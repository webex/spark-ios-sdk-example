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

class IncomingCallViewController: BaseViewController, CallObserver, IncomingCallDelegate {
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SparkContext.sharedInstance.spark?.callNotificationCenter.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SparkContext.sharedInstance.spark?.callNotificationCenter.remove(observer: self)
    }
    
    // MARK: - PhoneObserver
    
    func callIncoming(_ call: Call) {
        SparkContext.sharedInstance.call = call
        presentCallToastView(call)
    }
    
    func refreshAccessTokenFailed() {
        // TODO: need to implement it?
    }
    
    // MARK: - IncomingCallDelegate
    
    func didAnswerIncomingCall() {
        
        self.presentVideoCallView(SparkContext.sharedInstance.call?.from ?? "")
        
    }
    
    func didDeclineIncomingCall() {
        SparkContext.sharedInstance.call?.reject(nil)
    }
    
    // MARK: - UI views
    
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
