//
//  ActivityDetailViewController.swift
//  KitchenSink
//
//  Created by qucui on 2018/1/18.
//  Copyright © 2018年 Cisco Systems, Inc. All rights reserved.
//

import UIKit
import SparkSDK

class RoomDetailViewController: BaseViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var roomModel: Room?
    var roomId: String?
    var emailAddress: String?
    private var contentTextView: UITextView?
    private var fileContentsView: UIScrollView?
    private var textInputView: KitchensinkInputView?
    private var receivedFiles: [FileObjectModel]? = [FileObjectModel]()
    
    /// saparkSDK reperesent for the SparkSDK API instance
    var sparkSDK: Spark?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.registerActivityControll()
    }
    
    // MARK: - SparkSDK: AcitivityClient
    private func registerActivityControll(){
        self.sparkSDK?.messages?.onMessage = {message in
            self.updateMessageAcitivty(message)
        }
    }
    
    // MARK: - SparkSDK: Send Message
    public func sendMessage(_ textStr: String?,_ memberShip : Membership? ,_ image: [String: Any]?){
        self.title = "Sending.."
        var finalStr : String?
        var files : [FileObjectModel]?
        var mentions : [MessageMentionModel]?
        if let text = textStr{
            finalStr = text
        }else{
            finalStr = ""
        }
        if let imageDict = image{
            do{
                let selectedImage = imageDict["UIImagePickerControllerOriginalImage"] as! UIImage
                let imageData = UIImageJPEGRepresentation(selectedImage, 1.0)
                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let imageURL = docDir.appendingPathComponent("tempImage.jpeg")
                try imageData?.write(to: imageURL)
                let fileModel = FileObjectModel(name: "tempImage.jpeg", localFileUrl: imageURL.absoluteString)
                files = [FileObjectModel]()
                files?.append(fileModel)
                fileModel.image = ThumbNailImageModel(localFileUrl: imageURL.absoluteString, width: 600, height: 320)
            }catch{
                print("image convert failed")
                return
            }
        }
        if let membership = memberShip{
            let mention = MessageMentionModel.createPeopleMentionItem(personId: membership.id)
            mentions = [MessageMentionModel]()
            mentions?.append(mention)
            finalStr = "\(finalStr!)\(membership.personDisplayName!)"
        }
        
        if let room = self.roomModel{
            self.sparkSDK?.messages?.post(roomId: room.id!,text: finalStr,mentions: mentions, files: files, uploadProgressHandler:{
                (file, progress) in
                    let progressStr = "Sending.. Uploaded: \(progress*100)"+"%"
                    self.title = progressStr
            },completionHandler: { (response) in
                switch response.result{
                case .success(let meesage):
                    /// Send Message Call Back Code Here
                    self.title = "Sent Sucess!"
                    self.roomId = meesage.roomId
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error)
                        self.title = "Sent Fail!"
                    }
                    break
                }}
            )
        }else if let email = self.emailAddress{
            self.sparkSDK?.messages?.post(email: email,
                                          text: finalStr,
                                          mentions: mentions,
                                          files: files,
            uploadProgressHandler:{ (file, progress) in
                let progressStr = "Sending.. Uploaded: \(progress*100)"+"%"
                self.title = progressStr
            },completionHandler: { (response) in
                switch response.result{
                case .success(let message):
                    /// Send Message Call Back Code Here
                    self.title = "Sent Sucess!"
                    self.roomId = message.roomId
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error)
                        self.title = "Sent Fail!"
                    }
                    break
                }
            })
        }
    }
    
    // MARK: - SparkSDK: Download File
    public func downLoadFile(file: FileObjectModel, onView: UIView){
        let progressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: onView.frame.size.width, height: 30))
        progressLabel.textAlignment = .center
        progressLabel.textColor = UIColor.black
        onView.addSubview(progressLabel)
        if let roomId = self.roomId{
            self.sparkSDK?.messages?.downLoadFile(roomId: roomId, file: file, downLoadProgressHandler: { (progress) in
                DispatchQueue.main.async {
                    progressLabel.text = String(Int(progress*100)) + "%"
                }
            }, completionHandler: { (file, state) in
                if(state == FileDownLoadState.DownloadSuccess){
                    let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
                    webView.loadRequest(URLRequest(url: URL(string: file.localFileUrl!)!))
                    let webVC = UIViewController()
                    webVC.view = webView
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            })
        }
    }

    public func downLoadThumbnail(_ file: FileObjectModel, onView: UIView){
        let progressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: onView.frame.size.width, height: onView.frame.size.height))
        progressLabel.textAlignment = .center
        progressLabel.textColor = UIColor.black
        onView.addSubview(progressLabel)
       
        if let roomId = self.roomId{
            self.sparkSDK?.messages?.downLoadThumbNail(roomId: roomId, file: file, downLoadProgressHandler: { (progress) in
                DispatchQueue.main.async {
                    progressLabel.text = String(Int(progress*100)) + "%"
                }
            }, completionHandler: { (file, state) in
                
                if(state == FileDownLoadState.DownloadSuccess){
                    progressLabel.removeFromSuperview()
                    guard let localUrl = file.image?.localFileUrl else{
                        return
                    }
                    let image = UIImage(contentsOfFile: localUrl)
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: onView.frame.size.width, height: onView.frame.size.height))
                    imageView.image = image
                    imageView.backgroundColor = UIColor.red
                    onView.addSubview(imageView)
                }
            })
        }
    }
    
    // MARK: - UI Implementation
    public func setupView(){
        self.view.backgroundColor = UIColor.white
        if let room = self.roomModel{
            self.title = room.title
            self.roomId = room.id
        }else if let email = self.emailAddress{
            self.title = email
        }else{
            self.title = ""
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: kScreenWidth-10, height: 20))
        titleLabel.text = "Message Payloads:"
        self.view.addSubview(titleLabel)
        
        self.contentTextView = UITextView(frame: CGRect(x: 10, y: 30, width: kScreenWidth-20, height: 320))
        self.contentTextView?.backgroundColor =  UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.contentTextView?.font = UIFont.fontAwesome(ofSize: 15)
        self.contentTextView?.isUserInteractionEnabled = true
        self.contentTextView?.isScrollEnabled = true
        self.view.addSubview(self.contentTextView!)
        
        let fileTitleLable = UILabel(frame: CGRect(x: 10, y: 350, width: kScreenWidth-10, height: 20))
        fileTitleLable.text = "Files:"
        self.view.addSubview(fileTitleLable)
        
        self.fileContentsView = UIScrollView(frame: CGRect(x: 10, y: 370, width: kScreenWidth-20, height: 100))
        self.fileContentsView?.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.view.addSubview(self.fileContentsView!)

        self.textInputView = KitchensinkInputView(frame: CGRect(x:0,y:kScreenHeight-kNavHeight-40,width: kScreenWidth, height: 40), backVC: self)
        self.textInputView?.sendBtnClickBlock = { (textStr: String?, mention : Membership? , image: [String: Any]?) in
            self.textInputView?.textView?.text = ""
            self.sendMessage(textStr, mention, image)
        }
        self.view.addSubview(self.textInputView!)
    }
    
    public func updateMessageAcitivty(_ message: MessageModel){
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: message.dictPresent(), options: .prettyPrinted)
            self.contentTextView?.text = String(data: jsonData, encoding: .utf8)
        }catch{}
    }
    
    public func setUpFileContentsView(files: [FileObjectModel]){

        self.fileContentsView?.removeFromSuperview()
        self.fileContentsView = UIScrollView(frame: CGRect(x: 10, y: 315, width: kScreenWidth-20, height: 120))
        self.fileContentsView?.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
  
        self.view.addSubview(self.fileContentsView!)
        self.view.bringSubview(toFront: self.textInputView!)
        
        self.receivedFiles?.removeAll()
        self.receivedFiles = files
        self.fileContentsView?.contentSize = CGSize(width: 100*(self.receivedFiles?.count)!, height: 120)
        for index in 0..<files.count{
            let file = files[index]
            let tempView = UIView(frame: CGRect(x: 100*index, y: 0, width: 100, height: 100))
            tempView.tag = 10000+index
            tempView.backgroundColor = UIColor.lightGray
            self.fileContentsView?.addSubview(tempView)
            if(file.mimeType?.contains("image/"))!{
                self.downLoadThumbnail(file, onView: tempView)
            }else{
                let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: tempView.frame.size.width-20, height: tempView.frame.size.height-20))
                titleLabel.text = file.displayName!
                titleLabel.numberOfLines = 0
                titleLabel.backgroundColor = UIColor.lightGray
                titleLabel.textAlignment = .center
                tempView.addSubview(titleLabel)
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(fileDownLoadClicked(_ :)))
            tempView.addGestureRecognizer(tap)
        }
    }
    @objc private func fileDownLoadClicked(_ recognizer: UITapGestureRecognizer){
        let index = (recognizer.view?.tag)! - 10000
        let file = self.receivedFiles![index]
        self.downLoadFile(file: file, onView: recognizer.view!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
