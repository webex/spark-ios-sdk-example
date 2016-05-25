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
