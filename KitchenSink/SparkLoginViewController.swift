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

class SparkLoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleAuth()
        updateStatusLabel()
    }
    
    // MARK: - Login/Auth handling
    
    @IBAction func loginWithSpark(_ sender: AnyObject) {
        let clientId = "Cb3f891d2044fec65bfe36a8d1b3d69b3098448e9e0335c58bab42f5b94ad06c9"
        let clientSecret = "f2660da9c8b90a9cdfe713f7c115473b76da531bb7ec9c66fdb8ec1481585879"
        let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
        let redirectUri = "KitchenSink://response"
        
        Spark.initWith(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri, controller: self)
    }
    
    func handleAuth() {
        guard Spark.authorized() else {
            return
        }
        
        view.makeToastActivity(.center)
        passAuth()
        view.hideToastActivity()
    }
    
    func passAuth() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController!
        present(viewController!, animated: false, completion: nil)
    }
    
    func updateStatusLabel() {
        statusLabel.text = "Powered by SDK v" + Spark.version
    }
}
