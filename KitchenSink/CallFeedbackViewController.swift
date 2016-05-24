//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

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
