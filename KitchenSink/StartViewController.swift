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
        statusLabel.text = "Powered by SDK v" + Spark.version
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

