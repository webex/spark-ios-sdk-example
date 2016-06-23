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

class VideoAudioSetupViewController: UIViewController {
    
    @IBOutlet weak var defaultAudioSpeakerSwitch: UISwitch!
    @IBOutlet weak var defaultVideoSwitch: UISwitch!
    @IBOutlet weak var defaultCameraSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    let setup = VideoAudioSetup.sharedInstance
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        defaultAudioSpeakerSwitch.setOn(setup.isLoudSpeaker(), animated: true)
        defaultVideoSwitch.setOn(setup.isVideoEnabled(), animated: true)
        defaultCameraSwitch.setOn(setup.getFacingMode() == Call.FacingMode.User, animated: true)
        updateStatusLabel()
    }
    
    // MARK: - Speaker switch
    
    @IBAction func toggleLoudSpeaker(sender: AnyObject) {
        setup.setLoudSpeaker(defaultAudioSpeakerSwitch.on)
        updateStatusLabel()
    }
    
    @IBAction func toggleVideoMode(sender: AnyObject) {
        setup.setVideoEnabled(defaultVideoSwitch.on)
        if !setup.isVideoEnabled() {
            defaultCameraSwitch.enabled = false
        } else {
            defaultCameraSwitch.enabled = true
        }
        updateStatusLabel()
    }
    
    @IBAction func toggleFacingMode(sender: AnyObject) {
        if defaultCameraSwitch.on {
            setup.setFacingMode(Call.FacingMode.User)
        } else {
            setup.setFacingMode(Call.FacingMode.Environment)
        }
        updateStatusLabel()
    }
    
    func updateStatusLabel() {
        // Speaker
        let speakerStatus: String
        if defaultAudioSpeakerSwitch.on {
            speakerStatus = "Speaker"
        } else {
            speakerStatus = "Non Speaker"
        }
        statusLabel.text = "\nAudio output selected : " + speakerStatus
        
        // Video mode
        let mediaOption: String
        if defaultVideoSwitch.on {
            mediaOption = "Audio + Video"
        } else {
            mediaOption = "Audio-Only"
        }
        statusLabel.text = statusLabel.text! + "\nMedia option : " + mediaOption
        
        // Camera
        let cameraStatus: String
        if !defaultVideoSwitch.on {
            cameraStatus = "N/A"
        } else if defaultCameraSwitch.on {
            cameraStatus = "Front camera"
        } else {
            cameraStatus = "Back camera"
        }
        statusLabel.text = statusLabel.text! + "\nCamera selected : " + cameraStatus
    }
}
