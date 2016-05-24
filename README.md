# Kitchen Sink

Kitchen Sink Demo App is a developer friendly sample implementation of Spark client SDK and showcases all SDK features.

## Setup
Here are the steps to setup Xcode project using [CocoaPods](http://cocoapods.org):

1. Install CocoaPods:
    ```bash
    gem install cocoapods
    ```

1. Setup Cocoapods:
    ```bash
    pod setup
    ```

1. Install SparkSDK and other dependencies from your project directory:

    ```bash
    pod install
    ```

## Example
The "// MARK: " labels in source code have distinguished the SDK calling and UI views paragraphes.  
Below is code snippets of the SDK calling in the demo.

1. Setup SDK with Spark access token 
   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let sparkAccessToken = "Yjc5ZTYyMDEt..."
        Spark.initWith(accessToken: sparkAccessToken)
        return true
    }
   ```
1. Setup SDK with app infomation, and authorize access to Spark service
   ```swift
   class LoginViewController: UIViewController {
    
        @IBAction func loginWithSpark(sender: AnyObject) {
            let clientId = "C90f769..."
            let clientSecret = "64e252..."
            let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
            let redirectUri = "KitchenSink://response"
            
            Spark.initWith(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri, controller: self)
        }
    }
    ```

1. Register device
    ```swift
    Spark.phone.register() { success in
        if !success {
            print("Failed to register device.")
        }
    }
    ```
            
1. Spark calling API
    
   ```swift
    // Self video view and Remote video view
    @IBOutlet weak var selfView: MediaRenderView!
    @IBOutlet weak var remoteView: MediaRenderView!
    
    // Calling events
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallRinging), name: Notifications.Call.Ringing, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallConnected), name: Notifications.Call.Connected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCallViewController.onCallDisconnected), name: Notifications.Call.Disconnected, object: nil)
    }
    
    // Make a call
    let renderView = RenderView(local: videoCallViewController.selfView, remote: videoCallViewController.remoteView)
    let call = Spark.phone.dial(email, renderView: renderView) { success in
        if !success {
            print("Failed to dial call.")
        }
    }
    
    // Recive a call
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showCallToastView(_:)), name: Notifications.Phone.Incoming, ...)
    @objc func showCallToastView(notification: NSNotification) {
        let incomingCall = notification.call
    }
    
    // Answer and reject call
    call.answer(renderView, completionHandler: nil)
    call.reject(nil)
    ```
