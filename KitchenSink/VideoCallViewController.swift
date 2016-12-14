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

class VideoCallViewController: UIViewController, CallObserver {
    
    @IBOutlet private weak var selfView: MediaRenderView!
    @IBOutlet private weak var remoteView: MediaRenderView!
    
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var disconnectionTypeLabel: UILabel!
    
    @IBOutlet private weak var hangupButton: UIButton!
    @IBOutlet private weak var homeButton: UIButton!
    @IBOutlet private weak var dialpadButton: UIButton!
    @IBOutlet private weak var dialpadView: UICollectionView!
    
    @IBOutlet private weak var facingModeSwitch: UISwitch!
    @IBOutlet private weak var loudSpeakerSwitch: UISwitch!
    @IBOutlet private weak var sendingVideoSwitch: UISwitch!
    @IBOutlet private weak var sendingAudioSwitch: UISwitch!
    @IBOutlet private weak var receivingVideoSwitch: UISwitch!
    @IBOutlet private weak var receivingAudioSwitch: UISwitch!
    
    @IBOutlet private weak var switchContainerView: UIView!
    @IBOutlet private weak var avatarContainerView: UIImageView!
    
    @IBOutlet private weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var remoteViewTop: NSLayoutConstraint!
    @IBOutlet private weak var selfViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var selfViewHeight: NSLayoutConstraint!
    
	var localVideoView: MediaRenderView {
		_ = view
		return selfView
	}
	
	var remoteVideoView: MediaRenderView {
		_ = view
		return remoteView
	}
	
    var call: Call!
    var remoteAddr = ""
    
    private var remoteDisplayName = ""
    private var remoteAvatarUrl = ""
    private var avatarImageView = UIImageView()
    private var remoteDisplayNameLabel = UILabel()
    private var spark: Spark!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spark = AppDelegate.spark
        setupAvata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIStatus()
        spark.callNotificationCenter.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spark.callNotificationCenter.remove(observer: self)
    }
    
    override func viewDidLayoutSubviews() {
        updateAvatarContainerView()
    }
    
    // MARK: - Landscape
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if UIDevice.current.orientation.isLandscape {
            remoteViewTop.constant = 0
            remoteViewHeight.constant = view.bounds.height
            selfViewWidth.constant = 100
            selfViewHeight.constant = 70
            homeButton.isHidden = true
            disconnectionTypeLabel.isHidden = true
            showCallControllView(false)
        } else {
            remoteViewTop.constant = 40
            remoteViewHeight.constant = 180
            selfViewWidth.constant = 70
            selfViewHeight.constant = 100
            homeButton.isHidden = false
            disconnectionTypeLabel.isHidden = !isCallDisconnected()
            showCallControllView(true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateViewConstraints()
        updateAvatarContainerView()
    }
    
    // MARK: - CallObserver
    
    func callDidBeginRinging(_ call: Call) {
        updateUIStatus()
    }
    
    func callDidConnect(_ call: Call) {
        updateUIStatus()
    }
    
    func callDidDisconnect(_ call: Call, disconnectionType: DisconnectionType) {
        updateUIStatus()
        showDisconnectionType(disconnectionType)
        presentRateView()
    }
    
    func remoteMediaDidChange(_ call: Call, remoteMediaChangeType: RemoteMediaChangeType) {
        updateAvatarViewVisibility()
        
        if (remoteMediaChangeType == .remoteVideoOutputMuted) {
            receivingVideoSwitch.isOn = false
        } else if (remoteMediaChangeType == .remoteVideoOutputUnmuted) {
            receivingVideoSwitch.isOn = true
        }
        
        if (remoteMediaChangeType == .remoteAudioOutputMuted) {
            receivingAudioSwitch.isOn = false
        } else if (remoteMediaChangeType == .remoteAudioOutputUnmuted) {
            receivingAudioSwitch.isOn = true
        }
    }
    
    func localMediaDidChange(_ call: Call, localMediaChangeType: LocalMediaChangeType) {
        switch localMediaChangeType {
        case .localVideoMuted:
            sendingVideoSwitch.isOn = false
        case .localVideoUnmuted:
            sendingVideoSwitch.isOn = true
        case .localAudioMuted:
            sendingAudioSwitch.isOn = false
        case .localAudioUnmuted:
            sendingAudioSwitch.isOn = true
        }
    }
    
    func facingModeDidChange(_ call: Call, facingMode: Call.FacingMode) {
        facingModeSwitch.isOn = isFacingModeUser(call.facingMode)
    }
    
    func loudSpeakerDidChange(_ call: Call, isLoudSpeakerSelected: Bool) {
        loudSpeakerSwitch.isOn = isLoudSpeakerSelected
    }
    
    func enableDTMFDidChange(_ call: Call, sendingDTMFEnabled: Bool) {
        hideDialpadButton(!sendingDTMFEnabled)
    }
    
    // MARK: - Call control
    
    @IBAction private func hangup(_ sender: AnyObject) {
        call.hangup() { success in
            if !success {
                print("Failed to hangup call.")
                self.dismissCallView()
            } else {
                self.presentRateView()
            }
        }
    }
    
    @IBAction private func toggleFacingMode(_ sender: AnyObject) {
        call.toggleFacingMode()
        facingModeSwitch.isOn = isFacingModeUser(call.facingMode)
    }
    
    @IBAction private func toggleLoudSpeaker(_ sender: AnyObject) {
        call.toggleLoudSpeaker()
        loudSpeakerSwitch.isOn = call.loudSpeaker
    }
    
    @IBAction private func toggleSendingVideo(_ sender: AnyObject) {
        call.toggleSendingVideo()
        sendingVideoSwitch.isOn = call.sendingVideo
        showSelfView(sendingVideoSwitch.isOn)
    }
    
    @IBAction private func toggleSendingAudio(_ sender: AnyObject) {
        call.toggleSendingAudio()
        sendingAudioSwitch.isOn = call.sendingAudio
    }
    
    @IBAction private func toggleReceivingVideo(_ sender: AnyObject) {
        call.toggleReceivingVideo()
        receivingVideoSwitch.isOn = call.receivingVideo
        updateAvatarViewVisibility()
    }
    
    @IBAction private func toggleReceivingAudio(_ sender: AnyObject) {
        call.toggleReceivingAudio()
        receivingAudioSwitch.isOn = call.receivingAudio
    }
    
    @IBAction private func gotoHome(_ sender: AnyObject) {
        if isCallDisconnected() {
            dismissCallView()
        } else {
            showEndCallAlert()
        }
    }
    
    @IBAction func pressDialpadButton(_ sender: AnyObject) {
        hideDialpadView(!dialpadView.isHidden)
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
        hideDialpadButton(!call.sendingDTMFEnabled)
        hideDialpadView(true)
        updateSelfViewVisibility()
        
        if isCallDisconnected() {
            hideCallView()
        }
    }
    
    private func showDisconnectionType(_ type: DisconnectionType) {
        let disconnectionType = type.rawValue
        disconnectionTypeLabel.text = disconnectionTypeLabel.text! + disconnectionType
        disconnectionTypeLabel.isHidden = false
    }
    
    private func updateStatusLabel() {
        statusLabel.text = call.status.rawValue
    }
    
    private func updateSwitches() {
        facingModeSwitch.isOn = isFacingModeUser(call.facingMode)
        loudSpeakerSwitch.isOn = call.loudSpeaker
        sendingVideoSwitch.isOn = call.sendingVideo
        sendingAudioSwitch.isOn = call.sendingAudio
        receivingVideoSwitch.isOn = call.receivingVideo
        receivingAudioSwitch.isOn = call.receivingAudio
        
        if !VideoAudioSetup.sharedInstance.isVideoEnabled() {
            facingModeSwitch.isEnabled = false
            sendingVideoSwitch.isEnabled = false
            receivingVideoSwitch.isEnabled = false
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
        avatarImageView.frame = CGRect(x: x_avatar, y: y_avatar, width: w_avatar, height: h_avatar)
        avatarImageView.layer.cornerRadius = w_avatar/2
        avatarImageView.layer.masksToBounds = true
        
        let w_name = avatarContainerView.frame.width
        let h_name = (avatarContainerView.frame.height - h_avatar)/2
        let x_name = CGFloat(0)
        let y_name = avatarContainerView.frame.height - h_name
        remoteDisplayNameLabel.frame = CGRect(x: x_name, y: y_name, width: w_name, height: h_name)
        remoteDisplayNameLabel.text = remoteDisplayName
        remoteDisplayNameLabel.textAlignment = NSTextAlignment.center
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
    
    private func updateSelfViewVisibility() {
        showSelfView(call.sendingVideo)
    }
    
    private func fetchAvataImage() {
        Utils.downloadAvatarImage(remoteAvatarUrl, completionHandler: {
            self.avatarImageView.image = $0
        })
    }
    
    private func dismissCallView() {
        if presentingViewController!.isKind(of: UINavigationController.self) {
            let navigationController = presentingViewController as! UINavigationController
            dismiss(animated: true, completion: nil)
            navigationController.popViewController(animated: true)
        }
    }
    
    private func hideCallView() {
        showSelfView(false)
        showCallControllView(false)
    }
    
    private func showSelfView(_ shown: Bool) {
        selfView.isHidden = !shown
    }
    
    private func showCallControllView(_ shown: Bool) {
        if isCallDisconnected() {
            switchContainerView.isHidden = true
            hangupButton.isHidden = true
        } else {
            switchContainerView.isHidden = !shown
            hangupButton.isHidden = !shown
            hideDialpadButton(!shown)
        }
    }
    
    private func showAvatarContainerView(_ shown: Bool) {
        avatarContainerView.isHidden = !shown
    }
    
    private func hideDialpadView(_ hidden: Bool) {
        dialpadView.isHidden = hidden
    }
    
    private func hideDialpadButton(_ hidden: Bool) {
        dialpadButton.isHidden = hidden
        if hidden {
            hideDialpadView(true)
        }
    }
    
    private func presentRateView() {
        let rateViewController = storyboard?.instantiateViewController(withIdentifier: "CallFeedbackViewController") as! CallFeedbackViewController
        rateViewController.call = self.call
        rateViewController.modalPresentationStyle = .fullScreen
        present(rateViewController, animated: true, completion: nil)
        if let popoverController = rateViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .any
        }
    }
    
    private func showEndCallAlert() {
        let alert = UIAlertController(title: nil, message: "Do you want to end current call?", preferredStyle: .alert)
        
        let endCallHandler = {
            (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            self.call.hangup(nil)
            self.dismissCallView()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End call", style: .default, handler: endCallHandler))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Utils
    
    private func isFacingModeUser(_ mode: Call.FacingMode) -> Bool {
        return mode == Call.FacingMode.User
    }
    
    private func isCallConnected() -> Bool {
        return call.status == Call.Status.Connected
    }
    
    private func isCallDisconnected() -> Bool {
        return call.status == Call.Status.Disconnected
    }
}

// MARK: - DTMF dialpad view

extension VideoCallViewController : UICollectionViewDataSource {
	private static let DTMFKeys = ["1", "2", "3", "A", "4", "5", "6", "B", "7", "8", "9", "C", "*", "0", "#", "D"]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoCallViewController.DTMFKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialpadCell", for: indexPath)
        
        let dialButton = cell.viewWithTag(105) as! UILabel
        dialButton.text = VideoCallViewController.DTMFKeys[indexPath.item]
        dialButton.layer.borderColor = UIColor.gray.cgColor;
        return cell
    }
}

extension VideoCallViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.alpha = 0.7
            }, completion: { (finished: Bool) -> Void in
                cell?.alpha = 1
        })
        
        let dialButton = cell!.viewWithTag(105) as! UILabel
        let dtmfEvent = dialButton.text
		call.send(dtmf: dtmfEvent!, completionHandler: nil)
    }
}
