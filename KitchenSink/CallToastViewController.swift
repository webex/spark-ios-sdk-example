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

class CallToastViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var call: Call!
    var name: String?
    var avatar: String?
    var videoCallViewController: VideoCallViewController!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CallToastViewController.onCallConnected), name: Notifications.Call.Connected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CallToastViewController.onCallDisconnected), name: Notifications.Call.Disconnected, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupView() {
        requestHostsProfile()
        nameLabel.text = name
        videoCallViewController = storyboard?.instantiateViewControllerWithIdentifier("VideoCallViewController") as? VideoCallViewController!
    }
    
    // MARK: - People API
    
    func requestHostsProfile() {
        if Spark.authorized() {
            let email = call.from
            if email != "" {
                let host = (try? Spark.people.list(email: email))?[0]
                name = host?.displayName
                avatar = host?.avatar
            }
        }
    }
    
    // MARK: - Call answer/reject
    
    @IBAction func answerButtonPressed(sender: AnyObject) {
        Spark.phone.requestAccessForMedia() { granted in
            if granted {
                self.presentVideoCallView()
                let renderView = RenderView(local: self.videoCallViewController.selfView, remote: self.videoCallViewController.remoteView)
                self.call.answer(renderView, completionHandler: nil)
            } else {
                self.call.reject(nil)
                self.showCameraMicrophoneAccessDeniedAlert()
            }
        }
    }
    
    @IBAction func declineButtonPressed(sender: AnyObject) {
        call.reject(nil)
        dismissView()
    }
    
    // MARK: - Call events
    
    @objc func onCallDisconnected() {
        dismissView()
    }
    
    @objc func onCallConnected() {
        dismissView()
    }
    
    // MARK: - UI views
    
    func dismissView() {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func presentVideoCallView() {
        videoCallViewController.call = self.call
        videoCallViewController.modalPresentationStyle = .FullScreen
        self.presentViewController(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
            popoverController.permittedArrowDirections = .Any
        }
    }
    
    func showCameraMicrophoneAccessDeniedAlert() {
        let alert = UIAlertController(title: "Access Denied", message: "Calling requires access to the camera and microphone. To fix this, go to Settings|Privacy|Camera and Settings|Privacy|Microphone, find this app and grant access.", preferredStyle: .Alert)
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.dismissView()
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: dismissHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
}

