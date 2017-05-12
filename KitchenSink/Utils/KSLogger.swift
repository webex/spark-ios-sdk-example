//
//  KSLogger.swift
//  KitchenSink
//
//  Created by panzh on 11/05/2017.
//  Copyright © 2017 Cisco Systems, Inc. All rights reserved.
//

import Foundation
import SparkSDK

///Developer should implementation the SDK Logger protocol for troubleshooting.
public class KSLogger : Logger {
    public func log(message: LogMessage) {
        print(message)
    }
}
