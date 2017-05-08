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


//Get your own App Client information from https://developer.ciscospark.com
class SparkEnvirmonment {
    static let ClientId = "Cb3f891d2044fec65bfe36a8d1b3d69b3098448e9e0335c58bab42f5b94ad06c9"
    static let ClientSecret = ProcessInfo().environment["CLIENTSECRET"] ?? "f2660da9c8b90a9cdfe713f7c115473b76da531bb7ec9c66fdb8ec1481585879"
    static let Scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
    //Uri is that a user will be redirected to when completing an OAuth grant flow
    static let RedirectUri = "KitchenSink://response"
}

//*Spark* object is the entry point to use this Cisco Spark iOS SDK
//this app simplely use one Spark instance to demo all the SDK function.
class SparkContext: NSObject {

    static let sharedInstance: SparkContext = SparkContext()
    var spark: Spark?
    //authorized user
    var selfInfo :Person?
    //The recent active call
    var call: Call?

    //make sure hangup the last call before your create a new one.
    func deinitCall() {
        guard call != nil else {
            return
        }
        // Disconnects this call. 
        // Otherwise error will occur and completionHandler will be dispatched.
        call?.hangup() { error in
            
        }
        self.call = nil
    }
    
    //when the user log out,you must delloc the spark to release the memory.
    func deinitSpark() {
        guard spark != nil else {
            return
        }
        
        if call != nil {
            deinitCall()
        }
        
        // Removes this *phone* from Cisco Spark cloud on behalf of the authenticated user.
        // It also disconnects the websocket from Cisco Spark cloud.
        // Subsequent invocations of this method behave as a no-op.
        spark!.phone.deregister() { ret in
            // Deauthorizes the current user and clears any persistent state with regards to the current user.
            // If the *phone* is registered, it should be deregistered before calling this method.
            self.spark?.authenticator.deauthorize()
            self.selfInfo = nil
            self.spark = nil
        }
        
    }
    
    //OAuth helper function
    static func getOAuthStrategy() -> OAuthAuthenticator {
        return OAuthAuthenticator(clientId: SparkEnvirmonment.ClientId, clientSecret: SparkEnvirmonment.ClientSecret, scope: SparkEnvirmonment.Scope, redirectUri: SparkEnvirmonment.RedirectUri)
    }
    
    //log in with Spark ID helper function
    static func initSparkForSparkIdLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticator: SparkContext.getOAuthStrategy())
    }
    
    //log in with Spark ID helper function
    static func initSparkForJWTLogin() {
        SparkContext.sharedInstance.spark = Spark(authenticator: JWTAuthenticator())
    }
    
    //call memberships include yourself,so if you are calling someone,callerEmail is your email address.
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

