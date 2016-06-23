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
import Toast_Swift

class SparkLoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        handleAuth()
        updateStatusLabel()
    }
    
    // MARK: - Login/Auth handling
    
    @IBAction func loginWithSpark(sender: AnyObject) {
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
        
        view.makeToastActivity(.Center)
        passAuth()
        view.hideToastActivity()
    }
    
    func passAuth() {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController!
        presentViewController(viewController, animated: false, completion: nil)
    }
    
    func updateStatusLabel() {
        statusLabel.text = "powered by SDK v" + Spark.version
    }
}
