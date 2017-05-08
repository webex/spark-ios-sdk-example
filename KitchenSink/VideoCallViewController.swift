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
import Toast_Swift

enum VideoCallRole {
    case Caller(String)
    case Callee(String)
}


class VideoCallViewController: BaseViewController {
    
    @IBOutlet private weak var selfView: MediaRenderView!
    @IBOutlet private weak var remoteView: MediaRenderView!
    
    @IBOutlet private weak var disconnectionTypeLabel: UILabel!
    @IBOutlet private weak var hangupButton: UIButton!
    @IBOutlet private weak var dialpadButton: UIButton!
    @IBOutlet private weak var dialpadView: UICollectionView!
    
    @IBOutlet weak var loudSpeakerSwitch: UISwitch!
    @IBOutlet weak var frontCameraView: UIView!
    
    @IBOutlet weak var frontCameraImage: UIImageView!
    @IBOutlet weak var backCameraView: UIView!
    @IBOutlet weak var backCameraImage: UIImageView!
    
    @IBOutlet private weak var sendingVideoSwitch: UISwitch!
    @IBOutlet private weak var sendingAudioSwitch: UISwitch!
    @IBOutlet private weak var receivingVideoSwitch: UISwitch!
    @IBOutlet private weak var receivingAudioSwitch: UISwitch!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet private weak var switchContainerView: UIView!
    @IBOutlet private weak var avatarContainerView: UIImageView!
    
    
    @IBOutlet private weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var selfViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var selfViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet var dialpadViewWidth: NSLayoutConstraint!
    @IBOutlet var dialpadViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    override var navigationTitle: String? {
        get {
            return "Call status:\(self.title ?? "Unkonw")"
        }
        set(newValue) {
            title = newValue
            if let titleLabel = navigationItem.titleView as? UILabel {
                titleLabel.text = "Call status:\(self.title ?? "Unkonw")"
                titleLabel.sizeToFit()
                
            }
        }
    }
    
    var videoCallRole :VideoCallRole = .Callee("")
    private var callStatus:CallStatus = .initiated
    private var isFullScreen: Bool = false
    private let avatarImageView = UIImageView()
    private var avatarImageViewHeightConstraint: NSLayoutConstraint!
    private let remoteDisplayNameLabel = UILabel()
    private var rateViewController: CallFeedbackViewController?
    private let fullScreenImage = UIImage.fontAwesomeIcon(name: .expand, textColor: UIColor.white, size: CGSize.init(width: 44, height: 44))
    private let normalScreenImage = UIImage.fontAwesomeIcon(name: .compress, textColor: UIColor.white, size: CGSize.init(width: 44, height: 44))
    
    private let uncheckImage = UIImage.fontAwesomeIcon(name: .squareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))
    private let checkImage = UIImage.fontAwesomeIcon(name: .checkSquareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))
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
        
        //call callback init
        sparkCallBackInit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (navigationController?.isNavigationBarHidden ?? false) == true {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        updateAvatarContainerView()
    }
    
    deinit {
        self.rateViewController = nil
        SparkContext.sharedInstance.deinitCall()
    }
    
    override func goBack() {
        if isCallDisconnected() {
            _ = navigationController?.popViewController(animated: true)
        } else {
            showEndCallAlert()
        }
    }
    // MARK: - Landscape
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
    
    // MARK: - Call call back
    func sparkCallBackInit() {
        if let call = SparkContext.sharedInstance.call {
            call.onRinging = { [weak self] in
                if let strongSelf = self {
                    strongSelf.callStatus = .ringing
                    strongSelf.updateUIStatus()
                }
            }
            call.onConnected = { [weak self] in
                if let strongSelf = self {
                    strongSelf.callStatus = .connected
                    strongSelf.updateUIStatus()
                    if VideoAudioSetup.sharedInstance.isVideoEnabled() && !VideoAudioSetup.sharedInstance.isSelfViewShow {
                        strongSelf.toggleSendingVideo(strongSelf.sendingVideoSwitch)
                    }
                }
                
            }
            
            call.onDisconnected = {[weak self] disconnectionType in
                if let strongSelf = self {
                    strongSelf.callStatus = .disconnected
                    strongSelf.updateUIStatus()
                    strongSelf.navigationTitle = "Disconnected"
                    strongSelf.showDisconnectionType(disconnectionType)
                    strongSelf.presentRateView()
                }
            }

            call.onMediaChanged = {[weak self] mediaChangeType in
                if let strongSelf = self {
                    print("remoteMediaDidChange Entering")
                    strongSelf.updateAvatarViewVisibility()
                    switch mediaChangeType {
                    case .localVideoViewSize,.remoteVideoViewSize:
                        break
                    case .remoteSendingAudio(let isSending):
                        strongSelf.receivingAudioSwitch.isOn = isSending
                    case .remoteSendingVideo(let isSending):
                        strongSelf.receivingVideoSwitch.isOn = isSending
                    case .sendingAudio(let isSending):
                        strongSelf.sendingAudioSwitch.isOn = isSending
                    case .sendingVideo(let isSending):
                        strongSelf.sendingVideoSwitch.isOn = isSending
                    case .cameraSwitched:
                        strongSelf.updateCheckBoxStatus()
                    case .spearkerSwitched:
                        strongSelf.loudSpeakerSwitch.isOn = call.isSpeaker
                    default:
                        break
                    }
                    print("remoteMediaDidChange out")
                }
            }
        }
    }
    
    // MARK: - Call control
    
    @IBAction private func hangup(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.hangup() { [weak self] error in
            if let strongSelf = self {
                if error != nil {
                    strongSelf.view.makeToast("Call statue error:\(error!)", duration: 2, position: ToastPosition.center, title: nil, image: nil, style: nil)
                    { bRet in
                        
                    }
                }
            }
        }
    }
    
    func handleCapGestureEvent(sender:UITapGestureRecognizer) {
        if let view = sender.view {
            if view == frontCameraView {
                if SparkContext.sharedInstance.call?.facingMode != .user {
                    SparkContext.sharedInstance.call?.facingMode = .user
                }
                
            }
            else if view == backCameraView {
                if SparkContext.sharedInstance.call?.facingMode != .environment {
                    SparkContext.sharedInstance.call?.facingMode = .environment
                }
            }
            updateCheckBoxStatus()
        }
    }
    
    
    @IBAction private func toggleLoudSpeaker(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.isSpeaker = loudSpeakerSwitch.isOn
    }
    
    @IBAction private func toggleSendingVideo(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.sendingVideo = sendingVideoSwitch.isOn
        showSelfView(sendingVideoSwitch.isOn)
    }
    
    @IBAction private func toggleSendingAudio(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.sendingAudio = sendingAudioSwitch.isOn
    }
    
    @IBAction private func toggleReceivingVideo(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.receivingVideo = receivingVideoSwitch.isOn
        updateAvatarViewVisibility()
    }
    
    @IBAction private func toggleReceivingAudio(_ sender: AnyObject) {
        SparkContext.sharedInstance.call?.receivingAudio = receivingAudioSwitch.isOn
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
    @IBAction func pressDialpadButton(_ sender: AnyObject) {
        hideDialpadView(!dialpadView.isHidden)
    }
    
    // MARK: - UI views
    override func initView() {
        for label in labelFontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        
        fullScreenButton.setBackgroundImage(fullScreenImage, for: .normal)
        
        //checkbox init
        var tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        frontCameraView.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        backCameraView.addGestureRecognizer(tapGesture)
        
    }
    
    
    func updateCheckBoxStatus() {
        guard VideoAudioSetup.sharedInstance.isVideoEnabled() != false else {
            backCameraImage.image = uncheckImage
            frontCameraImage.image = uncheckImage
            return
        }
        
        if let isFacingMode = SparkContext.sharedInstance.call?.facingMode {
            if isFacingMode == .user {
                backCameraImage.image = uncheckImage
                frontCameraImage.image = checkImage
            }
            else {
                backCameraImage.image = checkImage
                frontCameraImage.image = uncheckImage
            }
        }
        else if VideoAudioSetup.sharedInstance.facingMode == .user {
            backCameraImage.image = uncheckImage
            frontCameraImage.image = checkImage
        }
        else {
            backCameraImage.image = checkImage
            frontCameraImage.image = uncheckImage
        }
    }
    
    
    private func setupAvatarView(_ remoteAddr: String) {
        avatarImageView.image = UIImage(named: "DefaultAvatar")
        avatarImageView.layer.masksToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        remoteDisplayNameLabel.text = remoteAddr
        remoteDisplayNameLabel.font = UIFont.labelLightFont(ofSize: 17 * Utils.HEIGHT_SCALE)
        remoteDisplayNameLabel.textColor = UIColor.white
        remoteDisplayNameLabel.textAlignment = NSTextAlignment.center
        remoteDisplayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(remoteDisplayNameLabel)
        
        
        let avatarImageViewCenterXConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .centerX, relatedBy: .equal, toItem: avatarContainerView, attribute: .centerX, multiplier: 1, constant: 0)
        let avatarImageViewCenterYConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .centerY, relatedBy: .equal, toItem: avatarContainerView, attribute: .centerY, multiplier: 1, constant: -(remoteViewHeight.constant/3/4))
        
        avatarImageViewHeightConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: remoteViewHeight.constant/3)
        let avatarImageViewWidthConstraint = NSLayoutConstraint.init(item: avatarImageView, attribute: .width, relatedBy: .equal, toItem: avatarImageView, attribute: .height, multiplier: 1, constant: 0)
        
        let remoteDisplayNameLabelLeadingConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .leading, relatedBy: .equal, toItem: avatarContainerView, attribute: .leading, multiplier: 1, constant: 0)
        let remoteDisplayNameLabelTrailingConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .trailing, relatedBy: .equal, toItem: avatarContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        let remoteDisplayNameLabelHeightConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 21 * Utils.HEIGHT_SCALE)
        let remoteDisplayNameLabelTopConstraint = NSLayoutConstraint.init(item: remoteDisplayNameLabel, attribute: .top, relatedBy: .equal, toItem: avatarImageView, attribute: .bottom, multiplier: 1, constant: 15 * Utils.HEIGHT_SCALE)
        
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
        
        Utils.fetchUserProfile(remoteAddr) { [weak self] (person: Person?) in
            if person != nil {
                //record this person in call history
                UserDefaultsUtil.addPersonHistory(person!)
                if let strongSelf = self{
                    strongSelf.remoteDisplayNameLabel.text = remoteAddr
                    if let displayName = person!.displayName {
                        strongSelf.remoteDisplayNameLabel.text = displayName
                    }
                    if let avatarUrl = person!.avatar {
                        strongSelf.fetchAvatarImage(avatarUrl)
                    }
                }
            }
        }
    }
    private func updateAvatarContainerView() {
        avatarImageViewHeightConstraint.constant = remoteViewHeight.constant/3
        avatarImageView.layer.cornerRadius = avatarImageViewHeightConstraint.constant/2
    }
    
    private func fetchAvatarImage(_ avatarUrl: String) {
        Utils.downloadAvatarImage(avatarUrl) { [weak self] avatarImage in
            if let strongSelf = self {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    strongSelf.avatarImageView.alpha = 1
                    strongSelf.avatarImageView.alpha = 0.1
                    strongSelf.view.layoutIfNeeded()
                }, completion: { [weak self] finished in
                    if let strongSelf = self {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                            strongSelf.avatarImageView.image = avatarImage
                            strongSelf.avatarImageView.alpha = 1
                            strongSelf.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                })
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
        DispatchQueue.main.async {
            self.updateStatusLabel()
            self.updateSwitches()
            self.updateAvatarViewVisibility()
            self.hideDialpadButton(false)
            self.hideDialpadView(true)
            self.updateSelfViewVisibility()
            
            if self.isCallDisconnected() {
                self.hideCallView()
            }
        }
        
    }
    private func updateStatusLabel() {
        switch callStatus {
        case .connected:
            navigationTitle = "Connected"
        case .disconnected:
            navigationTitle = "Disconnected"
        case .initiated:
            navigationTitle = "Initiated"
        case .ringing:
            navigationTitle = "Ringing"
        }
    }
    private func showDisconnectionType(_ type: Call.DisconnectReason) {
        var disconnectionTypeString = ""
        switch type {
        case .localCancel:
            disconnectionTypeString = "local cancel"
        case .localDecline:
            disconnectionTypeString = "local decline"
        case .localLeft:
            disconnectionTypeString = "local left"
        case .otherConnected:
            disconnectionTypeString = "other connected"
        case .otherDeclined:
            disconnectionTypeString = "other declined"
        case .remoteCancel:
            disconnectionTypeString = "remote cancel"
        case .remoteDecline:
            disconnectionTypeString = "remote decline"
        case .remoteLeft:
            disconnectionTypeString = "remote left"
        case .error(let error):
            disconnectionTypeString = "error: \(error)"
        }
        
        disconnectionTypeLabel.text = disconnectionTypeLabel.text! + disconnectionTypeString
        disconnectionTypeLabel.isHidden = false
    }
    
    private func updateSwitches() {
        updateCheckBoxStatus()
        loudSpeakerSwitch.isOn = SparkContext.sharedInstance.call?.isSpeaker ?? VideoAudioSetup.sharedInstance.isLoudSpeaker
        sendingVideoSwitch.isOn = SparkContext.sharedInstance.call?.sendingVideo ?? VideoAudioSetup.sharedInstance.isSelfViewShow
        sendingAudioSwitch.isOn = SparkContext.sharedInstance.call?.sendingAudio ?? true
        receivingVideoSwitch.isOn = SparkContext.sharedInstance.call?.receivingVideo ?? true
        receivingAudioSwitch.isOn = SparkContext.sharedInstance.call?.receivingAudio ?? true
        
        if !VideoAudioSetup.sharedInstance.isVideoEnabled() {
            frontCameraView.isUserInteractionEnabled = false
            backCameraView.isUserInteractionEnabled = false
            sendingVideoSwitch.isOn = false
            receivingVideoSwitch.isOn = false
            sendingVideoSwitch.isEnabled = false
            receivingVideoSwitch.isEnabled = false
        }
        else {
            frontCameraView.isUserInteractionEnabled = true
            backCameraView.isUserInteractionEnabled = true
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
        dialpadButton.isHidden = hidden
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
            SparkContext.sharedInstance.call?.hangup() { error in
                
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End call", style: .default, handler: endCallHandler))
        present(alert, animated: true, completion: nil)
    }
    
    private func fullScreenLandscape(_ height:CGFloat) {
        remoteViewHeight.constant = height
        selfViewWidth.constant = 100 * Utils.HEIGHT_SCALE
        selfViewHeight.constant = 70 * Utils.WIDTH_SCALE
        hideControlView(true)
        fullScreenButton.isHidden = true
    }
    private func fullScreenPortrait(_ height:CGFloat) {
        remoteViewHeight.constant = height
        selfViewWidth.constant = 70 * Utils.WIDTH_SCALE
        selfViewHeight.constant = 100 * Utils.HEIGHT_SCALE
        hideControlView(true)
        fullScreenButton.isHidden = false
        fullScreenButton.setBackgroundImage(normalScreenImage, for: .normal)
        
    }
    private func normalSizePortrait() {
        remoteViewHeight.constant = 210 * Utils.HEIGHT_SCALE
        selfViewWidth.constant = 70 * Utils.WIDTH_SCALE
        selfViewHeight.constant = 100 * Utils.HEIGHT_SCALE
        hideControlView(false)
        fullScreenButton.isHidden = false
        fullScreenButton.setBackgroundImage(fullScreenImage, for: .normal)
    }
    private func hideControlView(_ isHidden: Bool) {
        fullScreenButton.isHidden = UIDevice.current.orientation.isLandscape
        disconnectionTypeLabel.isHidden = (isHidden == false ? !isCallDisconnected():isHidden)
        showCallControllView(!isHidden)
        navigationController?.isNavigationBarHidden = isHidden
    }
    
    // MARK: - Utils
    func dial(_ remoteAddr: String) {
        if remoteAddr.isEmpty {
            return
        }
        
        
        
        var mediaOption = MediaOption.audioOnly()
        if VideoAudioSetup.sharedInstance.isVideoEnabled() {
            mediaOption = MediaOption.audioVideo(local: self.selfView, remote: self.remoteView)
        }
        self.callStatus = .initiated
        SparkContext.sharedInstance.spark?.phone.dial(remoteAddr, option: mediaOption) { [weak self] result in
            if let strongSelf = self {
                switch result {
                case .success(let call):
                    SparkContext.sharedInstance.call = call
                    strongSelf.sparkCallBackInit()
                case .failure(let error):
                    _ = strongSelf.navigationController?.popViewController(animated: true)
                    print("Dial call error: \(error)")
                }
                
                // self view init
                if VideoAudioSetup.sharedInstance.isVideoEnabled() && !VideoAudioSetup.sharedInstance.isSelfViewShow {
                    strongSelf.toggleSendingVideo(strongSelf.sendingVideoSwitch)
                }
            }
        }
    }
    
    func didAnswerIncomingCall() {
        
        
        var mediaOption = MediaOption.audioOnly()
        if VideoAudioSetup.sharedInstance.isVideoEnabled() {
            mediaOption = MediaOption.audioVideo(local: self.selfView, remote: self.remoteView)
        }
        
        if !VideoAudioSetup.sharedInstance.isSelfViewShow {
            sendingVideoSwitch.isOn = false
            showSelfView(sendingVideoSwitch.isOn)
        }
        
        if !VideoAudioSetup.sharedInstance.isLoudSpeaker {
            loudSpeakerSwitch.isOn = false
        }
        
        SparkContext.sharedInstance.call?.answer(option: mediaOption) { [weak self] error in
            if let strongSelf = self {
                if error != nil {
                    strongSelf.view.makeToast("Call statue error:\(error!)", duration: 2, position: ToastPosition.center, title: nil, image: nil, style: nil)
                    { bRet in
                        
                    }
                }
            }
        }
        
    }
    
    
    
    private func isFacingModeUser(_ mode: Phone.FacingMode) -> Bool {
        return mode == .user
    }
    
    private func isCallConnected() -> Bool {
        return callStatus == .connected
    }
    
    private func isCallDisconnected() -> Bool {
        return callStatus == .disconnected
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
    private static let DTMFKeys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoCallViewController.DTMFKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialpadCell", for: indexPath)
        let dialButton = cell.viewWithTag(105) as! UILabel
        dialButton.text = VideoCallViewController.DTMFKeys[indexPath.item]
        dialButton.layer.borderColor = UIColor.gray.cgColor
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
