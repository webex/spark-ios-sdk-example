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
    
    // Make a call
    let call = Spark.phone.dial(email, option: MediaOption.AudioVideo(local: videoCallViewController.selfView, remote: videoCallViewController.remoteView)) { success in
        if !success {
            print("Failed to dial call.")
        }
    }
    
    // Recive a call
    class IncomingCallViewController: UIViewController, PhoneObserver {
    override func viewWillAppear(...) {
        PhoneNotificationCenter.sharedInstance.addObserver(self)
    }
    override func viewWillDisappear(...) {
        PhoneNotificationCenter.sharedInstance.removeObserver(self)
    }
    func callIncoming(call: Call) {
        // Show incoming call toast view
    }
    
    // Answer and reject call
    call.answer(option: MediaOption.AudioVideo(local: videoCallViewController.selfView, remote: videoCallViewController.remoteView), completionHandler: nil)
    call.reject(nil)
    ```
    
## Note

1. Strip unsupported achitecture before submitting to App store:  

   Wme framework of media engine in SDK contains a build for both the simulator (x86_64) and the actual devices (ARM).  
   Of course, you aren't allowed to submit to the App Store a binary for an unsupported achitecture, so the solution is to "manually" remove the unneeded architectures from the final binary, before submitting it.  
   Daniel Kennett came up with a nice solution and provides this script to add to the build phase.  
   http://stackoverflow.com/questions/30547283/submit-to-app-store-issues
   
   Note this script only work in Release scheme and use for achive binary.
