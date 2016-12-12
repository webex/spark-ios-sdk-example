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
import Toast_Swift

class JWTLoginViewController: UIViewController {
    
    
    @IBOutlet weak var statusLabel: UILabel!
    private var jwtAuthStrategy: JWTAuthStrategy!
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jwtAuthStrategy = JWTAuthStrategy()
        jwtAuthStrategy.authorizedWith(jwt: "")
        statusLabel.text = "Powered by SDK v" + Spark.version
        AppDelegate.spark = Spark(authenticationStrategy: jwtAuthStrategy)
    }
    
    // MARK: - Login/Auth handling
    
    @IBAction func loginWithSpark(_ sender: UIButton) {
        if jwtAuthStrategy.authorized {
            jwtAuthStrategy.accessToken() { [unowned self] success in
                if success != nil {
                    self.showApplicationHome()
                } else {
                   self.showLoginError()
                }
            }
        } else {
            showLoginError()
        }
    }
    
    private func showApplicationHome() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HomeTableTableViewController") as! HomeTableTableViewController
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    private func showLoginError() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Login", message: "Unable to Login: Please make sure your JWT is correct.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true)
    }
}
