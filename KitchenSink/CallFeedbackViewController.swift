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
    
    @IBAction func sendFeedback(_ sender: AnyObject) {
        call.sendFeedback(Int(callRateView.rating), comments: userCommentsTextField.text!, includeLogs: includeLogSwitch.isOn)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI views
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func IncludeLogs(_ sender: AnyObject) {
        updateStatusLabel()
    }
    
    @IBAction func userCommentsChanged(_ sender: AnyObject) {
        updateStatusLabel()
    }

    func updateStatusLabel() {
        statusLabel.text = "User rating: " + String(Int(callRateView.rating))
        statusLabel.text = statusLabel.text! + "\nUser comments : " + userCommentsTextField.text!
        statusLabel.text = statusLabel.text! + "\nInclude logs : " + includeLogSwitch.isOn.description
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateStatusLabel()
        return false
    }
}
