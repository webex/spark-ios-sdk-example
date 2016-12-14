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
    private var spark: Spark!
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jwtAuthStrategy = JWTAuthStrategy()
        statusLabel.text = "Powered by SDK v" + Spark.version
        spark = Spark(authenticationStrategy: jwtAuthStrategy)
        AppDelegate.spark = spark
    }
    
    // MARK: - Login/Auth handling
    
    @IBAction func loginWithSpark(_ sender: UIButton) {
        if !jwtAuthStrategy.authorized {
            jwtAuthStrategy.authorizedWith(jwt: "PLACE_JWT_HERE")
        }

        if spark.authenticationStrategy.authorized {
            spark.people.getMe() { response in
                switch response.result {
                case .success(let person):
                    let emailAddress = (person.emails ?? []).first
                    let emailString = emailAddress == nil ? "NONE" : emailAddress!.toString()
                    let alert = UIAlertController(title: "Logged in", message: "Logged in as \(person.displayName ?? "NONE") with id \n\(emailString)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.showApplicationHome()
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                case .failure(let error):
                    let alert = UIAlertController(title: "Could Not Get Personal Info", message: "Unable to retrieve information about the user logged in using the JWT: Please make sure your JWT is correct. \(error)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
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
        let alert = UIAlertController(title: "Could Not Login", message: "Unable to Login: Please make sure your JWT is correct.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
