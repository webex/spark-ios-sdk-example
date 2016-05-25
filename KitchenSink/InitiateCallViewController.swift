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
