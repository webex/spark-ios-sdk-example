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
        demoAppHelpLabel.isHidden = true
        sparkIdHelpLabel.isHidden = true
        appIdHelpLabel.isHidden = true
    }
    
    @IBAction func showDemoAppHelpLabel(_ sender: AnyObject) {
        demoAppHelpLabel.isHidden = !demoAppHelpLabel.isHidden
        sparkIdHelpLabel.isHidden = true
        appIdHelpLabel.isHidden = true
    }
    
    @IBAction func showSparkIdHelpLabel(_ sender: AnyObject) {
        demoAppHelpLabel.isHidden = true
        sparkIdHelpLabel.isHidden = !sparkIdHelpLabel.isHidden
        appIdHelpLabel.isHidden = true
    }
    
    @IBAction func showAppIdHelpLabel(_ sender: AnyObject) {
        demoAppHelpLabel.isHidden = true
        sparkIdHelpLabel.isHidden = true
        appIdHelpLabel.isHidden = !appIdHelpLabel.isHidden
    }
}

