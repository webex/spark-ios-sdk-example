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

class Utils {
    static func fetchUserProfile(email: String) -> (displayName: String, avatarUrl: String) {
        var name = ""
        var avatar = ""
        if !email.isEmpty {
            // Person list is empty with SIP email address
            if let persons = try? Spark.people.list(email: email, max: 1) where !persons.isEmpty {
                let person = persons[0]
                if let displayName = person.displayName {
                    name = displayName
                } else {
                    // Fallback to raw dial string
                    name = email
                }
                if let avatarUrl = person.avatar {
                    avatar = avatarUrl
                }
            }
        }
        return (displayName: name, avatarUrl: avatar)
    }
    
    static func getDataFromUrl(urlString:String, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    static func downloadAvatarImage(url: String?, completionHandler: (image : UIImage) -> Void) {
        if url == nil || url!.isEmpty {
            let image = UIImage(named: "DefaultAvatar")
            completionHandler(image: image!)
            return
        }

        let fileName = NSURL(fileURLWithPath: url!).lastPathComponent! + ".jpg"
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let imagePath = documentsURL.URLByAppendingPathComponent(fileName).path!
        
        if NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
            let image = UIImage(contentsOfFile: imagePath)
            completionHandler(image: image!)
        } else {
            getDataFromUrl(url!) { (data, response, error)  in
                guard let data = data where error == nil else { return }
                print("Download Finished")
                do {
                    try data.writeToFile(imagePath, options: .AtomicWrite)
                } catch {
                    print(error)
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let image = UIImage(data: data)
                    completionHandler(image: image!)
                }
            }
        }
    }
    
    static func showCameraMicrophoneAccessDeniedAlert(parentView: UIViewController) {
        let AlertTitle = "Access Denied"
        let AlertMessage = "Calling requires access to the camera and microphone. To fix this, go to Settings|Privacy|Camera and Settings|Privacy|Microphone, find this app and grant access."
        
        let alert = UIAlertController(title: AlertTitle, message: AlertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        parentView.presentViewController(alert, animated: true, completion: nil)
    }
}
