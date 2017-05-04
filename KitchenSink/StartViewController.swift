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

class StartViewController: BaseViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var demoAppHelpLabel: UILabel!
    @IBOutlet weak var sparkIdHelpLabel: UILabel!
    @IBOutlet weak var jwtHelpLabel: UILabel!
    
    private var animationsCompletion: Bool = true
    
    @IBOutlet var labelFrontScaleCollection: [UILabel]!
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    @IBOutlet var buttonFrontScaleCollection: [UIButton]!
    
    @IBOutlet weak var imageTopToSuperView: NSLayoutConstraint!
    
    @IBOutlet weak var sparkIDButton: UIButton!
    @IBOutlet weak var JWTButton: UIButton!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStatusLabel()
        setupHelpLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if #available(iOS 10.0, *) {
        
        }
        else {
            if demoAppHelpLabel.layer.anchorPoint.x != 1 || sparkIdHelpLabel.layer.anchorPoint.x != 1 || jwtHelpLabel.layer.anchorPoint.x != 1{
                demoAppHelpLabel.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                demoAppHelpLabel.layer.position = CGPoint.init(x: demoAppHelpLabel.layer.position.x - demoAppHelpLabel.bounds.width/2, y: demoAppHelpLabel.layer.position.y + demoAppHelpLabel.bounds.height/2)
                sparkIdHelpLabel.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                sparkIdHelpLabel.layer.position = CGPoint.init(x: sparkIdHelpLabel.layer.position.x - sparkIdHelpLabel.bounds.width/2, y: sparkIdHelpLabel.layer.position.y + sparkIdHelpLabel.bounds.height/2)
                jwtHelpLabel.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                jwtHelpLabel.layer.position = CGPoint.init(x: jwtHelpLabel.layer.position.x - jwtHelpLabel.bounds.width/2, y: jwtHelpLabel.layer.position.y + jwtHelpLabel.bounds.height/2)
            }
        }
    }
    
    // MARK: - UIView
    override func initView() {
        for label in labelFrontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for button in buttonFrontScaleCollection {
            button.titleLabel?.font = UIFont.buttonLightFont(ofSize: (button.titleLabel?.font.pointSize)! * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        sparkIDButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        sparkIDButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        sparkIDButton.layer.cornerRadius = buttonHeight.constant/2
        
        JWTButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueNormal(), background: nil), for: .normal)
        JWTButton.setBackgroundImage(UIImage.imageWithColor(UIColor.buttonBlueHightlight(), background: nil), for: .highlighted)
        JWTButton.layer.cornerRadius = buttonHeight.constant/2
        
    }
    
    func updateStatusLabel() {
        statusLabel.text = "Powered by Cisco Spark iOS SDK v" + Spark.version
    }
    
    func setupHelpLabels() {
        demoAppHelpLabel.isHidden = true
        sparkIdHelpLabel.isHidden = true
        jwtHelpLabel.isHidden = true
        
    }
    
    // MARK: - Button click action
    @IBAction func showDemoAppHelpLabel(_ sender: AnyObject) {
        guard animationsCompletion else {
            return
        }
        if demoAppHelpLabel.layer.anchorPoint.x != 1 {
            demoAppHelpLabel.layer.anchorPoint = CGPoint.init(x: 1, y: 0)
            demoAppHelpLabel.layer.position = CGPoint.init(x: demoAppHelpLabel.layer.position.x + demoAppHelpLabel.bounds.width/2, y: demoAppHelpLabel.layer.position.y - demoAppHelpLabel.bounds.height/2)
            demoAppHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
        }
        
        let scale: CGFloat = !demoAppHelpLabel.isHidden ? 0.0001:1
        let damping: CGFloat = !demoAppHelpLabel.isHidden ? 1.0:0.8
        let springVelocity: CGFloat = !demoAppHelpLabel.isHidden ? 0.5:10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: springVelocity, options: .curveEaseInOut,animations: {
            self.demoAppHelpLabel.isHidden = false
            self.demoAppHelpLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            self.sparkIdHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
            self.jwtHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
            self.view.layoutIfNeeded()
            self.animationsCompletion = false
        }, completion: { finished in
            self.animationsCompletion = true
            self.sparkIdHelpLabel.isHidden = true
            self.jwtHelpLabel.isHidden = true
            self.demoAppHelpLabel.isHidden = scale<1 ? true:false
        })
        
        
    }
    
    @IBAction func showSparkIdHelpLabel(_ sender: AnyObject) {
        guard animationsCompletion else {
            return
        }
        if sparkIdHelpLabel.layer.anchorPoint.x != 1 {
            sparkIdHelpLabel.layer.anchorPoint = CGPoint.init(x: 1, y: 0)
            sparkIdHelpLabel.layer.position = CGPoint.init(x: sparkIdHelpLabel.layer.position.x + sparkIdHelpLabel.bounds.width/2, y: sparkIdHelpLabel.layer.position.y - sparkIdHelpLabel.bounds.height/2)
        }
        
        let scale: CGFloat = !sparkIdHelpLabel.isHidden ? 0.0001:1
        let damping: CGFloat = !sparkIdHelpLabel.isHidden ? 1.0:0.8
        let springVelocity: CGFloat = !sparkIdHelpLabel.isHidden ? 0.5:10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: springVelocity, options: .curveEaseInOut,
                       animations: {
                        self.sparkIdHelpLabel.isHidden = false
                        self.demoAppHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
                        self.jwtHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
                        self.sparkIdHelpLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                        self.view.layoutIfNeeded()
                        self.animationsCompletion = false
        }, completion: { finished in
            self.demoAppHelpLabel.isHidden = true
            self.jwtHelpLabel.isHidden = true
            self.animationsCompletion = true
            self.sparkIdHelpLabel.isHidden = scale<1 ? true:false
        })
    }
    
    @IBAction func showJWTHelpLabel(_ sender: AnyObject) {
        guard animationsCompletion else {
            return
        }
        if jwtHelpLabel.layer.anchorPoint.x != 1 {
            jwtHelpLabel.layer.anchorPoint = CGPoint.init(x: 1, y: 0)
            jwtHelpLabel.layer.position = CGPoint.init(x: jwtHelpLabel.layer.position.x + jwtHelpLabel.bounds.width/2, y: jwtHelpLabel.layer.position.y - jwtHelpLabel.bounds.height/2)
        }
        
        let scale: CGFloat = !jwtHelpLabel.isHidden ? 0.0001:1
        let damping: CGFloat = !jwtHelpLabel.isHidden ? 1.0:0.8
        let springVelocity: CGFloat = !jwtHelpLabel.isHidden ? 0.5:10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: springVelocity, options: .curveEaseInOut,
                       animations: {
                        self.jwtHelpLabel.isHidden = false
                        self.demoAppHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
                        self.sparkIdHelpLabel.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
                        self.jwtHelpLabel.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                        self.view.layoutIfNeeded()
                        self.animationsCompletion = false
        }, completion: { finished in
            self.demoAppHelpLabel.isHidden = true
            self.sparkIdHelpLabel.isHidden = true
            self.animationsCompletion = true
            self.jwtHelpLabel.isHidden = scale<1 ? true:false
        })
    }
}

