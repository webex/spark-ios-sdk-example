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
    
    private var registerState = "connecting"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerPhone()
        updateStatusLabel()
    }
    
    // MARK: - Phone register
    
    func registerPhone() {
        Spark.phone.requestMediaAccess(Phone.MediaAccessType.AudioVideo) { granted in
            if !granted {
                Utils.showCameraMicrophoneAccessDeniedAlert(self)
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
    
    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 4 {
            Spark.deauthorize()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - UI views
    
    private func updateStatusLabel() {
        statusLabel.text = "powered by SDK v" + Spark.version
        statusLabel.text = statusLabel.text! + "\nregistration to Cisco cloud : " + registerState
    }
    
    private func showPhoneRegisterFailAlert() {
        let alert = UIAlertController(title: "Alert", message: "Phone register fail", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}
