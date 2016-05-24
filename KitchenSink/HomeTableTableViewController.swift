//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK

class HomeTableTableViewController: UITableViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var registerState = "connecting"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerPhone()
        updateStatusLabel()
    }
    
    // MARK: - Phone register
    
    func registerPhone() {
        Spark.phone.requestAccessForMedia() { granted in
            if !granted {
                self.showCameraMicrophoneAccessDeniedAlert()
            }
        }
        Spark.phone.register() { success in
            if success {
                self.registerState = "ok"
                self.updateStatusLabel()
            } else {
                self.registerState = "fail"
                self.showPhoneRegisterFailAlert()
            }
        }
    }
    
    // MARK: - UI views
    
    func updateStatusLabel() {
        statusLabel.text = "powered by SDK v" + Spark.version
        statusLabel.text = statusLabel.text! + "\nregistration to Cisco Cloud : " + registerState
    }
    
    func showPhoneRegisterFailAlert() {
        let alert = UIAlertController(title: "Alert", message: "Phone Register Fail", preferredStyle: .Alert)
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: dismissHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showCameraMicrophoneAccessDeniedAlert() {
        let alert = UIAlertController(title: "Access Denied", message: "Calling requires access to the camera and microphone. To fix this, go to Settings|Privacy|Camera and Settings|Privacy|Microphone, find this app and grant access.", preferredStyle: .Alert)
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: dismissHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
}
