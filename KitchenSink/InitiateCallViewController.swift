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

class InitiateCallViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dialAddressTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var videoCallViewController: VideoCallViewController!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchResult: [Person]?
    fileprivate var dialEmail: String?
    private var spark: Spark!
    
    fileprivate var localVideoView: MediaRenderView {
        return videoCallViewController.selfView
    }
    
    fileprivate var remoteVideoView: MediaRenderView {
        return videoCallViewController.remoteView
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spark = AppDelegate.spark
        setupView()
    }
    
    // MARK: - Dial call
    
    func dial(_ address: String) {
        if address.isEmpty {
            return
        }
        
        spark.phone.requestMediaAccess(Phone.MediaAccessType.audioVideo) { granted in
            if granted {
                self.presentVideoCallView(address)
                
                var mediaOption = MediaOption.audioOnly
                if VideoAudioSetup.sharedInstance.isVideoEnabled() {
                    mediaOption = MediaOption.audioVideo(local: self.localVideoView, remote: self.remoteVideoView)
                }
                let call = self.spark.phone.dial(address, option: mediaOption) { success in
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
    
    @IBAction func dialAddress(_ sender: AnyObject) {
        dial(dialAddressTextField.text!)
    }
    
    @IBAction func switchDialWay(_ sender: AnyObject) {
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
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        
        if searchString.characters.count < 3 {
            searchResult?.removeAll()
            tableView.reloadData()
            return
        }
        
        if let email = EmailAddress.fromString(searchString) {
            spark.people.list(email: email, max: 10) {
                (response: ServiceResponse<[Person]>) in
                
                switch response.result {
                case .success(let value):
                    self.searchResult = value
                case .failure:
                    self.searchResult = nil
                }
                if searchString == searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        } else {
            spark.people.list(displayName: searchString, max: 10) {
                (response: ServiceResponse<[Person]>) in
                
                switch response.result {
                case .success(let value):
                    self.searchResult = value
                case .failure:
                    self.searchResult = nil
                }
                if searchString == searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResult != nil  {
            return searchResult!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonTableViewCell
        let person = searchResult?[indexPath.row]
        let email = person?.emails?.first
        cell.address = email?.toString()
        cell.initiateCallViewController = self
        
        Utils.downloadAvatarImage(person?.avatar, completionHandler: {
            cell.avatarImageView.image = $0
        })
        cell.nameLabel.text = person?.displayName
        return cell
    }
    
    // MARK: - UI views
    
    fileprivate func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Email or user name"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func presentVideoCallView(_ remoteAddr: String) {
        videoCallViewController = storyboard?.instantiateViewController(withIdentifier: "VideoCallViewController") as? VideoCallViewController!
        
        videoCallViewController.remoteAddr = remoteAddr
        videoCallViewController.modalPresentationStyle = .fullScreen
        present(videoCallViewController, animated: true, completion: nil)
        if let popoverController = videoCallViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
            popoverController.permittedArrowDirections = .any
        }
    }
    
    fileprivate func dismissVideoCallView() {
        videoCallViewController.dismiss(animated: false, completion: nil)
    }
    
    fileprivate func hideSearchView(_ hidden: Bool) {
        searchController.isActive = false
        tableView.isHidden = hidden
    }
    
    fileprivate func hideDialAddressView(_ hidden: Bool) {
        dialAddressTextField.isHidden = hidden
    }
}
