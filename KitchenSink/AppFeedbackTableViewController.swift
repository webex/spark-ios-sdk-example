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
import MessageUI

class AppFeedbackTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var userCommentsText: UITextView!
    @IBOutlet weak var mailAddressLabel: UILabel!
    @IBOutlet weak var snapshotLabel: UILabel!
    
    let mailAddress = "devsupport@ciscospark.com"
    var imagePicker = UIImagePickerController()
    var snapshotImage: UIImage!
    let snapshotFileName = "snapshot.png"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        topicLabel.text = "UI"
        snapshotLabel.text = " "
        mailAddressLabel.text = mailAddress
    }
    
    // MARK: - UI views
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            showActionSheet()
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            attachSnapshot()
        }
    }
    
    func showActionSheet() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Topic", preferredStyle: .ActionSheet)
        
        let uiAction = UIAlertAction(title: "UI", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.topicLabel.text = "UI"
        })
        
        let sdkAction = UIAlertAction(title: "SDK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.topicLabel.text = "SDK"
        })
        
        let devicesAction = UIAlertAction(title: "Supported devices", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.topicLabel.text = "Supported devices"
        })
        
        let featureAction = UIAlertAction(title: "Feature request", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.topicLabel.text = "Feature request"
        })
        
        optionMenu.addAction(uiAction)
        optionMenu.addAction(sdkAction)
        optionMenu.addAction(devicesAction)
        optionMenu.addAction(featureAction)
        
        presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func attachSnapshot() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([mailAddress])
        mailComposerVC.setSubject("[\(topicLabel.text!)] Feedback on Kitchen Sink demo app")
        mailComposerVC.setMessageBody(userCommentsText.text, isHTML: false)
        
        if (snapshotImage != nil) {
            let myData: NSData = UIImagePNGRepresentation(snapshotImage)!
            mailComposerVC.addAttachmentData(myData, mimeType: "image/png", fileName: snapshotFileName)
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: Delegates
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.snapshotImage = image
            self.snapshotLabel.text = self.snapshotFileName
        })
    }
}
