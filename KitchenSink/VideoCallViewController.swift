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
    
    @IBOutlet weak var selfView: MediaRenderView!
    @IBOutlet weak var remoteView: MediaRenderView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var disconnectionTypeLabel: UILabel!
    
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var dialpadButton: UIButton!
    @IBOutlet weak var dialpadView: UICollectionView!
    
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
    
    fileprivate var remoteDisplayName = ""
    fileprivate var remoteAvatarUrl = ""
    fileprivate var avatarImageView = UIImageView()
    fileprivate var remoteDisplayNameLabel = UILabel()
    fileprivate let DTMFKeys = ["1", "2", "3", "A", "4", "5", "6", "B", "7", "8", "9", "C", "*", "0", "#", "D"]
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
    
    @IBAction func hangup(_ sender: AnyObject) {
        call.hangup() { success in
            if !success {
                print("Failed to hangup call.")
                self.dismissCallView()
            } else {
                self.presentRateView()
            }
        }
    }
    
    @IBAction func toggleFacingMode(_ sender: AnyObject) {
        call.toggleFacingMode()
        facingModeSwitch.isOn = isFacingModeUser(call.facingMode)
    }
    
    @IBAction func toggleLoudSpeaker(_ sender: AnyObject) {
        call.toggleLoudSpeaker()
        loudSpeakerSwitch.isOn = call.loudSpeaker
    }
    
    @IBAction func toggleSendingVideo(_ sender: AnyObject) {
        call.toggleSendingVideo()
        sendingVideoSwitch.isOn = call.sendingVideo
        showSelfView(sendingVideoSwitch.isOn)
    }
    
    @IBAction func toggleSendingAudio(_ sender: AnyObject) {
        call.toggleSendingAudio()
        sendingAudioSwitch.isOn = call.sendingAudio
    }
    
    @IBAction func toggleReceivingVideo(_ sender: AnyObject) {
        call.toggleReceivingVideo()
        receivingVideoSwitch.isOn = call.receivingVideo
        updateAvatarViewVisibility()
    }
    
    @IBAction func toggleReceivingAudio(_ sender: AnyObject) {
        call.toggleReceivingAudio()
        receivingAudioSwitch.isOn = call.receivingAudio
    }
    
    @IBAction func gotoHome(_ sender: AnyObject) {
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
    
    fileprivate func setupAvata() {
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(remoteDisplayNameLabel)
        
        let profile = Utils.fetchUserProfile(remoteAddr)
        remoteDisplayName = profile.displayName
        remoteAvatarUrl = profile.avatarUrl
        
        fetchAvataImage()
    }
    
    fileprivate func updateUIStatus() {
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
    
    fileprivate func showDisconnectionType(_ type: DisconnectionType) {
        let disconnectionType = type.rawValue
        disconnectionTypeLabel.text = disconnectionTypeLabel.text! + disconnectionType
        disconnectionTypeLabel.isHidden = false
    }
    
    fileprivate func updateStatusLabel() {
        statusLabel.text = call.status.rawValue
    }
    
    fileprivate func updateSwitches() {
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
    
    fileprivate func updateAvatarContainerView() {
        avatarContainerView.image = UIImage(named: "Wallpaper")
        avatarContainerView.frame = remoteView.frame
        updateAvatarImageView()
    }
    
    fileprivate func updateAvatarImageView() {
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
    
    fileprivate func updateAvatarViewVisibility() {
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
    
    fileprivate func updateSelfViewVisibility() {
        showSelfView(call.sendingVideo)
    }
    
    fileprivate func fetchAvataImage() {
        Utils.downloadAvatarImage(remoteAvatarUrl, completionHandler: {
            self.avatarImageView.image = $0
        })
    }
    
    fileprivate func dismissCallView() {
        if presentingViewController!.isKind(of: UINavigationController.self) {
            let navigationController = presentingViewController as! UINavigationController
            dismiss(animated: true, completion: nil)
            navigationController.popViewController(animated: true)
        }
    }
    
    fileprivate func hideCallView() {
        showSelfView(false)
        showCallControllView(false)
    }
    
    fileprivate func showSelfView(_ shown: Bool) {
        selfView.isHidden = !shown
    }
    
    fileprivate func showCallControllView(_ shown: Bool) {
        if isCallDisconnected() {
            switchContainerView.isHidden = true
            hangupButton.isHidden = true
        } else {
            switchContainerView.isHidden = !shown
            hangupButton.isHidden = !shown
            hideDialpadButton(!shown)
        }
    }
    
    fileprivate func showAvatarContainerView(_ shown: Bool) {
        avatarContainerView.isHidden = !shown
    }
    
    fileprivate func hideDialpadView(_ hidden: Bool) {
        dialpadView.isHidden = hidden
    }
    
    fileprivate func hideDialpadButton(_ hidden: Bool) {
        dialpadButton.isHidden = hidden
        if hidden {
            hideDialpadView(true)
        }
    }
    
    fileprivate func presentRateView() {
        let rateViewController = storyboard?.instantiateViewController(withIdentifier: "CallFeedbackViewController") as! CallFeedbackViewController
        rateViewController.call = self.call
        rateViewController.modalPresentationStyle = .fullScreen
        self.present(rateViewController, animated: true, completion: nil)
        if let popoverController = rateViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .any
        }
    }
    
    fileprivate func showEndCallAlert() {
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
    
    fileprivate func isFacingModeUser(_ mode: Call.FacingMode) -> Bool {
        return mode == Call.FacingMode.User
    }
    
    fileprivate func isCallConnected() -> Bool {
        return call.status == Call.Status.Connected
    }
    
    fileprivate func isCallDisconnected() -> Bool {
        return call.status == Call.Status.Disconnected
    }
}

// MARK: - DTMF dialpad view

extension VideoCallViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DTMFKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialpadCell", for: indexPath)
        
        let dialButton = cell.viewWithTag(105) as! UILabel
        dialButton.text = DTMFKeys[indexPath.item]
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
