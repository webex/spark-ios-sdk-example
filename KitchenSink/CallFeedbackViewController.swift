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
import Cosmos

class CallFeedbackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userCommentsTextField: UITextField!
    @IBOutlet weak var includeLogSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var callRateView: CosmosView!
    
    var call: Call!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        userCommentsTextField.delegate = self
        callRateView.didFinishTouchingCosmos = { rating in
            self.updateStatusLabel()
        }
        updateStatusLabel()
    }
    
    // MARK: - Call sendFeedback
    
    @IBAction func sendFeedback(sender: AnyObject) {
        call.sendFeedback(Int(callRateView.rating), comments: userCommentsTextField.text!, includeLogs: includeLogSwitch.on)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UI views
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func IncludeLogs(sender: AnyObject) {
        updateStatusLabel()
    }
    
    @IBAction func userCommentsChanged(sender: AnyObject) {
        updateStatusLabel()
    }

    func updateStatusLabel() {
        statusLabel.text = "user rating: " + String(Int(callRateView.rating))
        statusLabel.text = statusLabel.text! + "\nuser comments : " + userCommentsTextField.text!
        statusLabel.text = statusLabel.text! + "\ninclude logs : " + includeLogSwitch.on.description
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateStatusLabel()
        return false
    }
}
