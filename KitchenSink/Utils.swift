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
    static func fetchUserProfile(_ emailString: String, completionHandler: @escaping (String, String) -> Void) {
        if let emailAddress = EmailAddress.fromString(emailString) {
            // Person list is empty with SIP email address
            SparkContext.sharedInstance.spark?.people.list(email: emailAddress, max: 1) { response in
                var name = emailString
                var avatarUrlString = ""
                var persons: [Person] = []
                
                switch response.result {
                case .success(let value):
                    persons = value
                case .failure(let error):
                    print("ERROR: \(error)")
                }
                
                if let person = persons.first {
                    if let displayName = person.displayName {
                        name = displayName
                    }
                    if let avatarUrl = person.avatar {
                        avatarUrlString = avatarUrl
                    }
                }
                completionHandler(name, avatarUrlString)
            }
        } else {
            print("could not parse email address \(emailString) for retrieving user profile")
            completionHandler(emailString, "")
        }
    }
    
    static func getDataFromUrl(_ urlString:String, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void)) {
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
    
    static func downloadAvatarImage(_ url: String?, completionHandler: @escaping (_ image : UIImage) -> Void) {
        if url == nil || url!.isEmpty {
            let image = UIImage(named: "DefaultAvatar")
            completionHandler(image!)
            return
        }

        let fileName = URL(fileURLWithPath: url!).lastPathComponent + ".jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsURL.appendingPathComponent(fileName).path
        
        if FileManager.default.fileExists(atPath: imagePath) {
            let image = UIImage(contentsOfFile: imagePath)
            completionHandler(image!)
        } else {
            getDataFromUrl(url!) { (data, response, error) in
                guard let data = data , error == nil else { return }
                print("Download Finished")
                do {
                    try data.write(to: URL(fileURLWithPath: imagePath), options: .atomicWrite)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async { () -> Void in
                    let image = UIImage(data: data)
                    completionHandler(image!)
                }
            }
        }
    }
    
    static func showCameraMicrophoneAccessDeniedAlert(_ parentView: UIViewController) {
        let AlertTitle = "Access Denied"
        let AlertMessage = "Calling requires access to the camera and microphone. To fix this, go to Settings|Privacy|Camera and Settings|Privacy|Microphone, find this app and grant access."
        
        let alert = UIAlertController(title: AlertTitle, message: AlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        parentView.present(alert, animated: true, completion: nil)
    }
}
