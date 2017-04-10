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

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dialButton: UIButton!
    
    @IBOutlet weak var avatarImageHeight: NSLayoutConstraint!
    @IBOutlet var heightScaleCollection: [NSLayoutConstraint]!
    
    @IBOutlet var labelFontScaleCollection: [UILabel]!
    
    @IBOutlet var widthScaleCollection: [NSLayoutConstraint]!
    
    var address: String?
    var initiateCallViewController: InitiateCallViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selector = #selector(PersonTableViewCell.dial)
        dialButton.addTarget(self, action: selector, for: UIControlEvents.touchUpInside)
        
        
        for label in labelFontScaleCollection {
            label.font = UIFont.labelLightFont(ofSize: label.font.pointSize * Utils.HEIGHT_SCALE)
        }
        for heightConstraint in heightScaleCollection {
            heightConstraint.constant *= Utils.HEIGHT_SCALE
        }
        for widthConstraint in widthScaleCollection {
            widthConstraint.constant *= Utils.WIDTH_SCALE
        }
        
        avatarImageView.layer.cornerRadius = avatarImageHeight.constant/2
    }
    
    func dial(_ sender: UIButton) {
        initiateCallViewController.dial(address!)
    }
}
