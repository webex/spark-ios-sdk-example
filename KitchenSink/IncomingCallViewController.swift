// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
