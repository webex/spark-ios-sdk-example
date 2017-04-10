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
    
    @IBOutlet weak var noneView: UIView!
    @IBOutlet weak var noneImage: UIImageView!
    
    @IBOutlet weak var audioView: UIView!
    
    @IBOutlet weak var audioImage: UIImageView!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var audioVideoView: UIView!

    @IBOutlet weak var audioVideoImage: UIImageView!
    
    
    @IBOutlet weak var frontCameraView: UIView!
    @IBOutlet weak var backCameraView: UIView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var backImage: UIImageView!
    
    @IBOutlet var labelFontCollection: [UILabel]!
    @IBOutlet var widthScaleConstraintCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleConstraintCollection: [NSLayoutConstraint]!

    private let uncheckImage = UIImage.fontAwesomeIcon(name: .squareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))
    private let checkImage = UIImage.fontAwesomeIcon(name: .checkSquareO, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 33 * Utils.HEIGHT_SCALE, height: 33 * Utils.HEIGHT_SCALE))

    
    
    
    
    let setup = VideoAudioSetup.sharedInstance
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
        noneView.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        audioView.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        videoView.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCapGestureEvent(sender:)))
        audioVideoView.addGestureRecognizer(tapGesture)
        updateCheckBoxStatus()
        
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCameraGestureEvent(sender:)))
        frontCameraView.addGestureRecognizer(tapGesture)
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCameraGestureEvent(sender:)))
        backCameraView.addGestureRecognizer(tapGesture)
        updateCameraStatus()
    }
    // MARK: - hand checkbox change
    func handleCapGestureEvent(sender:UITapGestureRecognizer) {
        if let view = sender.view {
            if view == noneView {
                setup.setLoudSpeaker(false)
                setup.setVideoEnabled(false)
            }
            else if view == audioView {
                setup.setLoudSpeaker(true)
                setup.setVideoEnabled(false)
            }
            else if view == videoView {
                setup.setLoudSpeaker(false)
                setup.setVideoEnabled(true)
            }
            else {
                setup.setLoudSpeaker(true)
                setup.setVideoEnabled(true)
            }
            
            updateCheckBoxStatus()
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
    
    
    func updateCheckBoxStatus() {

        
        if !setup.isLoudSpeaker() && !setup.isVideoEnabled() {
            noneImage.image = checkImage
            audioImage.image = uncheckImage
            videoImage.image = uncheckImage
            audioVideoImage.image = uncheckImage
        } else if setup.isLoudSpeaker() && !setup.isVideoEnabled() {
            noneImage.image = uncheckImage
            audioImage.image = checkImage
            videoImage.image = uncheckImage
            audioVideoImage.image = uncheckImage
        }
        else if !setup.isLoudSpeaker() && setup.isVideoEnabled() {
            noneImage.image = uncheckImage
            audioImage.image = uncheckImage
            videoImage.image = checkImage
            audioVideoImage.image = uncheckImage
        }
        else {
            noneImage.image = uncheckImage
            audioImage.image = uncheckImage
            videoImage.image = uncheckImage
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

    func gotoInitiateCallView() {
        if let initiateCallViewController = storyboard?.instantiateViewController(withIdentifier: "InitiateCallViewController") as? InitiateCallViewController! {
            navigationController?.pushViewController(initiateCallViewController, animated: true)
        }

    }
    
}
