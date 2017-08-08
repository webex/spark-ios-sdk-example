// Copyright 2016-2017 Cisco Systems Inc
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

class InitiateCallViewController: BaseViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UI outlets variables
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var dialAddressTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var textFieldScaleCollection: [UITextField]!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchResult: [Person]?
    fileprivate var historyResult: [Person]?
    fileprivate var dialEmail: String?
    fileprivate var segmentedControl: UISegmentedControl?
    
    /// saparkSDK reperesent for the SparkSDK API instance
    var sparkSDK: Spark?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    
    // MARK: - Dial call processing
    @IBAction func dialBtnClicked(_ sender: AnyObject) {
        if let emailAddress = dialAddressTextField.text{
            self.dialWithEmailAddress(emailAddress)
        }
    }
    
    func dialWithEmailAddress(_ emailAddress: String){
        if emailAddress.isEmpty {
            showNoticeAlert("Address is empty")
            return
        }
        self.presentVideoCallView(emailAddress)
    }
    
    fileprivate func presentVideoCallView(_ remoteAddr: String) {
        if let videoCallViewController = storyboard?.instantiateViewController(withIdentifier: "VideoCallViewController") as? VideoCallViewController! {
            videoCallViewController.videoCallRole = VideoCallRole.CallPoster(remoteAddr)
            videoCallViewController.sparkSDK = self.sparkSDK
            navigationController?.pushViewController(videoCallViewController, animated: true)
        }
    }
    
    // MARK: - SparkSDK: search people with Email/SearchString

    private func sparkFetchPersonProfilesWithEmail(searchStr: String){
        if let email = EmailAddress.fromString(searchStr) {
            /* Lists people with email address in the authenticated user's organization. */
            self.sparkSDK?.people.list(email: email, max: 10) {
                (response: ServiceResponse<[Person]>) in
                
                self.indicatorView.stopAnimating()
                switch response.result {
                case .success(let value):
                    self.searchResult = value
                case .failure:
                    self.searchResult = nil
                }
                if searchStr == self.searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        } else {
            /* Lists people with display name in the authenticated user's organization. */
            self.sparkSDK?.people.list(displayName: searchStr, max: 10) {
                (response: ServiceResponse<[Person]>) in
                self.indicatorView.stopAnimating()
                switch response.result {
                case .success(let value):
                    self.searchResult = value
                case .failure:
                    self.searchResult = nil
                }
                if searchStr == self.searchController.searchBar.text! {
                    self.tableView.reloadData()
                }
            }
        }
    }
    // MARK: search bar result updating delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        
        if searchString.characters.count < 3 {
            searchResult?.removeAll()
            tableView.reloadData()
            return
        }
        
        indicatorView.startAnimating()
        self.sparkFetchPersonProfilesWithEmail(searchStr: searchString)
    }
    
    // MARK: - UI Implementation
    override func initView() {
        for textfield in textFieldScaleCollection {
            textfield.font = UIFont.textViewLightFont(ofSize: (textfield.font?.pointSize)! * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
    }
    fileprivate func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
        historyTableView.dataSource = self
        historyTableView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Email or user name"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        view.bringSubview(toFront: indicatorView)
        dialAddressTextField.layer.borderColor = UIColor.gray.cgColor
        
        let itemArray = [UIImage.fontAwesomeIcon(name: .history, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 32*Utils.WIDTH_SCALE , height: 29)),UIImage.fontAwesomeIcon(name: .search, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 32*Utils.WIDTH_SCALE , height: 29)),UIImage.fontAwesomeIcon(name: .phone, textColor: UIColor.titleGreyColor(), size: CGSize.init(width: 32*Utils.WIDTH_SCALE , height: 29))]
        segmentedControl = UISegmentedControl.init(items: itemArray)
        segmentedControl?.frame = CGRect.init(x: 0, y: 0, width: 150, height: 29)
        segmentedControl?.tintColor = UIColor.titleGreyColor()
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.addTarget(self, action: #selector(switchDialWay(_:)),for:.valueChanged)
        navigationItem.titleView = segmentedControl
        
        //init history tableView data
        historyResult = UserDefaultsUtil.callPersonHistory
        historyResult?.reverse()
        historyTableView.reloadData()
        
        
    }
    
    @IBAction func switchDialWay(_ sender: AnyObject) {
        dissmissKeyboard()
        switch sender.selectedSegmentIndex
        {
        case 0:
            hideHistoryView(false)
            hideDialAddressView(true)
            hideSearchView(true)
        case 1:
            hideDialAddressView(true)
            hideSearchView(false)
            hideHistoryView(true)
        case 2:
            hideHistoryView(true)
            hideSearchView(true)
            hideDialAddressView(false)
        default:
            break;
        }
    }
    
    
    fileprivate func hideSearchView(_ hidden: Bool) {
        searchController.isActive = false
        tableView.isHidden = hidden
        if !hidden {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    fileprivate func hideHistoryView(_ hidden: Bool) {
        historyTableView.isHidden = hidden
        
        if !hidden {
            historyResult = UserDefaultsUtil.callPersonHistory
            historyResult?.reverse()
            historyTableView.reloadData()
        }
    }
    
    fileprivate func hideDialAddressView(_ hidden: Bool) {
        dialAddressTextField.isHidden = hidden
        if !hidden {
            dialAddressTextField.becomeFirstResponder()
        }
    }
    
    override func dissmissKeyboard() {
        super.dissmissKeyboard()
        searchController.searchBar.endEditing(true)
    }
    
    fileprivate func showNoticeAlert(_ notice:String) {
        let alert = UIAlertController(title: "Alert", message: notice, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 * Utils.HEIGHT_SCALE
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView && searchResult != nil  {
            return searchResult!.count
        } else if tableView == self.historyTableView {
            return historyResult?.count ?? 0
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonTableViewCell
        let dataSource: [Person]?
        
        if tableView == self.tableView {
            dataSource = searchResult
        }
        else {
            dataSource = historyResult
        }
        
        let person = dataSource?[indexPath.row]
        let email = person?.emails?.first
        cell.address = email?.toString()
        cell.initiateCallViewController = self
        
        Utils.downloadAvatarImage(person?.avatar, completionHandler: {
            cell.avatarImageView.image = $0
        })
        cell.nameLabel.text = person?.displayName
        
        return cell
    }
    // MARK: other functions
    deinit {
        searchController.view.removeFromSuperview()
    }
    
}
