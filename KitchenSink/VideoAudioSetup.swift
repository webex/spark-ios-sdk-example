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

class VideoAudioSetup {
    
    static let sharedInstance = VideoAudioSetup()
    fileprivate var videoEnabled = true
    
    func setFacingMode(_ mode: Call.FacingMode) {
        Spark.phone.defaultFacingMode = mode
    }
    
    func getFacingMode() -> Call.FacingMode {
        return Spark.phone.defaultFacingMode
    }
    
    func setLoudSpeaker(_ enable: Bool) {
        Spark.phone.defaultLoudSpeaker = enable
    }
    
    func isLoudSpeaker() -> Bool {
        return Spark.phone.defaultLoudSpeaker
    }
    
    func setVideoEnabled(_ enable: Bool) {
        videoEnabled = enable
    }
    
    func isVideoEnabled() -> Bool {
        return videoEnabled
    }
}
