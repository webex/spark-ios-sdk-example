//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import UIKit
import SparkSDK

class StartViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var demoAppHelpLabel: UILabel!
    @IBOutlet weak var sparkIdHelpLabel: UILabel!
    @IBOutlet weak var appIdHelpLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStatusLabel()
        setupHelpLabels()
    }
    
    func updateStatusLabel() {
        statusLabel.text = "powered by SDK v" + Spark.version
    }
    
    func setupHelpLabels() {
        demoAppHelpLabel.hidden = true
        sparkIdHelpLabel.hidden = true
        appIdHelpLabel.hidden = true
    }
    
    @IBAction func showDemoAppHelpLabel(sender: AnyObject) {
        demoAppHelpLabel.hidden = !demoAppHelpLabel.hidden
        sparkIdHelpLabel.hidden = true
        appIdHelpLabel.hidden = true
    }
    
    @IBAction func showSparkIdHelpLabel(sender: AnyObject) {
        demoAppHelpLabel.hidden = true
        sparkIdHelpLabel.hidden = !sparkIdHelpLabel.hidden
        appIdHelpLabel.hidden = true
    }
    
    @IBAction func showAppIdHelpLabel(sender: AnyObject) {
        demoAppHelpLabel.hidden = true
        sparkIdHelpLabel.hidden = true
        appIdHelpLabel.hidden = !appIdHelpLabel.hidden
    }
}

