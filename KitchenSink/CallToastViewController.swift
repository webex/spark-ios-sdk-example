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

class CallToastViewController: UIViewController, CallObserver {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var call: Call!
    var incomingCallDelegate: IncomingCallDelegate!
    
    private var name = ""
    private var avatar = ""
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        CallNotificationCenter.sharedInstance.addObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        CallNotificationCenter.sharedInstance.removeObserver(self)
    }
    
    // MARK: - Call answer/reject
    
    @IBAction func answerButtonPressed(sender: AnyObject) {
        incomingCallDelegate.didAnswerIncomingCall()
        dismissView()
    }
    
    @IBAction func declineButtonPressed(sender: AnyObject) {
        incomingCallDelegate.didDeclineIncomingCall()
        dismissView()
    }
    
    // MARK: - CallObserver
    
    func callDidBeginRinging(call: Call) {
    }
    
    func callDidConnect(call: Call) {
    }
    
    func callDidDisconnect(call: Call, disconnectionType: DisconnectionType) {
        dismissView()
    }
    
    func remoteMediaDidChange(call: Call, mediaChangeType: MediaChangeType) {
    }
    
    // MARK: - UI views
    
    private func setupView() {
        fetchUserProfile()
        fetchAvataImage()
        updateDisplayName()
    }
    
    private func fetchAvataImage() {
        Utils.downloadAvatarImage(avatar, completionHandler: {
            self.avatarImage.image = $0
        })
    }
    
    private func updateDisplayName() {
        nameLabel.text = name
    }
    
    private func dismissView() {
        dismissViewControllerAnimated(false, completion: nil)
    }

    // MARK: - People API
    
    private func fetchUserProfile() {
        if Spark.authorized() {
            if let email = call.from {
                let profile = Utils.fetchUserProfile(email)
                name = profile.displayName
                avatar = profile.avatarUrl
            }
        }
    }
}