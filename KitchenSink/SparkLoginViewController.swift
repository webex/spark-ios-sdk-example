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

class SparkLoginViewController: BaseViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    private var oauthStrategy: OAuthStrategy!
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusLabel.text = "Powered by SDK v" + Spark.version
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SparkContext.initSparkForSparkIdLogin()
        oauthStrategy = SparkContext.sharedInstance.spark?.authenticationStrategy as! OAuthStrategy
        if oauthStrategy.authorized {
            showApplicationHome()
        }
    }
    
    // MARK: - Login/Auth handling
    @IBAction func loginWithSpark(_ sender: AnyObject) {
        oauthStrategy.authorize(parentViewController: self) { success in
            if success {
                self.showApplicationHome()
            }
        }
    }
    
    private func showApplicationHome() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HomeTableTableViewController") as! HomeTableTableViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}
