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

class VideoCallViewController: UIViewController {
    
    enum TitleStatusLabel: String {
        case Calling
        case Incall = "In-call"
        case Disconnected
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var selfView: MediaRenderView!
    @IBOutlet weak var remoteView: MediaRenderView!
    @IBOutlet weak var toggleSendingAudioButton: UIButton!
    @IBOutlet weak var toggleSendingVideoButton: UIButton!
    @IBOutlet weak var toggleFacingModeButton: UIButton!
    @IBOutlet weak var toggleLoudSpeakerButton: UIButton!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var remoteViewLeading: NSLayoutConstraint!
    @IBOutlet weak var remoteViewTop: NSLayoutConstraint!
    @IBOutlet weak var remoteViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var selfViewWidth: NSLayoutConstraint!
    @IBOutlet weak var selfViewHeight: NSLayoutConstraint!
    
    var call: Call!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallRinging), name: Notifications.Call.Ringing, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallConnected), name: Notifications.Call.Connected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallDisconnected), name: Notifications.Call.Disconnected, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Call events handling
    
    @objc func onCallRinging() {
        updateTitleLabelToCalling()
        updateStatusLabel()
    }
    
    @objc func onCallConnected() {
        updateTitleLabelToIncall()
        updateStatusLabel()
    }
    
    @objc func onCallDisconnected() {
        updateTitleLabelToDisconnected()
        updateStatusLabel()
        hideCallView()
        presentRateView()
    }
    
    func updateStatusLabel() {
        statusLabel.text = "call status: " + call.status.rawValue
        statusLabel.text = statusLabel.text! + "\nsendingVideo: " + call.sendingVideo.description
        statusLabel.text = statusLabel.text! + "\nsendingAudio: " + call.sendingAudio.description
        statusLabel.text = statusLabel.text! + "\nfacingMode: " + call.facingMode.rawValue
        statusLabel.text = statusLabel.text! + "\nloudSpeaker: " + call.loudSpeaker.description
    }
    
    func updateTitleLabelToCalling() {
        TitleLabel.text = TitleStatusLabel.Calling.rawValue
    }
    
    func updateTitleLabelToIncall() {
        TitleLabel.text = TitleStatusLabel.Incall.rawValue
    }
    
    func updateTitleLabelToDisconnected() {
        TitleLabel.text = TitleStatusLabel.Disconnected.rawValue
    }
    
    // MARK: - Call control
    
    @IBAction func hangup(sender: AnyObject) {
        call.hangup() { success in
            if !success {
                print("Failed to hangup call.")
            } else {
                //self.dismissCallView()
                self.presentRateView()
            }
        }
    }
    
    @IBAction func toggleFacingMode(sender: AnyObject) {
        call.toggleFacingMode()
        updateStatusLabel()
    }
    
    @IBAction func toggleLoudSpeaker(sender: AnyObject) {
        call.toggleLoudSpeaker(!call.loudSpeaker)
        updateStatusLabel()
    }
    
    @IBAction func toggleSendingAudio(sender:UIButton) {
        call.toggleSendingAudio()
        toggleSendingAudioButton.selected = !call.sendingAudio
        updateStatusLabel()
    }
    
    @IBAction func toggleSendingVideo(sender:UIButton) {
        call.toggleSendingVideo()
        toggleSendingVideoButton.selected = !call.sendingVideo
        updateStatusLabel()
        if toggleSendingVideoButton.selected {
            hideSelfView()
        } else {
            showSelfView()
        }
    }
    
    @IBAction func gotoHome(sender: AnyObject) {
        if call.status != .Disconnected {
            showEndCallAlert()
        } else {
            dismissCallView()
        }
    }
    
    // MARK: - UI views
    
    func dismissCallView() {
        if presentingViewController!.isKindOfClass(UINavigationController) {
            let navigationController = presentingViewController as! UINavigationController
            presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            navigationController.popToRootViewControllerAnimated(true)
        } else if presentingViewController!.presentingViewController!.isKindOfClass(UINavigationController) {
            let navigationController = presentingViewController!.presentingViewController! as! UINavigationController
            presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            navigationController.popViewControllerAnimated(true)
        }
    }
    
    func hideCallView() {
        hideSelfView()
        hideRemoteView()
        hideCallControllView()
    }
    
    func showSelfView() {
        selfView.hidden = false
    }
    
    func hideSelfView() {
        selfView.hidden = true
    }
    
    func hideRemoteView() {
        remoteView.hidden = true
    }
    
    func hideCallControllView() {
        toggleFacingModeButton.hidden = true
        toggleLoudSpeakerButton.hidden = true
        toggleSendingVideoButton.hidden = true
        toggleSendingAudioButton.hidden = true
        hangupButton.hidden = true
    }
    
    func presentRateView() {
        let rateViewController = storyboard?.instantiateViewControllerWithIdentifier("CallFeedbackViewController") as! CallFeedbackViewController
        rateViewController.call = self.call
        rateViewController.modalPresentationStyle = .FullScreen
        self.presentViewController(rateViewController, animated: true, completion: nil)
        if let popoverController = rateViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .Any
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.verticalSizeClass == .Regular{
            remoteViewTop.constant = 40
            remoteViewLeading.constant = 10
            remoteViewTrailing.constant = 100
            remoteViewHeight.constant = 200
            selfViewWidth.constant = 70
            selfViewHeight.constant = 100
            homeButton.hidden = false
        } else {
            remoteViewTop.constant = 0
            remoteViewLeading.constant = 0
            remoteViewTrailing.constant = 0
            remoteViewHeight.constant = view.bounds.height
            selfViewWidth.constant = 100
            selfViewHeight.constant = 70
            homeButton.hidden = true
        }
        updateViewConstraints()
    }
    
    func showEndCallAlert() {
        let alert = UIAlertController(title: nil, message: "Do you want to end current call?", preferredStyle: .Alert)
        
        let endCallHandler = {
            (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.call.hangup(nil)
            self.dismissCallView()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End call", style: .Default, handler: endCallHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
}

