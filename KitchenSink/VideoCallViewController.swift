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

class VideoCallViewController: UIViewController, CallObserver {
    
    @IBOutlet weak var selfView: MediaRenderView!
    @IBOutlet weak var remoteView: MediaRenderView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var disconnectionTypeLabel: UILabel!
    
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var facingModeSwitch: UISwitch!
    @IBOutlet weak var loudSpeakerSwitch: UISwitch!
    @IBOutlet weak var sendingVideoSwitch: UISwitch!
    @IBOutlet weak var sendingAudioSwitch: UISwitch!
    @IBOutlet weak var receivingVideoSwitch: UISwitch!
    @IBOutlet weak var receivingAudioSwitch: UISwitch!
    
    @IBOutlet weak var switchContainerView: UIView!
    @IBOutlet weak var avatarContainerView: UIImageView!
    
    @IBOutlet weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var remoteViewTop: NSLayoutConstraint!
    @IBOutlet weak var selfViewWidth: NSLayoutConstraint!
    @IBOutlet weak var selfViewHeight: NSLayoutConstraint!
    
    var call: Call!
    var remoteAddr = ""
    
    private var remoteDisplayName = ""
    private var remoteAvatarUrl = ""
    private var avatarImageView = UIImageView()
    private var remoteDisplayNameLabel = UILabel()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvata()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUIStatus()
        CallNotificationCenter.sharedInstance.addObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        CallNotificationCenter.sharedInstance.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        updateAvatarContainerView()
    }
    
    // MARK: - Landscape
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            remoteViewTop.constant = 0
            remoteViewHeight.constant = view.bounds.height
            selfViewWidth.constant = 100
            selfViewHeight.constant = 70
            homeButton.hidden = true
            disconnectionTypeLabel.hidden = true
            showCallControllView(false)
        } else {
            remoteViewTop.constant = 40
            remoteViewHeight.constant = 180
            selfViewWidth.constant = 70
            selfViewHeight.constant = 100
            homeButton.hidden = false
            disconnectionTypeLabel.hidden = !isCallDisconnected()
            showCallControllView(true)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateViewConstraints()
        updateAvatarContainerView()
    }
    
    // MARK: - CallObserver
    
    func callDidBeginRinging(call: Call) {
        updateUIStatus()
    }
    
    func callDidConnect(call: Call) {
        updateUIStatus()
    }
    
    func callDidDisconnect(call: Call, disconnectionType: DisconnectionType) {
        updateUIStatus()
        showDisconnectionType(disconnectionType)
        presentRateView()
    }
    
    func remoteMediaDidChange(call: Call, mediaChangeType: MediaChangeType) {
        updateAvatarViewVisibility()
    }
    
    // MARK: - Call control
    
    @IBAction func hangup(sender: AnyObject) {
        call.hangup() { success in
            if !success {
                print("Failed to hangup call.")
            } else {
                self.presentRateView()
            }
        }
    }
    
    @IBAction func toggleFacingMode(sender: AnyObject) {
        call.toggleFacingMode()
        facingModeSwitch.on = isFacingMode(call.facingMode)
    }
    
    @IBAction func toggleLoudSpeaker(sender: AnyObject) {
        call.toggleLoudSpeaker(!call.loudSpeaker)
        loudSpeakerSwitch.on = call.loudSpeaker
    }
    
    @IBAction func toggleSendingVideo(sender: AnyObject) {
        call.toggleSendingVideo()
        sendingVideoSwitch.on = call.sendingVideo
        showSelfView(sendingVideoSwitch.on)
    }
    
    @IBAction func toggleSendingAudio(sender: AnyObject) {
        call.toggleSendingAudio()
        sendingAudioSwitch.on = call.sendingAudio
    }
    
    @IBAction func toggleReceivingVideo(sender: AnyObject) {
        call.toggleReceivingVideo()
        receivingVideoSwitch.on = call.receivingVideo
        updateAvatarViewVisibility()
    }
    
    @IBAction func toggleReceivingAudio(sender: AnyObject) {
        call.toggleReceivingAudio()
        receivingAudioSwitch.on = call.receivingAudio
    }
    
    @IBAction func gotoHome(sender: AnyObject) {
        if isCallDisconnected() {
            dismissCallView()
        } else {
            showEndCallAlert()
        }
    }
    
    // MARK: - UI views
    
    private func setupAvata() {
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(remoteDisplayNameLabel)
        
        let profile = Utils.fetchUserProfile(remoteAddr)
        remoteDisplayName = profile.displayName
        remoteAvatarUrl = profile.avatarUrl
        
        fetchAvataImage()
    }
    
    private func updateUIStatus() {
        updateStatusLabel()
        updateSwitches()
        updateAvatarViewVisibility()
        
        if isCallDisconnected() {
            hideCallView()
        }
    }
    
    private func showDisconnectionType(type: DisconnectionType) {
        let disconnectionType = type.rawValue
        disconnectionTypeLabel.text = disconnectionTypeLabel.text! + disconnectionType
        disconnectionTypeLabel.hidden = false
    }
    
    private func updateStatusLabel() {
        statusLabel.text = call.status.rawValue
    }
    
    private func updateSwitches() {
        facingModeSwitch.on = isFacingMode(Spark.phone.defaultFacingMode)
        loudSpeakerSwitch.on = Spark.phone.defaultLoudSpeaker
        sendingVideoSwitch.on = call.sendingVideo
        sendingAudioSwitch.on = call.sendingAudio
        receivingVideoSwitch.on = call.receivingVideo
        receivingAudioSwitch.on = call.receivingAudio
        
        if !VideoAudioSetup.sharedInstance.isVideoEnabled() {
            facingModeSwitch.enabled = false
            sendingVideoSwitch.enabled = false
            receivingVideoSwitch.enabled = false
        }
    }
    
    private func updateAvatarContainerView() {
        avatarContainerView.image = UIImage(named: "Wallpaper")
        avatarContainerView.frame = remoteView.frame
        updateAvatarImageView()
    }
    
    private func updateAvatarImageView() {
        let w_avatar = avatarContainerView.frame.height/3
        let h_avatar = avatarContainerView.frame.height/3
        let x_avatar = (avatarContainerView.frame.width - w_avatar)/2
        let y_avatar = (avatarContainerView.frame.height - h_avatar)/2
        avatarImageView.frame = CGRectMake(x_avatar, y_avatar, w_avatar, h_avatar)
        avatarImageView.layer.cornerRadius = w_avatar/2
        avatarImageView.layer.masksToBounds = true
        
        let w_name = avatarContainerView.frame.width
        let h_name = (avatarContainerView.frame.height - h_avatar)/2
        let x_name = CGFloat(0)
        let y_name = avatarContainerView.frame.height - h_name
        remoteDisplayNameLabel.frame = CGRectMake(x_name, y_name, w_name, h_name)
        remoteDisplayNameLabel.text = remoteDisplayName
        remoteDisplayNameLabel.textAlignment = NSTextAlignment.Center
    }
    
    private func updateAvatarViewVisibility() {
        if !isCallConnected() {
            showAvatarContainerView(true)
            return
        }
        
        if !call.receivingVideo || !call.remoteSendingVideo {
            showAvatarContainerView(true)
            
        } else {
            showAvatarContainerView(false)
        }
    }
    
    private func fetchAvataImage() {
        Utils.downloadAvatarImage(remoteAvatarUrl, completionHandler: {
            self.avatarImageView.image = $0
        })
    }
    
    private func dismissCallView() {
        if presentingViewController!.isKindOfClass(UINavigationController) {
            let navigationController = presentingViewController as! UINavigationController
            dismissViewControllerAnimated(true, completion: nil)
            navigationController.popToRootViewControllerAnimated(true)
        }
    }
    
    private func hideCallView() {
        showSelfView(false)
        showCallControllView(false)
    }
    
    private func showSelfView(shown: Bool) {
        selfView.hidden = !shown
    }
    
    private func showCallControllView(shown: Bool) {
        if isCallDisconnected() {
            switchContainerView.hidden = true
            hangupButton.hidden = true
        } else {
            switchContainerView.hidden = !shown
            hangupButton.hidden = !shown
        }
    }
    
    private func showAvatarContainerView(shown: Bool) {
        avatarContainerView.hidden = !shown
    }
    
    private func presentRateView() {
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
    
    private func showEndCallAlert() {
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
    
    // MARK: - Utils
    
    private func isFacingMode(mode: Call.FacingMode) -> Bool {
        return mode == Call.FacingMode.User
    }
    
    private func isCallConnected() -> Bool {
        return call.status == Call.Status.Connected
    }
    
    private func isCallDisconnected() -> Bool {
        return call.status == Call.Status.Disconnected
    }
}

