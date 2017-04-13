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

class VideoAudioSetupViewController: BaseViewController {
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var audioVideoView: UIView!
    @IBOutlet weak var audioVideoImage: UIImageView!
    
    @IBOutlet weak var loudSpeakerSwitch: UISwitch!
    @IBOutlet weak var selfViewSwitch: UISwitch!
    @IBOutlet weak var cameraSetupView: UIView!
    @IBOutlet weak var videoSetupView: UIView!
    @IBOutlet weak var frontCameraView: UIView!
    @IBOutlet weak var backCameraView: UIView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var selfViewHiddenHelpLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var selfViewHiddenHelpLabel: KSLabel!
    
    
    @IBOutlet weak var videoViewHiddenHelpLabel: KSLabel!
    @IBOutlet weak var videoViewhiddenHelpLabelHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var selfViewSetupHeight: NSLayoutConstraint!
    @IBOutlet weak var videoViewHeight: NSLayoutConstraint!
    @IBOutlet var labelFontCollection: [UILabel]!
    @IBOutlet var widthScaleConstraintCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleConstraintCollection: [NSLayoutConstraint]!

    private let uncheckImage = UIImage.fontAwesomeIcon(name: .squareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))
    private let checkImage = UIImage.fontAwesomeIcon(name: .checkSquareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))
    let setup = VideoAudioSetup.sharedInstance
    private let selfViewSetupHeightContant = 320 * Utils.HEIGHT_SCALE
    private let selfViewSetupHelpLabelHeightContant = 54 * Utils.HEIGHT_SCALE
    
    private let videoViewSetupHeightContant = 400 * Utils.HEIGHT_SCALE
    private let videoViewSetupHelpLabelHeightContant = 54 * Utils.HEIGHT_SCALE
    
    override var navigationTitle: String? {
        get {
            return "Video/Audio setup"
        }
        set(newValue) {
            title = newValue
        }
    }
        
    
    // MARK: - Life cycle
    override func initView() {
        for label in labelFontCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        
        for heightConstraint in heightScaleConstraintCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleConstraintCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        

        //navigation bar init
        let nextButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        
        let nextImage = UIImage.fontAwesomeIcon(name: .phone, textColor: UIColor.buttonGreenNormal(), size: CGSize.init(width: 32 * Utils.WIDTH_SCALE , height: 44))
        let nextLightImage = UIImage.fontAwesomeIcon(name: .phone, textColor: UIColor.buttonGreenHightlight(), size: CGSize.init(width: 32 * Utils.WIDTH_SCALE, height: 44))
        nextButton.setImage(nextImage, for: .normal)
        nextButton.setImage(nextLightImage, for: .highlighted)
        nextButton.addTarget(self, action: #selector(gotoInitiateCallView), for: .touchUpInside)
        
        
        let rightView = UIView.init(frame:CGRect.init(x: 0, y: 0, width: 44, height: 44))
        rightView.addSubview(nextButton)
        let rightButtonItem = UIBarButtonItem.init(customView: rightView)
        
        
        let fixBarSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixBarSpacer.width = -10 * (2 - Utils.WIDTH_SCALE)
        navigationItem.rightBarButtonItems = [fixBarSpacer,rightButtonItem]
        
        
        //checkbox init 
        var tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        audioView.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        audioVideoView.addGestureRecognizer(tapGesture)
        updateCallCapStatus()
        videoViewHeight.constant = CGFloat(setup.isVideoEnabled() ? videoViewSetupHeightContant:0)
        videoViewhiddenHelpLabelHeight.constant = CGFloat(setup.isVideoEnabled() ? 0:videoViewSetupHelpLabelHeightContant)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCameraGestureEvent(sender:)))
        frontCameraView.addGestureRecognizer(tapGesture)
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCameraGestureEvent(sender:)))
        backCameraView.addGestureRecognizer(tapGesture)
        updateCameraStatus()
        updateLoudspeakerStatus()
        updateSelfViewStatus()
        selfViewSetupHeight.constant = CGFloat(selfViewSwitch.isOn ? selfViewSetupHeightContant:0)
        selfViewHiddenHelpLabelHeight.constant = CGFloat(selfViewSwitch.isOn ? 0:selfViewSetupHelpLabelHeightContant)
        
    }
    // MARK: - hand checkbox change
    
    @IBAction func loudSpeakerSwitchChange(_ sender: Any) {
        let speakerSwitch = sender as! UISwitch
        setup.setLoudSpeaker(speakerSwitch.isOn)
    }
    @IBAction func selfViewSwitchChange(_ sender: Any) {
        let selfViewSwitch = sender as! UISwitch
        setup.isSelfViewShow = selfViewSwitch.isOn
        updateSelfSetupView(!selfViewSwitch.isOn)
    }
    
    func handleCapGestureEvent(sender:UITapGestureRecognizer) {
        if let view = sender.view {
            if view == audioView {
                setup.setVideoEnabled(false)
                updateVideoView(true)
            }
            else if view == audioVideoView {
                setup.setVideoEnabled(true)
                updateVideoView(false)
            }
            
            updateCallCapStatus()
        }
    }
    
    func handleCameraGestureEvent(sender:UITapGestureRecognizer) {
        if let view = sender.view {
            if view == frontCameraView {
                setup.setFacingMode(Call.FacingMode.User)
            }
            else {
                setup.setFacingMode(Call.FacingMode.Environment)
            }
            
            updateCameraStatus()
        }
    }
    
    
    func updateCallCapStatus() {
        if !setup.isVideoEnabled() {
            audioImage.image = checkImage
            audioVideoImage.image = uncheckImage
        } else {
            audioImage.image = uncheckImage
            audioVideoImage.image = checkImage
        }
    }
    
    func updateCameraStatus() {
        if setup.getFacingMode() == Call.FacingMode.User {
            frontImage.image = checkImage
            backImage.image = uncheckImage
        }
        else {
            frontImage.image = uncheckImage
            backImage.image = checkImage
        }
    }
    
    func updateLoudspeakerStatus() {
        loudSpeakerSwitch.isOn = setup.isLoudSpeaker()
    }

    func updateSelfViewStatus() {
        selfViewSwitch.isOn = setup.isSelfViewShow
    }
    
    func updateVideoView(_ isHidden:Bool) {
        var firstView:UIView?
        var firstConstraint:NSLayoutConstraint?
        var firstConstant:CGFloat?
        var secondView:UIView?
        var secondConstraint:NSLayoutConstraint?
        var secondConstant:CGFloat?
        
        if isHidden {
            firstView = videoSetupView
            firstConstraint = videoViewHeight
            firstConstant = 0
            secondView = videoViewHiddenHelpLabel
            secondConstraint = videoViewhiddenHelpLabelHeight
            secondConstant = videoViewSetupHelpLabelHeightContant
            
        }
        else {
            firstView = videoViewHiddenHelpLabel
            firstConstraint = videoViewhiddenHelpLabelHeight
            firstConstant = 0
            secondView = videoSetupView
            secondConstraint = videoViewHeight
            secondConstant = videoViewSetupHeightContant
        }
        
        expandedView(firstConstraint!, constant: firstConstant!,view: firstView!){ [weak self] in
            if let strongSelf = self {
                strongSelf.expandedView(secondConstraint!, constant: secondConstant!,view: secondView!)
            }
        }
        
    }

    func updateSelfSetupView(_ isHidden:Bool) {
        var firstView:UIView?
        var firstConstraint:NSLayoutConstraint?
        var firstConstant:CGFloat?
        var secondView:UIView?
        var secondConstraint:NSLayoutConstraint?
        var secondConstant:CGFloat?
        
        if isHidden {
            firstView = cameraSetupView
            firstConstraint = selfViewSetupHeight
            firstConstant = 0
            secondView = selfViewHiddenHelpLabel
            secondConstraint = selfViewHiddenHelpLabelHeight
            secondConstant = selfViewSetupHelpLabelHeightContant
            
        }
        else {
            firstView = selfViewHiddenHelpLabel
            firstConstraint = selfViewHiddenHelpLabelHeight
            firstConstant = 0
            secondView = cameraSetupView
            secondConstraint = selfViewSetupHeight
            secondConstant = selfViewSetupHeightContant
        }
        
        expandedView(firstConstraint!, constant: firstConstant!,view: firstView!){ [weak self] in
            if let strongSelf = self {
                strongSelf.expandedView(secondConstraint!, constant: secondConstant!,view: secondView!)
            }
        }
    }
    
    private func expandedView(_ viewConstraint:NSLayoutConstraint,constant:CGFloat,view:UIView,completion: (() -> Swift.Void)? = nil) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: .curveEaseIn, animations: { [weak self]  in
            if let strongSelf = self {
                viewConstraint.constant = constant
                view.alpha = (constant == 0 ? 0:1)
                strongSelf.view.layoutIfNeeded()
            }
            
        }, completion: { finished in
            if let finishedCompletion = completion {
                finishedCompletion()
            }
        })
    }
    
    func gotoInitiateCallView() {
        if let initiateCallViewController = storyboard?.instantiateViewController(withIdentifier: "InitiateCallViewController") as? InitiateCallViewController! {
            navigationController?.pushViewController(initiateCallViewController, animated: true)
        }

    }
    
}
