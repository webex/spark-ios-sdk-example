//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK

class InitiateCallViewController: UIViewController {

    @IBOutlet weak var dialAddressTextField: UITextField!
    
    var videoCallViewController: VideoCallViewController!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        videoCallViewController = storyboard?.instantiateViewControllerWithIdentifier("VideoCallViewController") as? VideoCallViewController!
    }
    
    // MARK: - Dial call

    @IBAction func dialCall(sender: AnyObject) {
        let email = dialAddressTextField.text!
        if email.isEmpty {
            return
        }
        
        self.presentVideoCallView()
        
        let renderView = RenderView(local: videoCallViewController.selfView, remote: videoCallViewController.remoteView)
        let call = Spark.phone.dial(email, renderView: renderView) { success in
            if !success {
                print("Failed to dial call.")
            }
        }
        self.videoCallViewController.call = call
    }
    
    // MARK: - UI views
    
    func presentVideoCallView() {
        videoCallViewController.modalPresentationStyle = .FullScreen
        self.presentViewController(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .Any
        }
    }
}
