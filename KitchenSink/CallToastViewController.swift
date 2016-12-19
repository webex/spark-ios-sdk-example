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

class CallToastViewController: UIViewController, CallObserver {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var call: Call!
    var incomingCallDelegate: IncomingCallDelegate!
    
    fileprivate var name = ""
    fileprivate var avatar = ""
    
    private var spark: Spark!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spark = AppDelegate.spark
        fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spark.callNotificationCenter.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spark.callNotificationCenter.remove(observer: self)
    }
    
    // MARK: - Call answer/reject
    
    @IBAction func answerButtonPressed(_ sender: AnyObject) {
        incomingCallDelegate.didAnswerIncomingCall()
        dismissView()
    }
    
    @IBAction func declineButtonPressed(_ sender: AnyObject) {
        incomingCallDelegate.didDeclineIncomingCall()
        dismissView()
    }
    
    // MARK: - CallObserver
    
    func callDidDisconnect(_ call: Call, disconnectionType: DisconnectionType) {
        dismissView()
    }
    
    // MARK: - UI views
    
    fileprivate func fetchAvatarImage() {
        Utils.downloadAvatarImage(avatar, completionHandler: {
            self.avatarImage.image = $0
        })
    }
    
    fileprivate func dismissView() {
        dismiss(animated: false, completion: nil)
    }

    // MARK: - People API
    
    fileprivate func fetchUserProfile() {
        if spark.authenticationStrategy.authorized {
            if let email = call.from {
                Utils.fetchUserProfile(email) { [unowned self] (displayName: String, avatarUrl: String) in
                    self.name = displayName
                    self.avatar = avatarUrl
                    self.fetchAvatarImage()
                    self.nameLabel.text = displayName
                }
            }
        }
    }
}
