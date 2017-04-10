//
//  SparkContext.swift
//
//  Copyright © 2017 Cisco Systems Inc. All rights reserved.
//

import Foundation
import SparkSDK

class SparkEnvirmonment {
    static let ClientId = "Cb3f891d2044fec65bfe36a8d1b3d69b3098448e9e0335c58bab42f5b94ad06c9"
    static let ClientSecret = ProcessInfo().environment["CLIENTSECRET"] ?? ""
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
        if call!.status != .Disconnected {
            call?.hangup() { ret in
                self.call = nil
            }
        }
        else {
            call = nil
        }
    }
    
    func deinitSpark() {
        guard spark != nil else {
            return
        }
        
        if call != nil {
            deinitCall()
        }
        
        spark!.phone.deregister() { ret in
            self.spark?.authenticationStrategy.deauthorize()
            self.selfInfo = nil
            self.spark = nil
        }
        
    }
    
    static func getOAuthStrategy() -> OAuthStrategy {
        return OAuthStrategy(clientId: SparkEnvirmonment.ClientId, clientSecret: SparkEnvirmonment.ClientSecret, scope: SparkEnvirmonment.Scope, redirectUri: SparkEnvirmonment.RedirectUri)
    }
    
    static func initSparkForSparkIdLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticationStrategy: SparkContext.getOAuthStrategy())
    }
    
    static func initSparkForJWTLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticationStrategy: JWTAuthStrategy())
    }
}

