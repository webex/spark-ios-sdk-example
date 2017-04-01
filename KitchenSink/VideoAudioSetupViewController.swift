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
    
    @IBOutlet weak var defaultAudioSpeakerSwitch: UISwitch!
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var defaultCameraSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet var labelFontCollection: [UILabel]!
    
    @IBOutlet var widthScaleConstraintCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleConstraintCollection: [NSLayoutConstraint]!
    
    let setup = VideoAudioSetup.sharedInstance
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initView() {
        for label in labelFontCollection {
            label.font = UIFont.systemFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        
        for heightConstraint in heightScaleConstraintCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleConstraintCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        
        defaultAudioSpeakerSwitch.setOn(setup.isLoudSpeaker(), animated: true)
        defaultVideoSwitch.setOn(setup.isVideoEnabled(), animated: true)
        defaultCameraSwitch.setOn(setup.getFacingMode() == Call.FacingMode.User, animated: true)
        updateStatusLabel()
    }
    // MARK: - Speaker switch
    
    @IBAction func toggleLoudSpeaker(_ sender: AnyObject) {
        setup.setLoudSpeaker(defaultAudioSpeakerSwitch.isOn)
        updateStatusLabel()
    }
    
    @IBAction func toggleVideoMode(_ sender: AnyObject) {
        setup.setVideoEnabled(defaultVideoSwitch.isOn)
        if !setup.isVideoEnabled() {
            defaultCameraSwitch.isEnabled = false
        } else {
            defaultCameraSwitch.isEnabled = true
        }
        updateStatusLabel()
    }
    
    @IBAction func toggleFacingMode(_ sender: AnyObject) {
        if defaultCameraSwitch.isOn {
            setup.setFacingMode(Call.FacingMode.User)
        } else {
            setup.setFacingMode(Call.FacingMode.Environment)
        }
        updateStatusLabel()
    }
    
    func updateStatusLabel() {
        // Speaker
        let speakerStatus: String
        if defaultAudioSpeakerSwitch.isOn {
            speakerStatus = "Speaker"
        } else {
            speakerStatus = "Non Speaker"
        }
        statusLabel.text = "\nAudio output selected : " + speakerStatus
        
        // Video mode
        let mediaOption: String
        if defaultVideoSwitch.isOn {
            mediaOption = "Audio + Video"
        } else {
            mediaOption = "Audio-Only"
        }
        statusLabel.text = statusLabel.text! + "\nMedia option : " + mediaOption
        
        // Camera
        let cameraStatus: String
        if !defaultVideoSwitch.isOn {
            cameraStatus = "N/A"
        } else if defaultCameraSwitch.isOn {
            cameraStatus = "Front camera"
        } else {
            cameraStatus = "Back camera"
        }
        statusLabel.text = statusLabel.text! + "\nCamera selected : " + cameraStatus
    }
}
