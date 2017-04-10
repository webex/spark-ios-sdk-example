//
//  UserDefaultUtil.swift
//  KitchenSink
//
//  Created by panzh on 06/04/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import SparkSDK


public class UserDefaultsUtil {
    private static let CALL_PERSON_HISTORY_KEY = "KSCallPersonHistory"
    private static let CALL_PERSON_HISTORY_ADDRESS_KEY = "KSCallPersonHistoryAddress"
    static let userDefault = UserDefaults.standard
    static var callPersonHistory: [Person] {
        get {
            var resutlArray: [Person] = []
            if let array = userDefault.array(forKey: CALL_PERSON_HISTORY_KEY) {
                for onePerson in array {
                    if let personString = onePerson as? String {
                        if var p = Person(JSONString: personString) {
                            p.emails = getPersonAddress(p)
                            if p.emails != nil {
                                resutlArray.append(p)
                            }
                        }
                    }
                }
                
            }
            return resutlArray
            
        }
    }
    
    static func addPersonHistory(_ person:Person) {
        //save address for person
        UserDefaultsUtil.savePersonAddress(person)
        
        let personString = person.toJSONString()
        
        guard personString != nil else {
            return
        }
        var resultArray: [Any]
        
        if var array = userDefault.array(forKey: CALL_PERSON_HISTORY_KEY) {
            
            for onePerson in array {
                if let personString = onePerson as? String {
                    if let p = Person(JSONString: personString) {
                        if p.id == person.id {
                            return
                        }
                    }
                }
            }
            
            array.append(personString!)
            if array.count > 10 {
                array.removeFirst()
            }
            resultArray = array
        }
        else
        {
            resultArray = Array.init()
            resultArray.append(personString!)
        }
        
        userDefault.set(resultArray, forKey: CALL_PERSON_HISTORY_KEY)
        
    }
    
    private static func savePersonAddress(_ person:Person) {
        guard person.id != nil && person.emails?.first != nil else {
            return
        }
        
        guard !person.emails!.first!.toString().isEmpty else {
            return
        }
        
        var addressDic: Dictionary<String, Any>?
        if let dic = userDefault.dictionary(forKey: CALL_PERSON_HISTORY_ADDRESS_KEY) {
            addressDic = dic
            addressDic!.updateValue(person.id!, forKey: person.emails!.first!.toString())
            
        }
        else {
            addressDic = [person.id! : person.emails!.first!.toString()]
        }
        userDefault.set(addressDic, forKey: CALL_PERSON_HISTORY_ADDRESS_KEY)
    }
    
    private static func getPersonAddress(_ person:Person) -> [EmailAddress]? {
        guard person.id != nil else {
            return nil
        }
        
        var emails:[EmailAddress]?
        
        if let dic = userDefault.dictionary(forKey: CALL_PERSON_HISTORY_ADDRESS_KEY) {
            if let email = dic[person.id!] {
                if let str = email as? String {
                    if let ea = EmailAddress.fromString(str) {
                        emails = [ea]
                    }
                }
            }
        }
        return emails
    }
}
