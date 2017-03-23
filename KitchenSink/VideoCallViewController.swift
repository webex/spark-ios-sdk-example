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
import Toast_Swift

enum VideoCallRole {
    case Caller(String)
    case Callee(String)
}


class VideoCallViewController: BaseViewController, CallObserver {
    
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
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet private weak var switchContainerView: UIView!
    @IBOutlet private weak var avatarContainerView: UIImageView!
    
    
    @IBOutlet private weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var remoteViewTop: NSLayoutConstraint!
    @IBOutlet private weak var selfViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var selfViewHeight: NSLayoutConstraint!
    
    var videoCallRole :VideoCallRole = .Callee("")
    
    private var isFullScreen: Bool = false
    private let avatarImageView = UIImageView()
    private var avatarImageViewHeightConstraint: NSLayoutConstraint!
    private let remoteDisplayNameLabel = UILabel()
    private var rateViewController: CallFeedbackViewController?
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var remoteAddr = ""
        switch videoCallRole {
        case .Callee(let remoteAddress):
            remoteAddr = remoteAddress
            didAnswerIncomingCall()
        case .Caller(let remoteAddress):
            remoteAddr = remoteAddress
            dial(remoteAddress)
            
        }
        setupAvatarView(remoteAddr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIStatus()
        SparkContext.sharedInstance.spark?.callNotificationCenter.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (navigationController?.isNavigationBarHidden ?? false) == true {
            navigationController?.isNavigationBarHidden = false
        }
        SparkContext.sharedInstance.spark?.callNotificationCenter.remove(observer: self)
    }
    
    override func viewDidLayoutSubviews() {
        updateAvatarContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    deinit {
        self.rateViewController = nil
        SparkContext.sharedInstance.deinitCall()
    }
    
    // MARK: - Landscape
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    private func viewOrientationChange(_ isLandscape:Bool,with size:CGSize) {
        if isLandscape {
            fullScreenLandscape(size.height)
            isFullScreen = true
        }
        else if isFullScreen {
            fullScreenPortrait(size.height)
        }
        else {
            normalSizePortrait()
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewOrientationChange(UIDevice.current.orientation.isLandscape,with:size)
        updateAvatarContainerView()
    }
    
    // MARK: - CallObserver
    
    func callDidBeginRinging(_ call: Call) {
        updateUIStatus()
    }
    
    func callDidConnect(_ call: Call) {
        updateUIStatus()
    }
    
    func remoteViewSizeDidChange(_ call: Call, height: UInt32, width: UInt32) {

    }
    
    func callDidDisconnect(_ call: Call, disconnectionType: DisconnectionType) {
        updateUIStatus()
        showDisconnectionType(disconnectionType)
        presentRateView()
    }
    
    func remoteMediaDidChange(_ call: Call, remoteMediaChangeType: RemoteMediaChangeType) {
        print("remoteMediaDidChange Entering")
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
        print("remoteMediaDidChange out")
    }
    
    func localMediaDidChange(_ call: Call, localMediaChangeType: LocalMediaChangeType) {
        print("localMediaDidChange Entering")
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
        print("localMediaDidChange out")
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
        SparkContext.sharedInstance.call?.hangup() { [weak self] success in
            if !success {
                
                self?.view.makeToast("Failed to hangup call.", duration: 2, position: ToastPosition.center, title: nil, image: nil, style: nil)
                { bRet in
                    _ = self?.navigationController?.popViewController(animated: true)
                }
                print("Failed to hangup call.")
                
            } else {
                self?.presentRateView()
            }
        }
    }
    
    @IBAction private func toggleFacingMode(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleFacingMode()
        facingModeSwitch.isOn = isFacingModeUser(SparkContext.sharedInstance.call?.facingMode ?? .User)
    }
    
    @IBAction private func toggleLoudSpeaker(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleLoudSpeaker()
        loudSpeakerSwitch.isOn = SparkContext.sharedInstance.call?.loudSpeaker ?? true
    }
    
    @IBAction private func toggleSendingVideo(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleSendingVideo()
        sendingVideoSwitch.isOn = SparkContext.sharedInstance.call?.sendingVideo ?? true
        showSelfView(sendingVideoSwitch.isOn)
    }
    
    @IBAction private func toggleSendingAudio(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleSendingAudio()
        sendingAudioSwitch.isOn = SparkContext.sharedInstance.call?.sendingAudio ?? true
    }
    
    @IBAction private func toggleReceivingVideo(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleReceivingVideo()
        receivingVideoSwitch.isOn = SparkContext.sharedInstance.call?.receivingVideo ?? true
        updateAvatarViewVisibility()
    }
    
    @IBAction private func toggleReceivingAudio(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.toggleReceivingAudio()
        receivingAudioSwitch.isOn = SparkContext.sharedInstance.call?.receivingAudio ?? true
    }
    @IBAction func fullScreenButtonTouchUpInside(_ sender: Any) {
        isFullScreen = !isFullScreen
        if isFullScreen {
            fullScreenPortrait(UIScreen.main.bounds.height)
        }
        else {
            normalSizePortrait()
            
        }
    }
    
    @IBAction private func gotoHome(_ sender: AnyObject) {
        if isCallDisconnected() {
            _ = navigationController?.popViewController(animated: true)
        } else {
            showEndCallAlert()
        }
    }
    
    @IBAction func pressDialpadButton(_ sender: AnyObject) {
        hideDialpadView(!dialpadView.isHidden)
    }
    
    // MARK: - UI views
    
    private func setupAvatarView(_ remoteAddr: String) {
        avatarImageView.image = UIImage(named: "DefaultAvatar")
        avatarImageView.layer.masksToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        remoteDisplayNameLabel.text = remoteAddr
        remoteDisplayNameLabel.textAlignment = NSTextAlignment.center
        remoteDisplayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(remoteDisplayNameLabel)
        
        
        let avatarImageViewCenterXConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .centerX, relatedBy: .equal, toItem: avatarContainerView, attribute: .centerX, multiplier: 1, constant: 0)
        let avatarImageViewCenterYConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .centerY, relatedBy: .equal, toItem: avatarContainerView, attribute: .centerY, multiplier: 1, constant: 0)
        
        avatarImageViewHeightConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: remoteViewHeight.constant/3)
        let avatarImageViewWidthConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .width, relatedBy: .equal, toItem: avatarImageView, attribute: .height, multiplier: 1, constant: 0)
        
        let remoteDisplayNameLabelLeadingConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .leading, relatedBy: .equal, toItem: avatarContainerView, attribute: .leading, multiplier: 1, constant: 0)
        let remoteDisplayNameLabelTrailingConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .trailing, relatedBy: .equal, toItem: avatarContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        let remoteDisplayNameLabelHeightConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 21)
        let remoteDisplayNameLabelTopConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .top, relatedBy: .equal, toItem: avatarImageView, attribute: .bottom, multiplier: 1, constant: 20)
        
        remoteDisplayNameLabel.addConstraint(remoteDisplayNameLabelHeightConstraint)
        
        avatarContainerView.addConstraint(avatarImageViewCenterXConstraint)
        avatarContainerView.addConstraint(avatarImageViewCenterYConstraint)
        avatarContainerView.addConstraint(remoteDisplayNameLabelLeadingConstraint)
        avatarContainerView.addConstraint(remoteDisplayNameLabelTrailingConstraint)
        avatarContainerView.addConstraint(remoteDisplayNameLabelTopConstraint)
        avatarImageView.addConstraint(avatarImageViewHeightConstraint)
        avatarImageView.addConstraint(avatarImageViewWidthConstraint)
        
        view.setNeedsUpdateConstraints()
        
        if remoteAddr.isEmpty {
            return
        }
        
        Utils.fetchUserProfile(remoteAddr) { [weak self] (displayName: String, avatarUrl: String) in
            if let strongSelf = self {
                strongSelf.remoteDisplayNameLabel.text = displayName
                strongSelf.fetchAvatarImage(avatarUrl)
            }
        }
    }
    private func updateAvatarContainerView() {
        avatarImageViewHeightConstraint.constant = remoteViewHeight.constant/3
        avatarImageView.layer.cornerRadius = avatarImageViewHeightConstraint.constant/2
    }

    private func fetchAvatarImage(_ avatarUrl: String) {
        Utils.downloadAvatarImage(avatarUrl) { [weak self] image in
            if let strongSelf = self {
                strongSelf.avatarImageView.image = image
            }
        }
    }
    
    private func updateAvatarViewVisibility() {
        guard SparkContext.sharedInstance.call != nil else {
            return
        }
        if !isCallConnected() {
            showAvatarContainerView(true)
            return
        }
        
        if !(SparkContext.sharedInstance.call!.receivingVideo) || !(SparkContext.sharedInstance.call!.remoteSendingVideo) {
            showAvatarContainerView(true)
        } else {
            showAvatarContainerView(false)
        }
    }
    
    
    
    private func updateUIStatus() {
        updateStatusLabel()
        updateSwitches()
        updateAvatarViewVisibility()
        hideDialpadButton(!(SparkContext.sharedInstance.call?.sendingDTMFEnabled ?? false))
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
        statusLabel.text = SparkContext.sharedInstance.call?.status.rawValue
    }
    
    private func updateSwitches() {
        facingModeSwitch.isOn = isFacingModeUser(SparkContext.sharedInstance.call?.facingMode ?? .User)
        loudSpeakerSwitch.isOn = SparkContext.sharedInstance.call?.loudSpeaker ?? true
        sendingVideoSwitch.isOn = SparkContext.sharedInstance.call?.sendingVideo ?? true
        sendingAudioSwitch.isOn = SparkContext.sharedInstance.call?.sendingAudio ?? true
        receivingVideoSwitch.isOn = SparkContext.sharedInstance.call?.receivingVideo ?? true
        receivingAudioSwitch.isOn = SparkContext.sharedInstance.call?.receivingAudio ?? true
        
        if !VideoAudioSetup.sharedInstance.isVideoEnabled() {
            facingModeSwitch.isEnabled = false
            sendingVideoSwitch.isEnabled = false
            receivingVideoSwitch.isEnabled = false
        }
    }
    
    private func updateSelfViewVisibility() {
        showSelfView(SparkContext.sharedInstance.call?.sendingVideo ?? false)
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
        if !hidden {
            let DTMFenabled = SparkContext.sharedInstance.call?.sendingDTMFEnabled ?? false
            dialpadButton.isHidden = !DTMFenabled
        }
        else {
            dialpadButton.isHidden = hidden
        }
        if hidden {
            hideDialpadView(true)
        }
    }
    
    private func presentRateView() {
        guard rateViewController == nil else {
            return
        }
        
        rateViewController = storyboard?.instantiateViewController(withIdentifier: "CallFeedbackViewController") as? CallFeedbackViewController
        rateViewController?.modalPresentationStyle = .fullScreen
        rateViewController?.modalTransitionStyle = .coverVertical
        rateViewController?.dissmissBlock = { [weak self] in
            if let strongSelf = self {
                _ = strongSelf.navigationController?.popViewController(animated: true)
            }
        }
        
        present(rateViewController!, animated: true, completion: nil)
    }
    
    private func showEndCallAlert() {
        let alert = UIAlertController(title: nil, message: "Do you want to end current call?", preferredStyle: .alert)
        
        let endCallHandler = {
            (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            SparkContext.sharedInstance.call?.hangup(nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End call", style: .default, handler: endCallHandler))
        present(alert, animated: true, completion: nil)
    }
    
    private func fullScreenLandscape(_ height:CGFloat) {
        remoteViewTop.constant = 0
        remoteViewHeight.constant = height
        print("remoteView set to screen bounds:\(UIScreen.main.bounds)")
        selfViewWidth.constant = 100
        selfViewHeight.constant = 70
        hideControlView(true)
        fullScreenButton.isHidden = true
    }
    private func fullScreenPortrait(_ height:CGFloat) {
        remoteViewTop.constant = 0
        remoteViewHeight.constant = height
        print("remoteView set to screen bounds:\(UIScreen.main.bounds)")
        selfViewWidth.constant = 70
        selfViewHeight.constant = 100
        hideControlView(true)
        fullScreenButton.isHidden = false
        fullScreenButton.setBackgroundImage(UIImage.init(named: "normalScreen"), for: UIControlState.normal)
        
    }
    private func normalSizePortrait() {
        remoteViewTop.constant = 40
        remoteViewHeight.constant = 180
        selfViewWidth.constant = 70
        selfViewHeight.constant = 100
        hideControlView(false)
        fullScreenButton.isHidden = false
        fullScreenButton.setBackgroundImage(UIImage.init(named: "fullScreen"), for: UIControlState.normal)
    }
    private func hideControlView(_ isHidden: Bool) {
        fullScreenButton.isHidden = UIDevice.current.orientation.isLandscape
        homeButton.isHidden = isHidden
        disconnectionTypeLabel.isHidden = (isHidden == false ? !isCallDisconnected():isHidden)
        showCallControllView(!isHidden)
        navigationController?.isNavigationBarHidden = isHidden
    }
    
    // MARK: - Utils
    func dial(_ remoteAddr: String) {
        if remoteAddr.isEmpty {
            return
        }
        
        SparkContext.sharedInstance.spark?.phone.requestMediaAccess(Phone.MediaAccessType.audioVideo) { granted in
            if granted {
                
                var mediaOption = MediaOption.audioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.audioVideo(local: self.selfView, remote: self.remoteView)
                }
                SparkContext.sharedInstance.call = SparkContext.sharedInstance.spark?.phone.dial(remoteAddr, option: mediaOption) { success in
                    if !success {
                        _ = self.navigationController?.popViewController(animated: true)
                        print("Failed to dial call.")
                    }
                }
            } else {
                Utils.showCameraMicrophoneAccessDeniedAlert(self)
            }
        }
    }
    
    func didAnswerIncomingCall() {
        SparkContext.sharedInstance.spark?.phone.requestMediaAccess(Phone.MediaAccessType.audioVideo) { granted in
            if granted {
                
                var mediaOption = MediaOption.audioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.audioVideo(local: self.selfView, remote: self.remoteView)
                }
                SparkContext.sharedInstance.call?.answer(option: mediaOption) { success in
                    if !success {
                        _ = self.navigationController?.popViewController(animated: true)
                        SparkContext.sharedInstance.call?.reject(nil)
                    }
                }
            } else {
                SparkContext.sharedInstance.call?.reject(nil)
                Utils.showCameraMicrophoneAccessDeniedAlert(self)
            }
        }
    }
    
    
    private func isFacingModeUser(_ mode: Call.FacingMode) -> Bool {
        return mode == Call.FacingMode.User
    }
    
    private func isCallConnected() -> Bool {
        return SparkContext.sharedInstance.call?.status == Call.Status.Connected
    }
    
    private func isCallDisconnected() -> Bool {
        return SparkContext.sharedInstance.call?.status == Call.Status.Disconnected
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return navigationController!.isNavigationBarHidden
        }
    }
    
    // MARK: - Orientation manage
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
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
        SparkContext.sharedInstance.call?.send(dtmf: dtmfEvent!, completionHandler: nil)
    }
}
