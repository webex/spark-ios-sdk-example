//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK

class VideoAudioSetupViewController: UIViewController {
    
    @IBOutlet weak var defaultAudioSpeakerSwitch: UISwitch!
    @IBOutlet weak var cameraPickerView: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var cameras = ["Front camera","Back camera"]
    var cameraStatus: String?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        defaultAudioSpeakerSwitch.setOn(Spark.phone.defaultLoudSpeaker, animated: true)
        if Spark.phone.defaultFacingMode == Call.FacingMode.User {
            cameraPickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            cameraPickerView.selectRow(1, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - Speaker switch
    
    @IBAction func toggleLoudSpeaker(sender: AnyObject) {
        Spark.phone.defaultLoudSpeaker = defaultAudioSpeakerSwitch.on
        updateStatusLabel()
    }
    
    // MARK: - Camera picker view
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        cameraStatus = cameras[row]
        updateStatusLabel()
        return cameras[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(row == 0)
        {
            Spark.phone.defaultFacingMode = Call.FacingMode.User
        }
        else if(row == 1)
        {
            Spark.phone.defaultFacingMode = Call.FacingMode.Environment
        }
        updateStatusLabel()
    }
    
    func updateStatusLabel() {
        
        statusLabel.text = "\nvideo selected : " + cameraStatus!
        
        let speakerStatus: String
        if defaultAudioSpeakerSwitch.on {
            speakerStatus = "Speaker"
        } else {
            speakerStatus = "Non Speaker"
        }
        statusLabel.text = statusLabel.text! + "\naudio selected : " + speakerStatus
    }
}
