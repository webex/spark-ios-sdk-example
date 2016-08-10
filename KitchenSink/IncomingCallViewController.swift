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
    
    private var callToastViewController: CallToastViewController!
    private var videoCallViewController: VideoCallViewController!
    private var call: Call!
    
    private var localVideoView: MediaRenderView {
        return videoCallViewController.selfView
    }
    
    private var remoteVideoView: MediaRenderView {
        return videoCallViewController.remoteView
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PhoneNotificationCenter.sharedInstance.addObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PhoneNotificationCenter.sharedInstance.removeObserver(self)
    }
    
    // MARK: - PhoneObserver
    
    func callIncoming(call: Call) {
        self.call = call
        presentCallToastView(call)
    }
    
    func refreshAccessTokenFailed() {
        // TODO: need to implement it?
    }
    
    // MARK: - IncomingCallDelegate
    
    func didAnswerIncomingCall() {
        Spark.phone.requestMediaAccess(Phone.MediaAccessType.AudioVideo) { granted in
            if granted {
                var remoteAddr = ""
                if let remote = self.call.from {
                    remoteAddr = remote
                }
                self.presentVideoCallView(remoteAddr)
                
                var mediaOption = MediaOption.AudioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.AudioVideo(local: self.localVideoView, remote: self.remoteVideoView)
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
    
    private func presentCallToastView(call: Call) {
        callToastViewController = storyboard?.instantiateViewControllerWithIdentifier("CallToastViewController") as! CallToastViewController
        
        callToastViewController.call = call
        callToastViewController.incomingCallDelegate = self
        callToastViewController.modalPresentationStyle = .FullScreen
        presentViewController(callToastViewController, animated: true, completion: nil)
        if let popoverController = callToastViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.permittedArrowDirections = .Any
        }
    }
    
    private func presentVideoCallView(remoteAddr: String) {
        videoCallViewController = storyboard?.instantiateViewControllerWithIdentifier("VideoCallViewController") as? VideoCallViewController!
        
        videoCallViewController.remoteAddr = remoteAddr
        videoCallViewController.call = self.call
        videoCallViewController.modalPresentationStyle = .FullScreen
        self.presentViewController(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .Any
        }
    }
    
    private func dismissVideoCallView() {
        videoCallViewController.dismissViewControllerAnimated(false, completion: nil)
    }
}
