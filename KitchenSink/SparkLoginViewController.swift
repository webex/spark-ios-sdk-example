//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK
import Toast_Swift

class SparkLoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.makeToastActivity(.Center)
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
        if Spark.authorized() {
            passAuth()
        } else {
            view.hideToastActivity()
        }
    }
    
    func passAuth() {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController!
        presentViewController(viewController, animated: false, completion: nil)
    }
    
    func updateStatusLabel() {
        statusLabel.text = "powered by SDK v" + Spark.version
    }
}
