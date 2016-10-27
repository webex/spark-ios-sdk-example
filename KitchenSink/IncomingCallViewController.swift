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

class IncomingCallViewController: UIViewController, PhoneObserver, IncomingCallDelegate {
    
    fileprivate var callToastViewController: CallToastViewController!
    fileprivate var videoCallViewController: VideoCallViewController!
    fileprivate var call: Call!
    
    fileprivate var localVideoView: MediaRenderView {
        return videoCallViewController.selfView
    }
    
    fileprivate var remoteVideoView: MediaRenderView {
        return videoCallViewController.remoteView
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PhoneNotificationCenter.sharedInstance.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PhoneNotificationCenter.sharedInstance.remove(observer: self)
    }
    
    // MARK: - PhoneObserver
    
    func callIncoming(_ call: Call) {
        self.call = call
        presentCallToastView(call)
    }
    
    func refreshAccessTokenFailed() {
        // TODO: need to implement it?
    }
    
    // MARK: - IncomingCallDelegate
    
    func didAnswerIncomingCall() {
        Spark.phone.requestMediaAccess(Phone.MediaAccessType.audioVideo) { granted in
            if granted {
                var remoteAddr = ""
                if let remote = self.call.from {
                    remoteAddr = remote
                }
                self.presentVideoCallView(remoteAddr)
                
                var mediaOption = MediaOption.audioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.audioVideo(local: self.localVideoView, remote: self.remoteVideoView)
                }
                self.call.answer(option: mediaOption) { success in
                    if !success {
                        self.dismissVideoCallView()
                        self.call.reject(nil)
                    }
                }
            } else {
                self.call.reject(nil)
                Utils.showCameraMicrophoneAccessDeniedAlert(self)
            }
        }
    }
    
    func didDeclineIncomingCall() {
        call.reject(nil)
    }
    
    // MARK: - UI views
    
    fileprivate func presentCallToastView(_ call: Call) {
        callToastViewController = storyboard?.instantiateViewController(withIdentifier: "CallToastViewController") as! CallToastViewController
        
        callToastViewController.call = call
        callToastViewController.incomingCallDelegate = self
        callToastViewController.modalPresentationStyle = .fullScreen
        present(callToastViewController, animated: true, completion: nil)
        if let popoverController = callToastViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.permittedArrowDirections = .any
        }
    }
    
    fileprivate func presentVideoCallView(_ remoteAddr: String) {
        videoCallViewController = storyboard?.instantiateViewController(withIdentifier: "VideoCallViewController") as? VideoCallViewController!
        
        videoCallViewController.remoteAddr = remoteAddr
        videoCallViewController.call = self.call
        videoCallViewController.modalPresentationStyle = .fullScreen
        self.present(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .any
        }
    }
    
    fileprivate func dismissVideoCallView() {
        videoCallViewController.dismiss(animated: false, completion: nil)
    }
}
