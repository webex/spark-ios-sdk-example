//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK

class IncomingCallViewController: UIViewController {
    
    var callToastViewController: CallToastViewController!
    
    // MARK: - Life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IncomingCallViewController.onCallIncoming(_:)), name: Notifications.Phone.Incoming, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Call events
    
    @objc func onCallIncoming(notification: NSNotification) {
        
        let call = notification.call
        
        callToastViewController = storyboard?.instantiateViewControllerWithIdentifier("CallToastViewController") as! CallToastViewController
        callToastViewController!.call = call
        presentCallToastView()
    }
    
    // MARK: - UI views
    
    func presentCallToastView() {
        callToastViewController.modalPresentationStyle = .FullScreen
        presentViewController(callToastViewController, animated: true, completion: nil)
        if let popoverController = callToastViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.permittedArrowDirections = .Any
        }
    }
}
