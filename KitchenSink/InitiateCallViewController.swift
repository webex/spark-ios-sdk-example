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

class InitiateCallViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dialAddressTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var videoCallViewController: VideoCallViewController!
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResult: [Person]?
    private var dialEmail: String?
    
    private var localVideoView: MediaRenderView {
        return videoCallViewController.selfView
    }
    
    private var remoteVideoView: MediaRenderView {
        return videoCallViewController.remoteView
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Dial call
    
    func dial(address: String) {
        if address.isEmpty {
            return
        }
        
        Spark.phone.requestMediaAccess(Phone.MediaAccessType.AudioVideo) { granted in
            if granted {
                self.presentVideoCallView(address)
                
                var mediaOption = MediaOption.AudioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.AudioVideo(local: self.localVideoView, remote: self.remoteVideoView)
                }
                let call = Spark.phone.dial(address, option: mediaOption) { success in
                    if !success {
                        self.dismissVideoCallView()
                        print("Failed to dial call.")
                    }
                }
                self.videoCallViewController.call = call
            } else {
                Utils.showCameraMicrophoneAccessDeniedAlert(self)
            }
        }
    }
    
    @IBAction func dialAddress(sender: AnyObject) {
        dial(dialAddressTextField.text!)
    }
    
    @IBAction func switchDialWay(sender: AnyObject) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            hideDialAddressView(true)
            hideSearchView(false)
        case 1:
            hideSearchView(true)
            hideDialAddressView(false)
        default:
            break;
        }
    }
    
    // MARK: - people search
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        
        if searchString.characters.count < 3 {
            searchResult?.removeAll()
            tableView.reloadData()
            return
        }
        
        if searchString.containsString("@") {
            Spark.people.list(email: searchString, max: 10) {
                (response: ServiceResponse<[Person]>) in
                
                switch response.result {
                case .Success(let value):
                    self.searchResult = value
                case .Failure:
                    self.searchResult = nil
                }
                if searchString == searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        } else {
            Spark.people.list(displayName: searchString, max: 10) {
                (response: ServiceResponse<[Person]>) in
                
                switch response.result {
                case .Success(let value):
                    self.searchResult = value
                case .Failure:
                    self.searchResult = nil
                }
                if searchString == searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResult != nil  {
            return searchResult!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath) as! PersonTableViewCell
        let person = searchResult?[indexPath.row]
        let email = person?.emails?.first
        cell.address = email
        cell.initiateCallViewController = self
        
        Utils.downloadAvatarImage(person?.avatar, completionHandler: {
            cell.avatarImageView.image = $0
        })
        cell.nameLabel.text = person?.displayName
        return cell
    }
    
    // MARK: - UI views
    
    private func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Email or user name"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func presentVideoCallView(remoteAddr: String) {
        videoCallViewController = storyboard?.instantiateViewControllerWithIdentifier("VideoCallViewController") as? VideoCallViewController!
        
        videoCallViewController.remoteAddr = remoteAddr
        videoCallViewController.modalPresentationStyle = .FullScreen
        presentViewController(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
            popoverController.permittedArrowDirections = .Any
        }
    }
    
    private func dismissVideoCallView() {
        videoCallViewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    private func hideSearchView(hidden: Bool) {
        searchController.active = false
        tableView.hidden = hidden
    }
    
    private func hideDialAddressView(hidden: Bool) {
        dialAddressTextField.hidden = hidden
    }
}
