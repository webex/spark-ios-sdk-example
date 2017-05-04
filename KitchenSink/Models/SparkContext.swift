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

import Foundation
import SparkSDK

class SparkEnvirmonment {
    static let ClientId = "Cb3f891d2044fec65bfe36a8d1b3d69b3098448e9e0335c58bab42f5b94ad06c9"
    static let ClientSecret = ProcessInfo().environment["CLIENTSECRET"] ?? "f2660da9c8b90a9cdfe713f7c115473b76da531bb7ec9c66fdb8ec1481585879"
    static let Scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
    static let RedirectUri = "KitchenSink://response"
}


class SparkContext: NSObject {
    
    //    let UI: TestUI
    static let sharedInstance: SparkContext = SparkContext()
    var spark: Spark?
    var selfInfo :Person?
    var call: Call?
    
    private var userInfo = [String:Any]()
    
    subscript (userInfo key: String) -> Any? {
        get {
            return self.userInfo[key]
        }
        set {
            self.userInfo[key] = newValue
        }
    }
    
    func deinitCall() {
        guard call != nil else {
            return
        }
        
        call?.hangup()
        self.call = nil
    }
    
    func deinitSpark() {
        guard spark != nil else {
            return
        }
        
        if call != nil {
            deinitCall()
        }
        
        spark!.phone.deregister() { ret in
            self.spark?.authenticator.deauthorize()
            self.selfInfo = nil
            self.spark = nil
        }
        
    }
    
    static func getOAuthStrategy() -> OAuthStrategy {
        return OAuthStrategy(clientId: SparkEnvirmonment.ClientId, clientSecret: SparkEnvirmonment.ClientSecret, scope: SparkEnvirmonment.Scope, redirectUri: SparkEnvirmonment.RedirectUri)
    }
    
    static func initSparkForSparkIdLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticator: SparkContext.getOAuthStrategy())
    }
    
    static func initSparkForJWTLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticator: JWTAuthStrategy())
    }
    
    static var callerEmail: String {
        get {
            if let call = SparkContext.sharedInstance.call {
                for member in call.memberships {
                    if member.isInitiator == true {
                        return member.email ?? "Unknow"
                    }
                }
            }
            return "Unknow"
        }
    }
    
}

