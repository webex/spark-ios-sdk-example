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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 4 {
            Spark.deauthorize()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
