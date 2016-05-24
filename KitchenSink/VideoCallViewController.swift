//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

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
        dismissCallView()
    }
    
    // MARK: - UI views
    
    func dismissCallView() {
        if presentingViewController!.isKindOfClass(UINavigationController) {
            let navigationController = presentingViewController as! UINavigationController
            presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            navigationController.popViewControllerAnimated(true)
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
}

